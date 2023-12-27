@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSimpleNoise

func _get_name():
	return "Simple Noise"
	
func _get_category():
	return "Custom"
	
func _get_description():
	return "Outputs a basic Perlin noise."
	
func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_input_port_count():
	return 2
	
func _get_output_port_count():
	return 1
	
func _get_input_port_type(port):
	return VisualShaderNode.PORT_TYPE_VECTOR_2D if (port == 0) else VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR
	
func _get_input_port_name(port):
	return "uv" if (port == 0) else "scale"
	
func _get_output_port_name(port):
	return "Noise Value"
	
func _get_global_code(mode):
	return "float noiseRandomValue(vec2 uv)
{
	return fract(sin(dot(uv, vec2(12.9898f, 78.233f))) * 43758.5453f);
}

float noiseInterpolate(float a, float b, float t)
{
	return (1.0f - t) * a + (t * b);
}

float valueNoise(vec2 uv)
{
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	f = f * f * (3.0f - 2.0f * f);
	
	uv = abs(fract(uv) - 0.5f);
	vec2 c0 = i + vec2(0.0f, 0.0);
	vec2 c1 = i + vec2(1.0f, 0.0f);
	vec2 c2 = i + vec2(0.0f, 1.0f);
	vec2 c3 = i + vec2(1.0f, 1.0f);
	
	float r0 = noiseRandomValue(c0);
	float r1 = noiseRandomValue(c1);
	float r2 = noiseRandomValue(c2);
	float r3 = noiseRandomValue(c3);
	
	float bottomOfGrid = noiseInterpolate(r0, r1, f.x);
	float topOfGrid = noiseInterpolate(r2, r3, f.x);
	float t = noiseInterpolate(bottomOfGrid, topOfGrid, f.y);
	return t;
}"
	
func _get_code(input_vars, output_vars, mode, type):
	return "float t = 0.0f;
	
	float freq = pow(2.0f, float(0));
	float amp = pow(0.5f, float(3-0));
	t += valueNoise(vec2(uv.x * scale/freq, uv.y * scale/freq))*amp;
	
	freq = pow(2.0f, float(1));
	amp = pow(0.5f, float(3-1));
	t += valueNoise(vec2(uv.x * scale/freq, uv.y * scale/freq))*amp;
	
	freq = pow(2.0f, float(2));
	amp = pow(0.5f, float(3-2));
	t += valueNoise(vec2(uv.x * scale/freq, uv.y * scale/freq))*amp;
	
	%s = t;" % [output_vars[0]]
