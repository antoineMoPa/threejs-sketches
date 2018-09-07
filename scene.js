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


if ( ! Detector.webgl ) Detector.addGetWebGLMessage();

var container, stats, clock, uniforms;
var camera, scene, renderer, land;
init();
animate();

function init() {
	container = document.getElementById( 'container' );
	camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 0.1, 2000 );
	camera.position.set( 5, 5, 5 );
	camera.lookAt( 0, 0.5, 0 );
	scene = new THREE.Scene();
	clock = new THREE.Clock();

	var textureLoader = new THREE.TextureLoader();
	
	uniforms = {};
	
	uniforms = THREE.UniformsUtils.merge(
		[
			THREE.UniformsLib['common'],
			THREE.UniformsLib['lights']
		]
	);

	uniforms.time = {value: 0.0};
	uniforms.land_t = {
		type: "t",
		value: textureLoader.load("./models/land/blend/ground.png")
	};
	uniforms.roads_t = {
		type: "t",
		value: textureLoader.load("./road_generator/out.png")
	};


	
	// loading manager
	var loadingManager = new THREE.LoadingManager( function() {
		scene.add( land );
	} );
	
	// collada
	var loader = new THREE.ColladaLoader( loadingManager );

	loader.load( './models/land/blend/land.dae', function ( collada ) {
		land = collada.scene;

		// Shading
		
		land.children[2].material = new THREE.ShaderMaterial(
			{
				transparent: true,
				uniforms: uniforms,
				vertexShader:
				document.getElementById( 'land_vertex_shader' ).textContent,
				fragmentShader:
				document.getElementById( 'land_fragment_shader' ).textContent
			}
		);

	} );
	
	//
	var ambientLight = new THREE.AmbientLight( 0xcccccc, 0.3 );
	//scene.add( ambientLight );
	var directionalLight = new THREE.DirectionalLight( 0xffffff, 0.1 );
	directionalLight.position.set( 10, 10, 1 );
	scene.add( directionalLight );
	
	renderer = new THREE.WebGLRenderer();
	renderer.setPixelRatio( window.devicePixelRatio );
	renderer.setSize( window.innerWidth, window.innerHeight );
	container.appendChild( renderer.domElement );
	//
	stats = new Stats();
	container.appendChild( stats.dom );
	//
	window.addEventListener( 'resize', onWindowResize, false );
}

function onWindowResize() {
	camera.aspect = window.innerWidth / window.innerHeight;
	camera.updateProjectionMatrix();
	renderer.setSize( window.innerWidth, window.innerHeight );
}

function animate() {
	requestAnimationFrame( animate );
	render();
	stats.update();
}

function render() {
	var delta = clock.getDelta();

	uniforms.time.value += delta;

	if ( land !== undefined ) {
		land.rotation.z += delta * 0.3;
	}
	
	renderer.render( scene, camera );
}
