extends Node3D

var learning_tutorial_complete : bool
var button_clicked : bool = false

signal all_ratings_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#this mesh follows the hmd on the floor
	var new_transf: Transform3D = EXPAR.camera_transform
	new_transf.origin.y = 0
	#new_transf.basis.y = Vector3(0, 1, 0)
	#$FollowHMD.global_transform.origin = new_transf.origin
	
	# show the current gestures
	$GestureRecognition/GestureLeft.text = EXPAR.current_left_gesture
	$GestureRecognition/GestureRight.text = EXPAR.current_right_gesture
	
	# if ratings have been given for all 5 images, allow to continue to actual experiment
	learning_tutorial_complete = $Images/PickableImageFrame1.rating_complete and $Images/PickableImageFrame2.rating_complete and $Images/PickableImageFrame4.rating_complete
	
	if learning_tutorial_complete:
		$GestureRecognition/TutorialComleteButton.visible = true
		$GestureRecognition/TutorialComleteButton.process_mode = Node.PROCESS_MODE_INHERIT
	

func setup() -> void:
	var file : FileAccess = FileAccess.open(EXPAR.savefile_images, FileAccess.READ_WRITE)
	var image_file_name : String
	# now go over all image child nodes and assign them the corresponding image
	for pickable_image_node in $Images.get_children():
		#image_file_name = EXPAR.images_array.pop_back().replace(".import", "")
		#get_tree().call_group("xr", "debug_message", pickable_image_node.name + ":: " + image_file_name)
		#pickable_image_node.image_texture = image_file_name
		pickable_image_node.update_texture("TUTORIAL")
		image_file_name = pickable_image_node.image_texture
		# save the frame transforms as well as the assigned images
		file.seek_end()
		file.store_line(pickable_image_node.name + "," + image_file_name + "," + MY.transf_to_csv(pickable_image_node.transform) + "," + MY.vec_to_csv(pickable_image_node.rotation_degrees) + ",practiceLearning")
		#file.seek_end()
		#file.store_line("GLOBAL_" + pickable_image_node.name + "," + image_file_name + "," + MY.transf_to_csv(pickable_image_node.global_transform))
	file.close()
	#get_tree().call_group("xr", "debug_message", "ImageLocations file created!")

	$Images.global_transform = EXPAR.calibrated_origin
	#if not FileAccess.file_exists(EXPAR.documents_path + "test_practice_locations1.txt"):
		#var file : FileAccess = FileAccess.open(EXPAR.documents_path + "test_practice_locations1.txt", FileAccess.WRITE)
		#for image in $Images.get_children():
			#file.store_string(image.name + "," + MY.transf_to_csv(image.global_transform))
		#file.close()

## this function is only intended to be run once after all ratings are collected
func save_final_ratings() -> void:
	# go through all images and save their current ratings
	for image_node in $Images.get_children():
		# pass empty string so that the current stat will be used to save
		image_node.save_final_ratings()


func _on_interactable_area_button_button_pressed(button: Variant) -> void:
	if not button_clicked:
		$GestureRecognition/TutorialComleteButton.visible = false
		$GestureRecognition/TutorialComleteButton.process_mode = Node.PROCESS_MODE_DISABLED
		$GestureRecognition/TutorialComleteButton/InteractableAreaButton.monitoring = false
		$GestureRecognition/TutorialComleteButton/InteractableAreaButton.monitorable = false
		get_tree().call_group("log", "log", "task_practice_learning.gd/_on_interactable_area_button_pressed()/button pressed")
		all_ratings_complete.emit()
		button_clicked = true
