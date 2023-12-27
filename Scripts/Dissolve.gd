extends CSGSphere3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	(material as ShaderMaterial).set_shader_parameter("Dissolve_Amount", sin(float(Time.get_ticks_msec()) / 1000 * 0.5))
