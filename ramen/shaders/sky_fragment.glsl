varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
uniform float time;
			 
void main() {
	vec4 col = vec4(0.0);
	vec3 p = normalize(vPosition);

	col = vec4(1.0);
	
	gl_FragColor = col;
}
