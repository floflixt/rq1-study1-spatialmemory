extends Node3D

signal calibration_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# in debug mode, make the example frame visible and interactable -> to define locations
	if EXPAR.is_debug_mode:
		$Images/ExampleFrame.visible = true
		$Images/ExampleFrame.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		$Images/ExampleFrame.visible = false
		$Images/ExampleFrame.process_mode = Node.PROCESS_MODE_DISABLED
		
		
	# define/move the calibrated origin as follows:
	# it is exactly in the middle of the first two moveable calibration cubes
	$CalibratedOrigin.global_position = ($CalibrationCubeYellow.global_position + $CalibrationCubeOrange.global_position + $CalibrationCubeBlue.global_position) / 3
	# turn it depending on the third calibration cube location -> rotation helper
	# for this, first calculate the rotation helper position in the middle of the cubes
	var rotation_pos : Vector3 = ($CalibrationCubeWhite.global_position + $CalibrationCubeOrange.global_position + $CalibrationCubeBlue.global_position)/3
	# second, put the rotation helper at exactly the same height (Y) as the calibrated origin
	$RotationHelper.global_position = Vector3(rotation_pos.x, $CalibratedOrigin.global_position.y, rotation_pos.z)
	# third, make the origin look at the rotation helper -> the final effect is a rotation of the origin while keeping it upright
	$CalibratedOrigin.look_at($RotationHelper.global_position)
		
		
	EXPAR.calibrated_origin = $CalibratedOrigin.global_transform
	$Images.global_transform = EXPAR.calibrated_origin
	
	var cal_text : String = ""
	cal_text = "GLOBAL_TRANSFORM\n" + MY.transf_to_str($Images/ExampleFrame.global_transform)
	cal_text += "\n\nLOCAL TRANSFORM \n"
	var relative_transform : Transform3D
	relative_transform = $Images/ExampleFrame.transform
	cal_text += MY.transf_to_str(relative_transform)
	
	
	$Images/ExampleFrame/Location.text = cal_text
	
	if EXPAR.current_left_gesture == "Point" and EXPAR.current_right_gesture == "ThumbsUp":
		save_calibration_info()
		calibration_complete.emit()
		
	# set this location relative to the calibrated origin
	#$DemoWhiteboard.global_transform.origin = $Origin.global_transform.origin - Vector3(1.187, 0.753, 0.414)
	 # and rotate the image correctly
	#$DemoWhiteboard.global_transform = $DemoWhiteboard.global_transform.rotated_local(Vector3.UP, )

func save_calibration_info() -> void:
	var calibration_info: Dictionary
	calibration_info = {
		"calibrated_origin_in_global_space": MY.vec_to_csv($CalibratedOrigin.global_position),
		"calibrated_origin_in_calibration_scene": MY.vec_to_csv($CalibratedOrigin.position),
		"orange_cube_relative_to_origin": MY.vec_to_csv($CalibrationCubeOrange.position),
		"yellow_cube_relative_to_origin": MY.vec_to_csv($CalibrationCubeYellow.position),
		"blue_cube_relative_to_origin": MY.vec_to_csv($CalibrationCubeBlue.position),
		"white_cube_relative_to_origin": MY.vec_to_csv($CalibrationCubeWhite.position),
	}
	var file : FileAccess = FileAccess.open(EXPAR.participant_info_file, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_string("\n" + JSON.stringify(calibration_info, "\t"))
	file.close()
	get_tree().call_group("log", "log", "calibration.gd/save_calibration_info()/saved info")
