varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
varying mat4 modelViewM;
varying mat4 projectionM;
varying vec3 vNormal;
uniform float time;
uniform sampler2D roofs_t;

vec4 facade(vec3 p, vec2 uv){
	vec4 col = vec4(0.0);

	float windows = 0.0;

	windows += cos(p.x * 300.0);
	windows *= cos(p.y * 200.0);

	windows *= 3.0;

	windows = clamp(windows, 0.0, 1.0);
	windows += cos(p.z * 300.0);
	windows = clamp(windows, 0.0, 0.7);

	col.rgb += windows * vec3(0.23, 0.2, 0.3);
	col += 0.02;
	col += 0.02 * cos(p.x * 2.0);
	col += 0.02 * cos(p.y * 2.0);
	col += 0.1 * cos(p.z * 2.0);

	return col;
}
			 
void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;
	vec3 p = vPosition;
	
	if(vNormal.z > 0.3){
		vec4 roofs_tex = texture2D(roofs_t, uv);
		
		// roof
		col = roofs_tex;
	} else {
		col = facade(p, uv);
	}

	col.a = 1.0;

	gl_FragColor = col;
}
