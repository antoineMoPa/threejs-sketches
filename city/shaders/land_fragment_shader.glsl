varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
varying mat4 modelViewM;
varying mat4 projectionM;
uniform float time;
uniform sampler2D land_t;
uniform sampler2D land_far_t;
uniform sampler2D roads_t;
varying float water_depth;

// Temporary
uniform float is_far;

float water_h(vec3 p, float intensity){
	float h = 0.0;
	// Scale
	float s = 30.0;

	float t = time * 1.0;

	h += 0.02 * cos(p.x * 1.0 + 2.6);
	h += 4.02 * cos(p.x * 2.0 + 3.2);
	h += 2.31 * cos(p.x * 4.0 + 1.7);
	h += 0.83 * cos(p.x * 8.0 + 2.0);
	h += 0.64 * cos(p.x * 16.0 + 1.4);
	h += 0.84 * cos(p.x * 32.0 + p.y * 32.0 + 0.4 + t);
	h += 0.33 * cos(p.x * 64.0 + 2.5 - t);
	h += 0.13 * cos(p.x * 128.0 + 1.5 - t);
	h += 0.60 * cos(p.x * 256.0 + p.y * 3.2 + t);
	h += 0.20 * cos(p.x * 512.0 + 3.2 + t);
	h += 0.30 * cos(p.x * 1024.0 + 1.2 + t);

	h += 3.21 * cos(p.y * 1.0 + 3.2);
	h += 2.94 * cos(p.y * 2.0 + 2.5);
	h += 0.65 * cos(p.y * 4.0 + 3.7 + t);
	h += 0.03 * cos(p.y * 8.0 + 1.8);
	h += 0.15 * cos(p.y * 16.0 + p.x * 16.0 + 1.3);
	h += 0.23 * cos(p.y * 32.0 + p.x * 32.0 + 2.8);
	h += 0.45 * cos(p.y * 64.0 + p.x * 64.0 + 1.3 - t);
	h += 0.35 * cos(p.y * 128.0 + 3.3 + t);
	h += 0.38 * cos(p.y * 256.0 + p.x * 16.0 + 0.3 + t);
	h += 0.40 * cos(p.y * 512.0 + 1.3 + t);
	h += 0.20 * cos(p.y * 1024.0 + 1.3 + t);
	
	h *= intensity;

	return h;
}

vec4 water(float intensity) {
	vec4 col = vec4(0.0);
	
	vec2 uv = vUv;
	vec3 p = vPosition;
	
	vec3 point_lamp = vec3(4.0, 10.0, 10.0);
	
	vec4 lampmvp = modelViewM * vec4(point_lamp, 1.0);
	point_lamp = (projectionM * lampmvp).xyz;

	float h = water_h(p, intensity);
	
	vec3 n = vec3(0.0);
	float delta = 0.4;
	n.x = water_h(p - vec3(delta,0.0,0.0), intensity) - water_h(p + vec3(delta,0.0,0.0), intensity);
	n.y = water_h(p - vec3(0.0,delta,0.0), intensity) - water_h(p + vec3(0.0,delta,0.0), intensity);
	n.z = 1.0;
	
	n = normalize(n);
	
	h *= 0.8;
	
	col.rgb = vec3(0.1, 0.4, 0.8);

	float spec = pow(0.01 * dot(n, point_lamp),2.0);
	float diff = 0.03 * dot(n, point_lamp);

	if(intensity < 0.02){
		float fac = (1.0 - intensity - 0.98)/0.02;
		fac += 0.3 * cos(fac * 10.0 - time * 10.0);
		col.rgb += 0.2 * fac;
	}

	spec = clamp(spec, 0.0, 1.0);
	diff = clamp(diff, 0.0, 1.0);
	
	col.rgb *= spec + diff + 0.2;

	col.a = 1.0;

	
	return col;
}

vec4 land(vec3 p, vec2 uv){
	vec4 col = vec4(0.0);
	// Todo: phong
	vec4 land_tex = texture2D(land_t, uv);

	land_tex.rgb *= 0.5 + 0.5 * clamp(p.z/0.01, 0.0, 1.0);

	col += land_tex;
	
	vec4 roads = texture2D(roads_t, uv);

	vec4 road_col = vec4(0.3);

	// Yellow line
	if(roads.r < 0.3){
		road_col.rg += 0.1 *
			clamp(cos(p.x * 500.0), 0.0, 1.0) *
			clamp(cos(p.y * 500.0), 0.0, 1.0);
	}
	
	// Smooth out road edge
	float fac = 1.0;
	float limit = 0.4;
	
	if(roads.r > limit){
		fac = 1.0 - (roads.r-(1.0-limit))/limit;
	}
	
	fac = clamp(fac, 0.0, 1.0);
	col = fac * road_col + (1.0 - fac) * land_tex;

	col.a = 1.0;
	
	return col;
}
			 
void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;
	vec3 p = vPosition;

	if(is_far < 0.5){
		
		float water_fac = water_depth/0.01;
		water_fac = clamp(water_fac, 0.0, 1.0);
		
		vec4 water_col = water(water_fac);
		
		if(water_depth < 0.01){
			water_col +=
				(1.0 - water_depth/0.01) *
				(
					vec4(0.1) +
					vec4(0.7) *
					abs(
						cos(
							water_depth / 0.01 * 24.0 +
							0.5 * cos(p.x * 200.0) +
							time * 10.0
							)
						)
					);
		}
		
		vec4 land_col = land(p, uv);
		col += water_fac * water_col + (1.0 - water_fac) * land_col;
		
	} else {
		col = texture2D(land_far_t, uv);
	}
	
	col.a = 1.0;
	
	gl_FragColor = col;
}
