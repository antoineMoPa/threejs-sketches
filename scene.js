/*
  Copyright 2018 Antoine Morin-Paulhus
  Started from Three.js Collada example code (the one with the elf)
  
  This file is part of landscape2018.
  
  landscape2018 is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
  
  landscape2018 is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with landscape2018.  If not, see <https://www.gnu.org/licenses/>.
*/

function start(){
	init();
	animate();
}

if ( ! Detector.webgl ) Detector.addGetWebGLMessage();

var shaders_to_load = [
	"land_fragment_shader.glsl", "land_vertex_shader.glsl",
	"building_fragment_shader.glsl", "building_vertex_shader.glsl",
	"post_fragment.glsl", "post_vertex.glsl",
	"sky_fragment.glsl", "sky_vertex.glsl",
	"trees_fragment.glsl", "trees_vertex.glsl"
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
var camera, scene, renderer, composer, ppshader;
var land, sky;
var renderPass, depthPass, shaderPass;
var collada;
//var player_width = 800;
//var player_height = 500;
var player_width = window.innerWidth;
var player_height = window.innerHeight;


function init() {
	container = document.getElementById( 'container' );
	camera = new THREE.PerspectiveCamera( 45, player_width / player_height, 0.1, 2000 );
	camera.position.set( 1.8, 0.5, 2.0 );
	camera.lookAt( 0, 0.5, 0 );
	scene = new THREE.Scene();
	clock = new THREE.Clock();
	
	var textureLoader = new THREE.TextureLoader();

	
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
	
	uniforms.land_t = {
		type: "t",
		value: textureLoader.load("./models/land/blend/ground.png")
	};	

	uniforms.roads_t = {
		type: "t",
		value: textureLoader.load("./road_generator/out.png")
	};
	
	uniforms.roofs_t = {
		type: "t",
		value: textureLoader.load("./road_generator/roofs.png")
	};

	uniforms.is_far = {
		value: 0.0
	};
		

	// loading manager
	var loadingManager = new THREE.LoadingManager( function() {
		scene.add( land );
	} );
	
	// collada
	var loader = new THREE.ColladaLoader( loadingManager );

	loader.load( './models/land/blend/land.dae', function ( _collada ) {
		collada = _collada;
		land = _collada.scene;

		// Shading

		// Land
		
		land.children[0].material[0] = new THREE.ShaderMaterial(
			{
				transparent: true,
				uniforms: uniforms,
				vertexShader: shaders['land_vertex_shader.glsl'],
				fragmentShader: shaders['land_fragment_shader.glsl']
			}
		);

		var far_uniforms = THREE.UniformsUtils.clone(uniforms);

		far_uniforms.is_far = {value: 1.0};

		far_uniforms.land_far_t = {
			type: "t",
			value: textureLoader.load("./models/land/blend/ground_far.png")
		};

		
		// Land-far
		land.children[0].material[1] = new THREE.ShaderMaterial(
			{
				transparent: false,
				uniforms: far_uniforms,
				vertexShader: shaders['land_vertex_shader.glsl'],
				fragmentShader: shaders['land_fragment_shader.glsl']
			}
		);

		
		// Buildings
		land.children[1].material[0] = new THREE.ShaderMaterial(
			{
				transparent: false,
				uniforms: uniforms,
				vertexShader: shaders['building_vertex_shader.glsl'],
				fragmentShader: shaders['building_fragment_shader.glsl']
			}
		);
		
		// Trees
		var trees_matrial = new THREE.ShaderMaterial(
			{
				transparent: true,
				uniforms: uniforms,
				vertexShader: shaders['trees_vertex.glsl'],
				fragmentShader: shaders['trees_fragment.glsl']
			}
		);

		var geometry = new THREE.BufferGeometry();
		var vertices = new Float32Array(collada.library.geometries["trees-mesh"].sources["trees-mesh-positions"].array);
		geometry.addAttribute( 'position', new THREE.BufferAttribute( vertices, 3 ) );
		
		var trees = new THREE.PointCloud(geometry, trees_matrial);

		scene.add(trees);
	} );
	
	//
	var ambientLight = new THREE.AmbientLight( 0xcccccc, 0.3 );
	//scene.add( ambientLight );
	var directionalLight = new THREE.DirectionalLight( 0xffffff, 0.1 );
	directionalLight.position.set( 10, 10, 1 );
	scene.add( directionalLight );

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
	
	renderer.setPixelRatio( window.devicePixelRatio );
	renderer.setSize( player_width, player_height );
	container.appendChild( renderer.domElement );
	//
	stats = new Stats();
	container.appendChild( stats.dom );
	//
	window.addEventListener( 'resize', onWindowResize, false );

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

function onWindowResize() {
	camera.aspect = player_width / player_height;
	camera.updateProjectionMatrix();
	renderer.setSize( player_width, player_height );
}

function animate() {
	requestAnimationFrame( animate );
	render();
	stats.update();
}

function render() {
	var delta = clock.getDelta();

	// TODO: add back time to land shader
	var t = shaderPass.uniforms.time.value = clock.elapsedTime;
	uniforms.time.value = clock.elapsedTime;

	camera.position.x = 3.0 * Math.cos(t * 0.3);
	camera.position.z = 3.0 * Math.sin(t * 0.3);
	camera.position.y = 0.3 * Math.sin(t * 0.3) + 0.8;
	camera.lookAt( 0, 0.5, 0 );
	
	composer.render();
}
