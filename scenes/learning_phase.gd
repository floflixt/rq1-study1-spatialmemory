extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
		file.store_line(pickable_image_node.name + "," + image_file_name + "," + MY.transf_to_csv(pickable_image_node.transform))
		#file.seek_end()
		#file.store_line("GLOBAL_" + pickable_image_node.name + "," + image_file_name + "," + MY.transf_to_csv(pickable_image_node.global_transform))
	file.close()
	get_tree().call_group("xr", "debug_message", "LEARNING - ImageLocations file created!")
	
	# start experiment timer
	$Timer.start()
	
	
## this function is only intended to be run once after all ratings are collected
func save_final_ratings() -> void:
	# go through all images and save their current ratings
	for image_node in $Images.get_children():
		# pass empty string so that the current stat will be used to save
		image_node.save_final_ratings()

# if the timer for the experiment has run out
func _on_timer_timeout() -> void:
	get_tree().call_group("xr", "participant_feedback", "Task Done!", Color.GREEN)
	# save all current ratings
	save_final_ratings()
