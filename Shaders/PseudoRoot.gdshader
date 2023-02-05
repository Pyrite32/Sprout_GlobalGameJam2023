shader_type canvas_item;

uniform vec4 red_color : hint_color;
uniform float intensity: hint_range(0.0,1.0,0.1);

void fragment()
{
	vec4 color = texture(TEXTURE, UV);
	vec4 finalColor = mix(color, red_color, intensity);
	
	COLOR.rgb = finalColor.rgb;
	COLOR.a = color.a;
}