varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
varying mat4 modelViewM;
varying mat4 projectionM;
uniform float time;
varying float water_depth;

#define PI2 6.2832

void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;
	vec3 p = vPosition;

	float noodle_fac = cos(uv.x * 2.0 * PI2 + 0.5 * cos(uv.y * 8.0 * PI2) + 3.1416/2.0);
	noodle_fac = abs(noodle_fac);
	noodle_fac = clamp(pow(noodle_fac, 2.0), 0.0, 1.0);
	
	col.rgb = vec3(0.8, 0.8, 0.6) - (1.0 - noodle_fac);

	col *= 1.0 - 0.1 * distance(p.z, 0.8)/0.2;

	// Tweak color
	col *= 1.0 + 0.3 * cos(time * 1.0 + p.x * 20.0);
	col *= 1.0 + 0.3 * cos(time * 1.0 + p.y * 30.0);
	
	col.a = noodle_fac;
	
	gl_FragColor = col;
}
