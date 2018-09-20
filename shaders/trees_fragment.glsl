varying vec2 vUv;
varying vec4 mvPosition;
varying vec3 vPosition;
varying vec3 vNormal;
uniform float time;
uniform sampler2D roofs_t;

			 
void main() {
	vec4 col = vec4(0.0);
	vec2 uv = vUv;
	vec3 p = vPosition;
	vec2 c = gl_PointCoord - vec2(0.50);
	
    float tree = 0.0;

	c *= 2.0;
	c.y *= -1.0;
	c.y -= 1.0;
		
	c.y -= 0.4;
    tree += 1.0 - length(c) * 10.0 - 0.3 * clamp(cos(c.y* 40.0), -0.8 + cos(c.y * 100.0), 0.7) - c.y * 10.0;
    tree *= 10.0;
    tree = clamp(tree, 0.0, 0.9);
    
    col.r += (0.1 - 0.1 * abs(c.x)) * tree;
    col.g += (0.4 - 0.4 * abs(c.x)) * tree;
    col.b += (0.1 + 0.1 * abs(c.x)) * tree;

	col.a = tree;
	
	gl_FragColor = col;
}
