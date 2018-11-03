varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
uniform float time;
uniform sampler2D tex;
uniform sampler2D afft;
uniform vec2 screen_dim;


#define cl01(x) clamp(x, 0.0, 1.0)
#define PI2 6.2832

/*
  UV.x between 0 and 1:
  elevator
  UV.x between 1 and 2:
  train
  UV.x between 2 and 3:
  train track
 */


void main() {
	vec4 col = vec4(0.0);
	vec3 p = vPosition;

	vec2 uv = mod(vUv, vec2(1.0, 1.0));
	
	if(vUv.x < 1.0){
		// Elevator
		col.r = 0.1;
		col.b = 0.2;
		col.g += 0.3 * cos(p.x * 100.0);
		col.a = 1.0;
	} else if(vUv.x < 2.0){
		// Train 
		col.rgb += 0.3;
		// Very lazy way to create windows
		col *= 1.0 - clamp(10.0 * cos(vPosition.z * 10.0 + 0.8), 0.0, 1.0);
		col.r += 0.1 * abs(cos(p.y * 0.4));
		col.b += 0.1 * abs(cos(p.y * 0.6)); 
		col.a = 1.0;
	} else if(vUv.x < 3.0){
		// Train track
		float f = 0.0;
		f = clamp(2.0 * cos(p.y * 1.0 + time * 6.2832), 0.0, 1.0);
		f *= 0.6 + 0.4 * cos(p.y * 0.2);
		col.rgb += f;
		col.a = f;
	} else if (vUv.x < 4.0){
		// Displays (ads, etc)
		col.rgba = texture2D(tex, uv);
	} else if (vUv.x < 5.0){
		// Distant roads and buildings
		col.rgba = texture2D(tex, uv);

		float l = length(vPosition.xz - vec2(0.0, 0.0));
		if(l > 30.0){
			col *= 1.0 - pow((l-30.0)/60.0, 2.0);
		}
		col *= 1.3;
		col *= clamp(cos(time * 2.5 + vPosition.x * 4.0), 0.0, 1.0) * 0.3 + 0.7;
		col *= clamp(cos(time * 2.5 + vPosition.z * 4.0), 0.0, 1.0) * 0.3 + 0.7;
		col.r += 0.02;
	}

	float i = length(texture2D(afft, vec2(0.584375, 0.9394366197183098)));
	
	col.r *= 0.8 + 0.8 * i;
	
	gl_FragColor = col;
}
