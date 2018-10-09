varying vec2 vUv;
varying vec3 vPosition;

void main() {
	vUv = uv;
	vec3 p = position.xzy;

	p.z *= -1.0;

	p.y += 0.05;
	
	vPosition = p;

	gl_PointSize = 20.0;
	gl_Position = projectionMatrix * modelViewMatrix * vec4(p, 1.0);
}
		
