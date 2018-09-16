uniform float time;
uniform sampler2D tDiffuse, tDepth;
uniform float cameraNear;
uniform float cameraFar;
varying vec2 vUv;

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
	vec4 col = texture2D(tDiffuse, vUv);
	float depth = getDepth(vUv);
	float z = depth * ( cameraNear - cameraFar ) - cameraNear;
	
	vec2 offset = vec2(0.0);

	col.rgb *= cos(z * 4.0);
	
	col.a = texture2D(tDepth, vUv).a;
	
	gl_FragColor = col;
}
