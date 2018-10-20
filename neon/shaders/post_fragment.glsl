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
	vec2 original = value;
	value *= 8.3;
	value = vec2(cos(value.x * 3000.0), sin(value.y * 2000.0));
	return original + value * 0.03 * cos(value.x * 100.0 + value.y * 10.0);
}

/*
  Screen Space Ambiant Occlusion
  Except I do the contrary, I give more light to
  closer objects because almost everything emits neon
  in this scene. So it's more like radiosity.
 */
vec4 ssao(){
	// Compare depths
	float offset = 0.01;
	vec4 col = vec4(0.0);
	float depths[4];

	float depth = getDepth(vUv);
	depths[0] = getDepth(noise(vUv + vec2(offset, 0.0)));
	depths[1] = getDepth(noise(vUv + vec2(-offset, 0.0)));
	depths[2] = getDepth(noise(vUv + vec2(0.0, offset)));
	depths[3] = getDepth(noise(vUv + vec2(0.0, offset)));
	
	for(int i = 0; i < 4; i++){
		float diff = depths[i] - depth;
		float adiff = abs(diff);
		float min_threshold = 0.01;
		float max_threshold = 0.4;
		float blend = 0.0;
		if(adiff > min_threshold &&
		   adiff < max_threshold &&
		   depths[i] > depth){
			blend = clamp(adiff/max_threshold, 0.0, 1.0);
		}

		if(adiff < 0.001 && depths[i] < 0.99){
			blend = 1.0 - blend;
			col.r += 0.02 * (blend);
			col.g += 0.01 * (blend);
			col.b += 0.02 * (blend);
		}
	}
	
	return col;
}

void main() {
	vec2 p = vUv - 0.5;
	vec4 diffuse = texture2D(tDiffuse, vUv);
	vec4 col = vec4(0.0);
	float depth = getDepth(vUv);
	float z = cameraFar + ((depth) * ( cameraNear - cameraFar ) - cameraNear);

	vec2 offset = vec2(0.0);
	
	vec4 blur_col = col;
	float blur_size = 0.001;

	diffuse += 0.2 * ssao();
	
	for(int i = 0; i < 3; i++){
		blur_size = blur_size * 1.5;
		blur_col += 0.25 * texture2D(tDiffuse, vUv + vec2(blur_size, 0.0));
		blur_col += 0.25 * texture2D(tDiffuse, vUv + vec2(0.0, blur_size));
		blur_col += 0.25 * texture2D(tDiffuse, vUv + vec2(-blur_size, 0.0));
		blur_col += 0.25 * texture2D(tDiffuse, vUv + vec2(0.0, -blur_size));
	}

	col = diffuse;
	col /= 2.0;

	float d = length(p);
	col *= 1.3 - pow(d, 3.0);

	// Color correction

	col.r = 1.3 * pow(col.r, 0.86);
	col.g = 1.4 * pow(col.g, 0.83);
	col.b = 1.3 * pow(col.b, 0.7);
	
	col.a = 1.0;
	
	gl_FragColor = col;
}
