varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec4 mvPosition;
varying vec4 mvNormal;
uniform float time;

void main() {
	vUv = uv;
	vNormal = normal;
	
	vec3 p = position;

	mvPosition = modelViewMatrix * vec4(p,1.0);
	mvNormal = projectionMatrix * modelViewMatrix * vec4(normal, 1.0);
	gl_Position = projectionMatrix * mvPosition;

	vPosition = p;
}
		
