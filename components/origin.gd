extends Marker3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# place origin in the middle of the 4 calibration cubes
	self.global_position.x = ($"../CalibrationCube1".global_position.x + $"../CalibrationCube2".global_position.x + $"../CalibrationCube3".global_position.x) / 3
	self.global_position.y = ($"../CalibrationCube1".global_position.y + $"../CalibrationCube2".global_position.y + $"../CalibrationCube3".global_position.y) / 3
	self.global_position.z = ($"../CalibrationCube1".global_position.z + $"../CalibrationCube2".global_position.z + $"../CalibrationCube3".global_position.z) / 3
	# debug info
	$OriginLabel.text = "CalibratedOrigin\n" + MY.transf_to_str(self.global_transform)

	
	
