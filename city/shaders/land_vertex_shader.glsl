varying vec2 vUv;
#define water_height -0.02
varying vec3 vPosition;
varying vec4 mvPosition;
varying mat4 modelViewM;
varying mat4 projectionM;
varying float water_depth;

void main() {
	vUv = uv;
	
	water_depth = -1.0;

	vec3 p = position;
	
	// If lower than a certain point, create water
	if(p.z < water_height){
		water_depth = abs(water_height - p.z);
		p.z = water_height;
	}
	
	mvPosition = modelViewMatrix * vec4(p,1.0);
	gl_Position = projectionMatrix * mvPosition;

	modelViewM = modelViewMatrix;
	projectionM = projectionMatrix;

	
	vPosition = p;
}
		