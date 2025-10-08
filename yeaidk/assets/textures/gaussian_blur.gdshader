// gaussian_blur.gdshader
// Use this shader on TWO ColorRects, set direction differently on each
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount = 2.0;
uniform vec2 direction = vec2(1.0, 0.0); // (1,0) for horizontal, (0,1) for vertical
uniform bool go = false;
const float weights[5] = float[](0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

void fragment() {
    if (!go || blur_amount <= 0.0) {
        COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
    }else{
	    vec2 tex_offset = (blur_amount * direction) / vec2(textureSize(SCREEN_TEXTURE, 0));
	    vec3 result = texture(SCREEN_TEXTURE, SCREEN_UV).rgb * weights[0];
	    
	    for(int i = 1; i < 5; i++) {
	        result += texture(SCREEN_TEXTURE, SCREEN_UV + tex_offset * float(i)).rgb * weights[i];
	        result += texture(SCREEN_TEXTURE, SCREEN_UV - tex_offset * float(i)).rgb * weights[i];
	    }
	    
	    COLOR = vec4(result, 1.0);
	}
}