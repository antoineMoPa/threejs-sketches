uniform float time;
uniform sampler2D tDiffuse, tRender, tDepth;
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
	// Low frequency noise
	vec2 original = value;
	float f = 3.0;
	value = vec2(cos(value.x * f), sin(value.y * f));
	return original + value * 0.003 * cos(value.x * f + value.y * f);
}


void main() {
	vec2 p = vUv - 0.5;
	vec4 diffuse = texture2D(tRender, vUv);

	/* First pass
	   r: radiosity
	   g:
	   b:
	   a:
	*/
	vec4 last = texture2D(tDiffuse, vUv); 
	
	
	vec4 col = vec4(0.0);
	float depth = getDepth(vUv);
	float z = cameraFar + ((depth) * ( cameraNear - cameraFar ) - cameraNear);

	vec2 offset = vec2(0.0);
	
	vec4 blur_col = vec4(0.0);
	float blur_size = 0.004;
	
	// Blur radiosity pass noise a bit
	blur_col += texture2D(tDiffuse, noise(vUv + vec2(blur_size, 0.0)));
	blur_col += texture2D(tDiffuse, noise(vUv + vec2(0.0, blur_size)));
	blur_col += texture2D(tDiffuse, noise(vUv + vec2(-blur_size, 0.0)));
	blur_col += texture2D(tDiffuse, noise(vUv + vec2(0.0, -blur_size)));
	blur_col /= 4.0;

	col = diffuse;

	/*
	  Create blueish-red radiosity using radiosity pass
	 */
	col.r += blur_col.r * 0.03;
	col.b += blur_col.r * 0.03;

	col /= 1.0;

	// Vignette
	float d = length(p);
	col.r *= 1.1 - clamp(2.1 * pow(d, 2.0), 0.0, 1.0);
	col.g *= 1.1 - clamp(6.2 * pow(d, 4.), 0.0, 1.0);
	col.b *= 1.1 - clamp(10.3 * pow(d, 8.0), 0.0, 1.0);
	
	// Color correction
	
	col.r = 1.3 * pow(col.r, 0.86);
	col.g = 1.4 * pow(col.g, 0.83);
	col.b = 1.3 * pow(col.b, 0.7);
	
	col.a = 1.0;
	
	gl_FragColor = col;
}
