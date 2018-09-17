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

	windows = cos(p.x * 600.0);
    windows = clamp(windows * 100.0 + 50.0, 0.0, 1.0);

	float windowsy = cos(p.z * 400.0);
    windows *= clamp(windowsy * 100.0 + 50.0, 0.0, 1.0);
    
    col += windows * vec4(0.1, 0.1, 0.2, 0.0);
	
	col.rgb += vec3(0.0, 0.0, 0.2);
	col.rgb -= windows * vec3(0.23, 0.2, 0.3);

	col.rgb += 0.3 - 0.7 * p.z;
	
	col.a = 1.0;
	
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
