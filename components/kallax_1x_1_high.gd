extends RigidBody3D

###################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.global_position.x = ($"../Kallax_1x1_high2".global_position.x + $"../Kallax_1x1_high3".global_position.x + $"../Kallax_1x1_high4".global_position.x)/3
	self.global_position.y = ($"../Kallax_1x1_high2".global_position.y + $"../Kallax_1x1_high3".global_position.y + $"../Kallax_1x1_high4".global_position.y)/3
	self.global_position.z = ($"../Kallax_1x1_high2".global_position.z + $"../Kallax_1x1_high3".global_position.z + $"../Kallax_1x1_high4".global_position.z)/3
