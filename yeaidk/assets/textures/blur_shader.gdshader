shader_type canvas_item;
uniform float blur_size = 10.0;
uniform bool go = false;

void fragment() {
	if (go || blur_size > 0.0) {
		vec4 sum = vec4(0.0);
		vec2 tex_size = vec2(textureSize(TEXTURE, 0));
		vec2 uv = UV;
		float count = 0.0;
		
		for (float x = -blur_size; x <= blur_size; x++) {
			for (float y = -blur_size; y <= blur_size; y++) {
				vec2 offset = vec2(x, y) / tex_size;
				vec2 sample_uv = clamp(uv + offset, vec2(0.0), vec2(1.0));
				sum += texture(TEXTURE, sample_uv);
				count += 1.0;
			}
		}
		COLOR = sum / count;
	}else{
		COLOR = texture(TEXTURE, UV);
	}
}
void vertex() {
	// Called for every vertex the material is visible on.
}
//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
