varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
varying mat4 modelViewM;
varying mat4 projectionM;
uniform float time;
uniform sampler2D reflectionMap;
uniform vec2 screen_dim;

#define PI2 6.2832

void main() {
	vec4 col = vec4(0.0);
	vec3 p = vPosition;

	col.rgb = vec3(0.26, 0.12, 0.06);

	col.rgb *= 0.7;

	vec3 c = cameraPosition;
	vec2 uv = gl_FragCoord.xy / screen_dim;
	
	col += 0.2 * texture2D(reflectionMap, uv);
	col.a = 0.8;
	
	gl_FragColor = col;
}
