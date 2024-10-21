shader_type canvas_item;

//uniform float sliderx;
//uniform float slidery;
//uniform float num;

void vertex() {
	// Called for every vertex the material is visible on.
	UV = vec2(UV.x, 1.0-UV.y);
}
void fragment() {
//<FRAG_CODE>
}