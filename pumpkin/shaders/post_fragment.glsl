uniform float time;
uniform sampler2D tDiffuse, tDepth;
uniform float cameraNear;
uniform float cameraFar;
varying vec2 vUv;
varying vec3 vPosition;

// Depth unpacking code from ThreeJS examples

const float UnpackDownscale = 255. / 256.; // 0..1 -> fraction (excluding 1)
const vec3 PackFactors = vec3( 256. * 256. * 256., 256. * 256.,  256. );
const vec4 UnpackFactors = UnpackDownscale / vec4( PackFactors, 1. );

float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors );
}

float getDepth( const in vec2 screenPosition ) {
#if DEPTH_PACKING == 1
	return unpackRGBAToDepth( texture2D( tDepth, screenPosition ) );
#else
	return texture2D( tDepth, screenPosition ).x;
#endif
}

void main() {
	vec4 col = vec4(0.0);
	vec2 p = vUv - 0.5;
	vec2 uv = vUv;
	
	vec4 diffuse = texture2D(tDiffuse, uv);
	float depth = getDepth(uv);
	float z = cameraFar + ((depth) * ( cameraNear - cameraFar ) - cameraNear);

	vec2 offset = vec2(0.0);

	vec4 blur_col = vec4(0.0);
	float blur_size = 0.008;

	for(int i = 0; i < 2; i++){
		blur_size = blur_size * 1.5;
		blur_col += 0.25 * texture2D(tDiffuse, uv + vec2(blur_size, 0.0));
		blur_col += 0.25 * texture2D(tDiffuse, uv + vec2(0.0, blur_size));
		blur_col += 0.25 * texture2D(tDiffuse, uv + vec2(-blur_size, 0.0));
		blur_col += 0.25 * texture2D(tDiffuse, uv + vec2(0.0, -blur_size));
	}

	col = 0.2 * blur_col + 0.8 * diffuse;

	float d = length(p);
	col *= 1.0 - pow(d, 3.0);
	
	// Color correction
	col.r = 1.0 * pow(col.r, 1.7);
	col.g = 1.0 * pow(col.g, 1.2);
	col.b = 1.0 * pow(col.b, 1.4);
	
	col.a = 1.0;
	
	gl_FragColor = col;
}
