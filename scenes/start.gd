extends Node3D


signal experiment_setup_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# keep the location of the calibration cube accesible
	EXPAR.calibrated_experimenter = $CalibrationCube.global_transform
	
	# show some mainly debug info
	$WorldOrigin/OriginCoordinates.text = MY.transf_to_str(self.global_transform)
	$CalibrationCube/CalibrationCubeCoordinates.text = MY.transf_to_str(EXPAR.calibrated_experimenter)
	
	# enable ranged pickup (for so that initial calibration cube can be reached)
	get_tree().call_group("xr", "enable_ranged")


func _on_experiment_setup_experiment_started() -> void:
	# we do not need the ranged grabbing anymore
	get_tree().call_group("xr", "disable_ranged")
	# here we can first do other preparations, then send this signal to continue
	experiment_setup_finished.emit()
