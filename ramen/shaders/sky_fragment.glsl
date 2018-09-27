varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
uniform float time;
			 
void main() {
	vec4 col = vec4(0.0);
	vec3 p = normalize(vPosition);

	// Move horizon slightly below
	p.y = p.y + 0.2;
	
	//col.r = 1.0;

	col.r += 1.2 - abs(p.y) * 3.0;
	col.g += 1.0 - abs(p.y) * 0.8 + 0.8;
	col.b += 1.0 - abs(p.y) * 0.3 + 0.2;

	if(p.y < 0.0){
		col.rgb *= 0.0;
	}
	
	col.a = 1.0;

	gl_FragColor = col;
}
