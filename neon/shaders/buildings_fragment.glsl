varying vec2 vUv;
varying vec4 mvPosition;
varying vec4 mvNormal;
varying vec3 vPosition;
varying vec3 vNormal;
uniform float time;

uniform vec2 screen_dim;

#define PI2 6.2832

vec4 neon(vec2 uv){
	vec4 col = vec4(0.0);

	/*
	  There are some very annoying glitches when rendering far-away neons without making 
	  them bigger and dimmer.
	 */
	float size_modifier = 0.001 * mvPosition.z;
	float color_modifier = (1.0 + 3.0 * size_modifier);

	// X neon
	float neon = 0.0;
	float size = 0.01 - size_modifier;
	neon += saturate(1.0 - abs(uv.x - 0.05)/size);
	neon += saturate(1.0 - abs(uv.x - 0.95)/size);
	col.r += 0.7 * neon;
	col.b += 0.3 * neon;

	// Same with blur
	neon = 0.0;
	size = 0.03 - size_modifier;
	neon += saturate(1.0 - abs(uv.x - 0.05)/size);
	neon += saturate(1.0 - abs(uv.x - 0.95)/size);
	col.r += 0.3 * neon;
	col.b += 0.2 * neon;

	size_modifier *= 8.0;
	
	// Y neon
	neon = 0.0;
	size = 0.01 - size_modifier;
	neon += saturate(1.0 - abs(uv.y - 0.05)/size);
	neon += saturate(1.0 - abs(uv.y - 0.95)/size);
	
	col.b += 0.4 * neon * color_modifier;

	neon = 0.0;
	size = 0.05 - size_modifier;
	neon += saturate(1.0 - abs(uv.y - 0.05)/size);
	neon += saturate(1.0 - abs(uv.y - 0.95)/size);
	col.b += 0.2 * neon * color_modifier;

	return col;
}

#define cl01(x) clamp(x, 0.0, 1.0)

vec4 windows(vec3 p, vec2 uv){
	vec4 col = vec4(0.0);

	float windows = 0.0;

	if(abs(vNormal.x) > abs(vNormal.y)){
		windows = cl01(10.0 * cos(p.y * 60.0));
	} else {
		windows = cl01(10.0 * cos(p.x * 60.0));
	}
	
	windows *= cl01(10.0 * cos(p.z * 60.0));

	windows = cl01(windows * 10.0);

	col.r += 0.04 * windows;
	col.g += 0.02 * windows;
	col.b += 0.01 * windows;

	if(windows > 0.2){
		col.rgb += 0.06 * clamp(10.0 * cos(mvNormal.xyz + p), 0.0, 1.0);
	}
	
	col.rgb *= 1.0 + 0.3 * windows;

	if(uv.x > 0.9 || uv.x < 0.1 || uv.y < 0.1 || uv.y > 0.9){
		col *= 0.0;
	}
	
	return col;
}

void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;

	col.rgb = vec3(0.0);

	if(vNormal.z < -0.1){
		// Here we are probably in some weird building with floor larger that floor below
		col.rgb = vec3(0.0);
		col.a = 1.0;
	} else if(vNormal.z < 0.2){
		// Because normal is pointing up:
		// not roof : add windows
		col += windows(vPosition, uv);
		col += neon(uv);
		col -= 0.01 * length(uv - vec2(0.5));
		col.a = 1.0;
	} else {
		// Roof
		col += 0.001 - 0.04 * length(uv - vec2(0.5));
		col.a = 1.0;
	}
	
	gl_FragColor = col;
}
