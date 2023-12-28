@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeVoronoi

func _get_name():
	return "Voronoi"

func _get_category():
	return "MyShaderNodes"

func _get_description():
	return "Voronoi noise pattern (based on work by Inigo Quilez)"

func _init():
	set_input_port_default_value(1, 0.0)

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 2

func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "cellDensity"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR_2D
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 2

func _get_output_port_name(port):
	match port:
		0:
			return "distFromCenter"
		1:
			return "distFromEdge"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return "vec2 randomVector(ivec2 cell)
	{
		/*
		mat2 m;
		m[0] = vec2(15.27, 47.63);
		m[1] = vec2(99.41, 89.98);
		
		vec2 t = fract(cos(vec2(cell) * m) * 46839.32);
		return vec2(sin(t.y + offset) * 0.5 + 0.5, cos(t.x + offset) * 0.5 + 0.5);
		*/
		
		vec2 seed = vec2(cell);
		return fract(sin(vec2(dot(seed, vec2(127.1, 311.7)), dot(seed, vec2(269.5, 183.3)))) * 43758.5453);
	}"
	
func _get_code(input_vars, output_vars, mode, type):
	return "ivec2 cell = ivec2(floor(" + input_vars[0] + " * " + input_vars[1] + "));
	vec2 posInCell = fract(" + input_vars[0] + " * " + input_vars[1] + ");
	
	" + output_vars[0] + " = 8.0f;
	vec2 closestOffset = vec2(8.0, 8.0);
	
	for(int y = -1; y <= 1; ++y)
	{
		for(int x = -1; x <= 1; ++x)
		{
			ivec2 cellToCheck = ivec2(x, y);
			vec2 cellOffset = vec2(cellToCheck) - posInCell + randomVector(cell + cellToCheck);
			
			float distToPoint = dot(cellOffset, cellOffset);
			
			if(distToPoint < " + output_vars[0] + ")
			{
				" + output_vars[0] + " = distToPoint;
				closestOffset = cellOffset;
			}
		}
	}
	
	" + output_vars[1] + " = 8.0f;
	
	for(int y = -1; y <= 1; ++y)
	{
		for(int x = -1; x <= 1; ++x)
		{
			ivec2 cellToCheck = ivec2(x, y);
			vec2 cellOffset = vec2(cellToCheck) - posInCell + randomVector(cell + cellToCheck);
			
			float distToEdge = dot(0.5f * (closestOffset + cellOffset), normalize(cellOffset - closestOffset));
			
			" + output_vars[1] + " = min(" + output_vars[1] + ", distToEdge);
		}
	}"
