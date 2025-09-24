shader_type canvas_item;

uniform vec4 color_start : source_color = vec4(1.0);
uniform vec4 color_end : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform bool vertical;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dir = vertical?UV.y:UV.x;
    COLOR = mix(color_start, color_end, dir);
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
