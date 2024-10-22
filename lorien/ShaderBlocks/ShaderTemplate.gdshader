shader_type canvas_item;

global uniform sampler2D bricks : source_color, repeat_enable;
global uniform sampler2D rug;
global uniform sampler2D tile;
global uniform sampler2D goose;

void vertex() {
	// Called for every vertex the material is visible on.
	// UV = vec2(UV.x, 1.0-UV.y);
}
void fragment() {
//<FRAG_CODE>
}