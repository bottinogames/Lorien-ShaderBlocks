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

void vertex() {
	// Called for every vertex the material is visible on.
	// UV = vec2(UV.x, 1.0-UV.y);
}
void fragment() {
//<FRAG_CODE>
}