extends Node3D

@export var can_finish_learning_phase : bool = false
@export var finish_learning_counter : int = 0

signal learning_phase_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if EXPAR.current_right_gesture == "ThumbsUp" and EXPAR.current_left_gesture == "ThumbsUp" and can_finish_learning_phase:
		# increase the counter by one per frame
		finish_learning_counter += 1
	else:
		# reset the counter
		finish_learning_counter = 0
	if finish_learning_counter > 300:
		save_final_ratings()
		learning_phase_finished.emit()


func setup() -> void:
	get_tree().call_group("xr", "debug_message", "LEARNING - SETUP")
	var file : FileAccess = FileAccess.open(EXPAR.savefile_images, FileAccess.READ_WRITE)
	var image_file_name : String
	# now go over all image child nodes and assign them the corresponding image
	for pickable_image_node in $Images.get_children():
		image_file_name = EXPAR.images_array.pop_back().replace(".import", "")
		#get_tree().call_group("xr", "debug_message", "LEARNING - " + pickable_image_node.name + ":: " + image_file_name)
		pickable_image_node.image_texture = image_file_name
		#get_tree().call_group("xr", "debug_message", "...image_texture assigned: " + pickable_image_node.image_texture)
		pickable_image_node.update_texture("LEARNING")
		#get_tree().call_group("xr", "debug_message", "...texture updated")
		 #save the frame transforms as well as the assigned images
		file.seek_end()
		file.store_line(pickable_image_node.name + "," + image_file_name + "," + MY.transf_to_csv(pickable_image_node.transform) + "," + MY.vec_to_csv(pickable_image_node.rotation_degrees) + ",learning")
		#file.seek_end()
		#file.store_line("GLOBAL_" + pickable_image_node.name + "," + image_file_name + "," + MY.transf_to_csv(pickable_image_node.global_transform))
	file.close()
	get_tree().call_group("xr", "debug_message", "LEARNING - ImageLocations file created!")
	
	# start experiment timers
	$Timer10m.start()
	$Timer20m.start()
	
	
## this function is only intended to be run once after all ratings are collected
func save_final_ratings() -> void:
	# go through all images and save their current ratings
	for image_node in $Images.get_children():
		# pass empty string so that the current stat will be used to save
		image_node.save_final_ratings()

# if the timer for the experiment has run out
func _on_timer_20m_timeout() -> void:
	get_tree().call_group("xr", "participant_feedback", "WARNING_20_MINUTES", Color.GREEN)
	# save all current ratings
	save_final_ratings()
	can_finish_learning_phase = true

func _on_timer_10m_timeout() -> void:
	get_tree().call_group("xr", "participant_feedback", "WARNING_10_MINUTES", Color.GREEN_YELLOW)
