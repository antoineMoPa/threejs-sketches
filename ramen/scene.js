/*
  Copyright 2018 Antoine Morin-Paulhus
  Started from Three.js Collada example code (the one with the elf)
  
  This file is part of ramen.
  
  ramen is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  ramen is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with ramen.  If not, see <https://www.gnu.org/licenses/>.
*/

function start(){
	init();
	animate();
}

if (! Detector.webgl) Detector.addGetWebGLMessage();

var shaders_to_load = [
	"noodles_fragment.glsl", "noodles_vertex.glsl",
	"soup_fragment.glsl", "soup_vertex.glsl",
	"sky_fragment.glsl", "sky_vertex.glsl",
	"post_fragment.glsl", "post_vertex.glsl",
];

var loaded_shaders = 0;
var shaders = {};

for(var i = 0; i < shaders_to_load.length; i++){	
	var curr = i;

	function load(){
		shaders[this.shader_name] = this.responseText;
		loaded_shaders++;
		if(loaded_shaders == shaders_to_load.length){
			start();
		}
	}
	
	var req = new XMLHttpRequest();
	req.shader_name = shaders_to_load[i];
	req.addEventListener('load', load);
	//req.overrideMimeType("text/x-shader");
	req.open('GET', "./shaders/" + shaders_to_load[i]);
	req.send();
}

var container, stats, clock, uniforms;
var camera, reflectionCamera, scene, renderer, composer, ppshader;
var ramen, sky;
var renderPass, depthPass, shaderPass, reflectionTarget;
var collada;
var noodles, soup;
var player_width = 800;
var player_height = 500;
var mirror_normal = new THREE.Vector3(0, 1, 0);
//var player_width = window.innerWidth;
//var player_height = window.innerHeight;


