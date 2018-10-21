varying vec2 vUv;
varying vec3 vPosition;

void main() {
	vUv = uv;
	vec4 mvPosition = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
	
	vPosition = position;
	
	gl_Position = mvPosition;
}
