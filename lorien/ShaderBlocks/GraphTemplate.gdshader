shader_type canvas_item;

global uniform sampler2D perlin : source_color, repeat_enable;
global uniform sampler2D voronoi : source_color, repeat_enable;
global uniform sampler2D cobweb : source_color, repeat_enable;
global uniform sampler2D electric : source_color, repeat_enable;

global uniform sampler2D gradient : source_color;

global uniform sampler2D bricks : source_color, repeat_enable;
global uniform sampler2D rug : source_color, repeat_enable;
global uniform sampler2D tile : source_color, repeat_enable;
global uniform sampler2D goose : source_color, repeat_enable;

global uniform float slider1;
global uniform float slider2;
global uniform float slider3;

vec4 GetGraph(float x, float nx)
{
	float f1 = -10.0;
	float f2 = -10.0;
	float f3 = -10.0;
	float f4 = -10.0;
	
	//<FRAG_CODE>
	
	return vec4(f1, f2, f3, f4);
}

void fragment() {
	float fy = dFdy(UV.y) * 1.0; // UV size of pixel on Y axis
	float fx = dFdx(UV.x) * 1.0; // UV size of pixel on X axis
	
	float ratio = fy / fx;
	
	const float _height = 4.0; // range of the graph vertically
	const float _halfheight = _height * 0.5;
	
	float x1 = UV.x * _height * ratio;
	float x2 = (UV.x + fx) * _height * ratio;
	float y1 = UV.y * -_height + _halfheight;
	float y2 = (UV.y+fy) * -_height + _halfheight;
	
	vec4 func1 = GetGraph(x1, UV.x);
	vec4 func2 = GetGraph(x2, UV.x + fx);
	
	vec4 step1 = step(vec4(y1), func1);
	vec4 step2 = step(vec4(y2), func1);
	vec4 step3 = step(vec4(y1), func2);
	vec4 step4 = step(vec4(y2), func2);
	
	// will be 1 if the line passes between out four sample points, otherwise 0
	vec4 line = clamp(mod(abs(step1) + abs(step2) + abs(step3) + abs(step4), 4.0), 0.0,1.0);
	
	const vec4 background = vec4 (0.08, 0.08, 0.08, 1.0);
	const vec4 fore1 = vec4(0.22,0.22,0.22,1.0);
	const vec4 fore2 = vec4(0.12,0.12,0.12,1.0);
	
	COLOR = background;
	COLOR = mix(COLOR,fore2,step(fract(y1*4.0), fract(y2 *4.0)));
	COLOR = mix(COLOR,fore2,step(fract(x2*4.0), fract(x1*4.0)));
	COLOR = mix(COLOR,fore1,step(fract(y1), fract(y2)));
	COLOR = mix(COLOR,fore1,step(fract(x2), fract(x1)));
	
	vec4 c1 = vec4(1.0,0.5,0.5,1.0);
	vec4 c2 = vec4(0.5,1.0,0.5,1.0);
	vec4 c3 = vec4(0.5,0.5,1.0,1.0);
	vec4 c4 = vec4(1.0,1.0,0.5,1.0);
	
	COLOR = mix(COLOR, c1, line.x);
	COLOR = mix(COLOR, c2, line.y);
	COLOR = mix(COLOR, c3, line.z);
	COLOR = mix(COLOR, c4, line.w);
}