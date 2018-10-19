varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
uniform float time;
uniform sampler2D tex;
uniform vec2 screen_dim;

#define cl01(x) clamp(x, 0.0, 1.0)
#define PI2 6.2832

vec4 neon(vec2 uv){
	
	vec4 col = vec4(0.0);

	uv = mod(uv, vec2(1.0));
	
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

	// I Moved the UVs to the left in blender
	// to indicate wheter the road was uni or bi-
	// directional
	if(uv.x < 0.0){
		uv.x += 1.0;
		uv.x /= 2.0;
		uv.y = 1.0 - uv.y;
	} else {
		// In this case, we are bidirectional
		// So we change the orientation at the middle
		if(uv.x > 0.5){
			uv.y = 1.0 - uv.y;
			uv.x -= 0.4;
		}
	}
	
	// Road side neon
	float light = 0.0;
	float size = 0.1;
	
	// Find sprite coords for small car
	vec2 p = vec2(0.0);
	p.x = uv.x;
	p.y = mod(uv.y * 2.0 + time, 1.0);
	p.y -= 0.6;
	p.y = p.y / 0.3;

	if(p.y > 0.0){
		p *= 0.1562;
		p.x *= 3.0;
		p.y = 1.0 - p.y;
		p.x -= 0.05;
		col = 0.8 * texture2D(tex, p);
	}

	light = 2.0 * distance(p * vec2(3.0, 0.5), vec2(0.75,-0.4));
	light = 1.0 - cl01(light);
	
	col.r += 0.1 * light;
	col.g += 0.1 * light;
	col.b += 0.1 * light;
	col.a += light;
	
	return col;
}

void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;

	col.rgb = vec3(0.01);
	
	col += neon(uv);
	col += cars(uv);

	col.a = 0.8;
	
	gl_FragColor = col;
}
