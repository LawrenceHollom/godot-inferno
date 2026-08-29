extends ColorRect

class_name Fire


func set_intensity(intensity: float) -> void:
	print("Setting fire intensity ", intensity)
	(self.material as ShaderMaterial).set_shader_parameter("intensity", intensity)