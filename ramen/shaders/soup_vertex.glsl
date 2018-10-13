varying vec4 vUv;
uniform mat4 textureMatrix;
uniform float time;

void main() {
	vUv = textureMatrix * vec4(position, 1.0);
	gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}
		
