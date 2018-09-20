varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
varying vec3 vNormal;
uniform float time;
uniform sampler2D roofs_t;

			 
void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;
	vec3 p = vPosition;
	vec2 c = gl_PointCoord - vec2(1.0);
	
	col.g = 0.3;
	
	col.a = 1.0;

	col *= 0.5 * cos(c.y * 10.0 + c.x * 3.0) + 0.5;

	col.a = 1.0 - 0.4 * length(c);
	
	gl_FragColor = col;
}
