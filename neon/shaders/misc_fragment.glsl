varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
uniform float time;
uniform sampler2D tex;
uniform vec2 screen_dim;

#define cl01(x) clamp(x, 0.0, 1.0)
#define PI2 6.2832

void main() {
	vec4 col = vec4(0.0);
	vec3 p = vPosition;

	col.r = 0.1;
	col.b = 0.2;
	col.g += 0.1 * cos(p.x * 100.0);
	
	col.a = 1.0;
	
	gl_FragColor = col;
}
