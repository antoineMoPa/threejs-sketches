varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
uniform float time;

void main() {
	vec4 col = vec4(0.0);
	vec3 p = normalize(vPosition);
	
	col = vec4(0.0);

	col.r += 0.4 + 0.4 * pow(1.7* p.y, 2.8);
	col.g += 0.2 - 0.2 * pow(1.2* p.y, 2.4);
	col.b += 0.05 + 0.4 * pow(2.2* p.y, 2.2);

	col *= 0.8;
	
	if(p.y < 0.3){
		float f = p.y/0.3;
		col.rgb *= f;
	}
	
	col.a = 1.0;
	
	gl_FragColor = col;
}
