shader_type canvas_item;

uniform sampler2D overlay_texture : hint_default_white, repeat_enable; // Texture to overlay on non-transparent areas
uniform vec4 overlay_color: source_color; // Optional color tint for the overlay
uniform float overlay_scale = 1.0; // Scale factor to control the texture size
uniform vec2 overlay_velocity = vec2(0.1, 0.1); // Velocity to control scrolling speed

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    if (original.a > 0.0) {
        vec2 scroll_offset = overlay_velocity * TIME;
		float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
        vec2 adjusted_scale = vec2(overlay_scale, overlay_scale * aspect_ratio);
        vec2 scaled_uv = SCREEN_UV * adjusted_scale - scroll_offset;

        vec4 overlay = texture(overlay_texture, fract(scaled_uv));
        COLOR = overlay * overlay_color * original.a;
    } else {
        COLOR = vec4(0.0); // Preserve transparency in transparent areas
    }
}