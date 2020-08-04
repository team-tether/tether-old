shader_type canvas_item;
render_mode unshaded;

uniform vec4 fill_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D fill;

void fragment() {
	vec2 size = vec2(textureSize(TEXTURE, 0));
	vec2 fill_size = vec2(textureSize(fill, 0));
	vec2 pixel = UV * size;
	
	if (texture(TEXTURE, UV) == fill_color) {
		vec2 fill_uv = mod(pixel, fill_size) / fill_size * 2.0;
		COLOR = texture(fill, fill_uv);
	} else {
		COLOR = vec4(0.0);
	}
}