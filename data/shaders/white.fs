vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
	vec4 c = Texel(texture, texture_coords);
	if (c.a < 0.1) {
		return vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		return vec4(1.0, 1.0, 1.0, 1.0);
	}
}