varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;

void main() {
	vUv = uv;
	vec3 p = position;
	vPosition = p;
	vNormal = normal;

	gl_Position = projectionMatrix * modelViewMatrix * vec4(p, 1.0);
	gl_Position.z = gl_Position.w;
}
		
