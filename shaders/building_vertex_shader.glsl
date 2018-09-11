varying vec2 vUv;
varying vec3 vPosition;
varying vec4 mvPosition;
varying mat4 modelViewM;
varying mat4 projectionM;
varying vec3 vNormal;

void main() {
	vUv = uv;
	
	vec3 p = position;

	vNormal = normal;
	
	mvPosition = modelViewMatrix * vec4(p,1.0);
	gl_Position = projectionMatrix * mvPosition;

	modelViewM = modelViewMatrix;
	projectionM = projectionMatrix;

	vPosition = p;
}
		
