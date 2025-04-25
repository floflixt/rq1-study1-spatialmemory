extends Node3D

var blue_transparent_material : Material = preload("res://components/blue_transparent_material.tres")
var red_transparent_material : Material = preload("res://components/red_transparent_material.tres")
var green_transparent_material : Material = preload("res://components/green_transparent_material.tres")
var blue_correct : bool = false
var red_correct : bool = false
var can_complete_tutorial : bool = false

signal tutorial_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# debug information
	$Origin.text = "TutorialOrigin\n" + MY.transf_to_str(self.global_transform)

	# show the current gestures
	$GestureRecognition/GestureLeft.text = EXPAR.current_left_gesture
	$GestureRecognition/GestureRight.text = EXPAR.current_right_gesture
	
	# continue to next phase
	if blue_correct and red_correct:
		can_complete_tutorial = true
		$GestureRecognition/TutorialComleteButton.visible = true
		$GestureRecognition/TutorialComleteButton.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		can_complete_tutorial = false
		$GestureRecognition/TutorialComleteButton.visible = false
		$GestureRecognition/TutorialComleteButton.process_mode = Node.PROCESS_MODE_DISABLED
		


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "BlueCentreCollision":
		$MoveCubes/BlueGoal.set_surface_override_material(0, green_transparent_material)
		blue_correct = true


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.name == "BlueCentreCollision":
		$MoveCubes/BlueGoal.set_surface_override_material(0, blue_transparent_material)
		blue_correct = false


func _on_timer_tutorial_complete_timeout() -> void:
	tutorial_finished.emit()


func _on_red_goal_area_area_entered(area: Area3D) -> void:
	if area.name == "RedCentreCollision":
		$MoveCubes/RedGoal.set_surface_override_material(0, green_transparent_material)
		red_correct = true


func _on_red_goal_area_area_exited(area: Area3D) -> void:
	if area.name == "RedCentreCollision":
		$MoveCubes/RedGoal.set_surface_override_material(0, red_transparent_material)
		red_correct = false


func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	$GestureRecognition/TutorialComleteButton.visible = false
	$GestureRecognition/TutorialComleteButton.process_mode = Node.PROCESS_MODE_DISABLED
	$TimerTutorialComplete.start()
	get_tree().call_group("xr", "participant_feedback", "Tutorial complete!\n\nPlease wait a moment...", Color.GREEN)
