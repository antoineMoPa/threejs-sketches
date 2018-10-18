varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
uniform float time;

uniform vec2 screen_dim;

#define PI2 6.2832

vec4 neon(vec2 uv){
	vec4 col = vec4(0.0);

	// Road side neon
	float neon = 0.0;
	float size = 0.01;
	neon += saturate(1.0 - abs(uv.x - 0.1)/size);
	neon += saturate(1.0 - abs(uv.x - 0.9)/size);
	col.r += neon;
	col.g += 0.5 * neon;
	col.b += 0.8 * neon;

	// Same with blur
	neon = 0.0;
	size = 0.03;
	neon += saturate(1.0 - abs(uv.x - 0.1)/size);
	neon += saturate(1.0 - abs(uv.x - 0.9)/size);
	col.r += 0.5 * neon;
	col.g += 0.3 * neon;
	col.b += 0.2 * neon;
	
	return col;
}

vec4 cars(vec2 uv){
	vec4 col = vec4(0.0);

	// Road side neon
	float cars = 0.0;
	float size = 0.1;
	if(uv.x > 0.5){
		uv.y = 1.0 - uv.y;
	}
	float p = mod(uv.y * 2.0 + time, 1.0);
	cars += saturate(1.0 - abs(p - 0.1)/size);
	cars += saturate(1.0 - abs(p - 0.9)/size);

	cars *= abs(cos(uv.x * 8.0 + 0.0));
	
	col.r += 0.3 * cars;
	col.g += 0.5 * cars;
	col.b += 0.9 * cars;

	return col;
}


#define cl01(x) clamp(x, 0.0, 1.0)

void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;

	col.rgb = vec3(0.01);

	col += neon(uv);
	col += cars(uv);
	
	col.a = 0.8;
	
	gl_FragColor = col;
}
