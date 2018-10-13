varying vec4 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
varying mat4 modelViewM;
varying mat4 projectionM;
uniform float time;
uniform sampler2D tDiffuse;

uniform vec2 screen_dim;

#define PI2 6.2832

void main() {
	vec4 col = vec4(0.0);

	col.rgb = vec3(0.3, 0.12, 0.06);
	float blend = 0.1;
	vec4 tex = texture2DProj(tDiffuse, vUv);
	col = blend * tex + (1.0 - blend) * col;
	col.a = 0.8;
	
	gl_FragColor = col;
}
