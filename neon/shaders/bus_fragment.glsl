varying vec2 vUv;
varying vec4 mvPosition;
varying mat4 mvMatrix;
varying vec4 mvNormal;
varying vec3 vPosition;
varying vec3 vNormal;
uniform float time;
uniform sampler2D tex;

uniform vec2 screen_dim;

#define PI2 6.2832
#define PI 3.1416

void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;

	if(uv.x > 2.0){
		// Decals
		uv.x -= 2.0;
		col = texture2D(tex, uv);
		col.rgb *= 1.0 + 0.2 * cos(time + vUv.x * 50.0);
		col.rgb *= 1.0 + 0.2 * cos(time + vUv.y * 50.0);
	} else if(uv.x > 1.0){
		// Propulsor output
		float p = 0.0;
		uv.x -= 1.0;
		p += 1.0 * cos(time * 30.0 - mvPosition.z * 600.0);
		p = clamp(p, 0.0, 1.0);
		p += 1.4;
		p *= 1.0 - 2.0 * abs(uv.x - 0.5);

		p *= cos(uv.y * PI2 + PI/2.0);
		
		col.r += 0.4 * pow(p, 1.2) * uv.y;
		col.b += 0.4 * pow(p, 1.8) * uv.y;
		col.a = p;
	} else {
		col = texture2D(tex, vUv);
		col.r += 0.02 * (cos((cameraPosition.z + cameraPosition.x + mvPosition.z) * 4.0) + 1.0);
		col.g += 0.01 * (cos((cameraPosition.z + cameraPosition.x + mvPosition.z) * 6.0) + 1.0);
		col.b += 0.03 * (cos((cameraPosition.z + cameraPosition.x + mvPosition.z) * 7.0) + 1.0);
	}
	
	gl_FragColor = col;
}