function init(){
	container = document.getElementById('container');

	scene = new THREE.Scene();
	clock = new THREE.Clock();
	
	camera = new THREE.PerspectiveCamera(45, player_width / player_height, 0.1, 2000);
	camera.position.set(1.8, 0.5, 2.0);
	camera.lookAt(0, 0.5, 0);
	
	reflectionCamera = new THREE.PerspectiveCamera();
	
	reflectionTarget = new THREE.WebGLRenderTarget(
		256,
		256		
	);
	
	reflectionTarget.texture.minFilter = THREE.LinearMipMapLinearFilter;
	reflectionCamera.position.set(0.0, 0.82, 0.0);
	reflectionCamera.lookAt(0, -1.0, 0.0);
	
	scene.add(reflectionCamera);
	
	var textureLoader = new THREE.TextureLoader();

	uniforms = {};
	
	uniforms = THREE.UniformsUtils.merge(
		[
			THREE.UniformsLib['common'],
			THREE.UniformsLib['lights']
		]
	);

	uniforms.time = {
		value: 0.0
	};
			
	var skyMaterial = new THREE.ShaderMaterial(
		{
			uniforms: uniforms,
			vertexShader: shaders['sky_vertex.glsl'],
			fragmentShader: shaders['sky_fragment.glsl'],
			side: THREE.BackSide
		}
	);

	var skyBox = new THREE.BoxBufferGeometry(100, 100, 100);
	sky = new THREE.Mesh(skyBox, skyMaterial);
	scene.add(sky);
	
	// loading manager
	var loadingManager = new THREE.LoadingManager(function(){
		scene.add(ramen);
	});
	
	// collada
	var loader = new THREE.ColladaLoader(loadingManager);

	loader.load('./models/ramen/ramen.dae', function (_collada){
		collada = _collada;
		ramen = _collada.scene;

		// Special shading
		noodles = ramen.getChildByName("noodles");
		
		noodles.material = new THREE.ShaderMaterial(
			{
				transparent: true,
				uniforms: uniforms,
				vertexShader: shaders['noodles_vertex.glsl'],
				fragmentShader: shaders['noodles_fragment.glsl'],
			}
		);

		noodles.renderOrder = -1;


		var table = ramen.getChildByName("table");
		var stick_1 = ramen.getChildByName("stick_1");
		var stick_2 = ramen.getChildByName("stick_2");
		var bowl = ramen.getChildByName("bowl");
		stick_1.castShadow = true;
		stick_2.castShadow = true;
		bowl.castShadow = true;
		table.receiveShadow = true;

		var lamp = ramen.getChildByName("Lamp");
		lamp.castShadow = true;

		lamp.shadow.mapSize.width = 1024;
		lamp.shadow.mapSize.height = 1024;
		lamp.shadow.camera.near = 1.0;
		lamp.shadow.camera.far = 20;
		lamp.shadow.radius = 2;

		soup = ramen.getChildByName("soup");
		
		soup.material = new THREE.ShaderMaterial(
			{
				transparent: true,
				uniforms: uniforms,
				vertexShader: shaders['soup_vertex.glsl'],
				fragmentShader: shaders['soup_fragment.glsl'],
			}
		);
		
		soup.material.uniforms.reflectionMap = {
			type: "t",
			value: reflectionTarget.texture
		};
		soup.material.uniforms.screen_dim = {
			type: "v",
			value: [player_width, player_height]
		};
	});
	
	var ambientLight = new THREE.AmbientLight(0xffffff, 0.1);
	scene.add(ambientLight);

	// Post-Process uniforms
	var ppuniforms = {};

	ppuniforms['time'] = { type: "f", value: 0.0 };
	ppuniforms['cameraNear'] = { type: "f", value: camera.near };
	ppuniforms['cameraFar'] = { type: "f", value: camera.far };
	ppuniforms['tDiffuse'] = { type: "t", value: null };
	ppuniforms['tDepth'] = { type: "t", value: null };
	
	ppshader = {
		uniforms: ppuniforms,
		defines: {
			'DEPTH_PACKING': 1
		},
		vertexShader: shaders['post_vertex.glsl'],
		fragmentShader: shaders['post_fragment.glsl']
	};
	
	renderer = new THREE.WebGLRenderer({alpha: true});
	renderer.shadowMap.enabled = true;
	
	renderer.setPixelRatio(window.devicePixelRatio);
	renderer.setSize(player_width, player_height);
	container.appendChild(renderer.domElement);
	//
	stats = new Stats();
	container.appendChild(stats.dom);
	//
	window.addEventListener('resize', onWindowResize, false);

	composer = new THREE.EffectComposer(renderer);
	renderPass = new THREE.RenderPass(scene, camera);
	depthPass = new THREE.DepthPass(scene, camera);
	shaderPass = new THREE.ShaderPass(ppshader);

	shaderPass.uniforms['tDepth'].value = depthPass.renderTarget.texture;

	composer.addPass(renderPass);
	composer.addPass(depthPass);
	composer.addPass(shaderPass);

	shaderPass.renderToScreen = true;
}

function onWindowResize(){
	camera.aspect = player_width / player_height;
	camera.updateProjectionMatrix();
	renderer.setSize(player_width, player_height);
}

function animate(){
	requestAnimationFrame(animate);
	render();
	stats.update();
}

function render(){
	var delta = clock.getDelta();

	var t = shaderPass.uniforms.time.value = clock.elapsedTime;
	uniforms.time.value = clock.elapsedTime;

	// Render CubeMap
	if(noodles){
		reflectionCamera.copy(camera);

		reflectionCamera.projectionMatrix.elements[5] *= -1.0;
		
		// This is not working (not taken into account by render())
		//scene.scale.set(1.0, -1.0, 1.0);
		
		noodles.visible = false;
		soup.visible = false;
		sky.visible = false;
		renderer.render(scene, reflectionCamera, reflectionTarget, true);

		sky.visible = true;
		soup.visible = true;
		noodles.visible = true;
	}
		
	camera.position.x = 3.0 * Math.cos(t * 0.3);
	camera.position.y = 0.3 * Math.sin(t * 0.3) + 2.8;	
	camera.position.z = 3.0 * Math.sin(t * 0.3);
	camera.lookAt(0, 0.5, 0);
	
	composer.render();
}
