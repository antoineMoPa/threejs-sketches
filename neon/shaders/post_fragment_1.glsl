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

vec2 noise(vec2 value){
	float f = 100.0;
	float f2 = 1000.0;
	vec2 original = value;
	//value = vec2(cos(value.x * f), sin(value.y * f));
	return original + value * 0.03 * cos(value.x * f2 + value.y * f2);
}

/*
  Screen Space Ambiant Occlusion
  Except I do the contrary, I give more light to
  closer objects because almost everything emits neon
  in this scene. So it's more like radiosity.
 */
float radio(){
	// Compare depths
	float offset = 0.01;
	float depths[4];
	float blend = 0.0;

	float depth = getDepth(vUv);
	depths[0] = getDepth(noise(vUv + vec2(offset, 0.0)));
	depths[1] = getDepth(noise(vUv + vec2(-offset, 0.0)));
	depths[2] = getDepth(noise(vUv + vec2(0.0, offset)));
	depths[3] = getDepth(noise(vUv + vec2(0.0, offset)));
	
	for(int i = 0; i < 4; i++){
		float diff = depths[i] - depth;
		float adiff = abs(diff);
		float min_threshold = 0.0001;
		float max_threshold = 0.2;

		if(adiff > min_threshold &&
		   adiff < max_threshold &&
		   depths[i] > depth){
			blend += adiff/max_threshold, 0.0, 1.0;
		}

	}
	
	blend = 1.0 - 3000.0 * blend;
	return blend;
}

void main() {
	vec2 p = vUv - 0.5;
	vec4 diffuse = texture2D(tDiffuse, vUv);
	vec4 col = vec4(0.0);
	float depth = getDepth(vUv);
	float z = cameraFar + ((depth) * ( cameraNear - cameraFar ) - cameraNear);
	
	vec2 offset = vec2(0.0);
	
	col.r = radio();
	col.a = 1.0;
	
	float d = length(p);

	gl_FragColor = col;
}
