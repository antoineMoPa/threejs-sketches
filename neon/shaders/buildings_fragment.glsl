varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
uniform float time;

uniform vec2 screen_dim;

#define PI2 6.2832

vec4 neon(vec2 uv){
	vec4 col = vec4(0.0);

	// X neon
	float neon = 0.0;
	float size = 0.01;
	neon += saturate(1.0 - abs(uv.x - 0.1)/size);
	neon += saturate(1.0 - abs(uv.x - 0.9)/size);
	col.r += neon;
	col.b += 0.3 * neon;

	// Same with blur
	neon = 0.0;
	size = 0.03;
	neon += saturate(1.0 - abs(uv.x - 0.1)/size);
	neon += saturate(1.0 - abs(uv.x - 0.9)/size);
	col.r += 0.2 * neon;
	col.b += 0.1 * neon;
	
	// Y neon
	neon = 0.0;
	size = 0.01;
	neon += saturate(1.0 - abs(uv.y - 0.1)/size);
	neon += saturate(1.0 - abs(uv.y - 0.9)/size);
	
	col.b += neon;

	neon = 0.0;
	size = 0.05;
	neon += saturate(1.0 - abs(uv.y - 0.1)/size);
	neon += saturate(1.0 - abs(uv.y - 0.9)/size);
	col.b += 0.2 * neon;

	return col;
}

#define cl01(x) clamp(x, 0.0, 1.0)

vec4 windows(vec3 p, vec2 uv){
	vec4 col = vec4(0.0);

	float windows = 0.0;

	windows += cl01(10.0 * cos(p.x * 60.0));
	windows *= cl01(10.0 * cos(p.y * 60.0));
	windows *= cl01(10.0 * cos(p.z * 60.0));

	windows = cl01(windows * 10.0);
	
	col.r += 0.04 * windows;
	col.g += 0.02 * windows;
	col.b += 0.01 * windows;
	
	return col;
}

void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;

	col.rgb = vec3(0.01);

	col += windows(vPosition, uv);
	col += neon(uv);

	col -= 0.01 * length(uv - vec2(0.5));
	
	col.a = 0.8;
	
	gl_FragColor = col;
}
