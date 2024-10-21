shader_type canvas_item;

uniform float glow : hint_range(0.0, 1.0);
uniform float transparency : hint_range(0.0, 1.0);  
uniform sampler2D gradient : repeat_enable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 offset = vec2(5.0, (TIME * 0.01));
	vec2 screen = SCREEN_UV * vec2(4.0,1.0);
	vec2 sampleUV = ((screen + offset) * 1.4);
	float s = sin(2.2);
	float c = cos(2.2);
	for (int oct = 5; oct >= 0; oct--)
	{
		sampleUV = vec2(sampleUV.x * s + sampleUV.y * s, sampleUV.x * s + sampleUV.y * c);
		sampleUV.x = sampleUV.x + sin(sampleUV.y * (1.0+(float(oct) * 0.7))  );
	}
	sampleUV = sampleUV + fract(TIME * 0.02);
	vec3 sample = texture(gradient, sampleUV).rgb;
	
	vec4 glow_color = mix(vec4(UV.x, UV.y, 0.5, 1.0), vec4(1.0,1.0,1.0,1.0), glow);
	
	COLOR = vec4(sample, 1.0 - transparency) * COLOR * glow_color;
}