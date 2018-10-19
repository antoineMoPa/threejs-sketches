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
	
	
	col.rgb = vec3(0.01);

	vec2 p = vec2(0.0);

	p.x = cos(vPosition.x * 10.0);
	p.y = cos(vPosition.y * 10.0);

	col.rb += 0.02 * cl01(cos(p.x)) * cl01(cos(p.y));
	
	col.a = 1.0;
	
	gl_FragColor = col;
}
