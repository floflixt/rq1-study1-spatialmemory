extends Node3D

var not_placed_images: Array[Node]
var image_to_place
var currently_placing : bool = false

signal recall_phase_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# if we are currently placing an image
	if currently_placing:
		# if at the same time both thumbs are up
		if EXPAR.current_right_gesture == "ThumbsUp" and EXPAR.current_left_gesture == "ThumbsUp" and image_to_place.can_confirm:
			# increase the counter by one per frame
			image_to_place.confirm_counter += 1
		else:
			# reset the counter
			image_to_place.confirm_counter = 0
		if image_to_place.placement_confirmed:
			image_to_place.save_location()
			currently_placing = false

func setup() -> void:
	get_tree().call_group("xr", "debug_message", "PRACTICE - RECALL - SETUP")
	var file : FileAccess = FileAccess.open(EXPAR.savefile_images, FileAccess.READ_WRITE)
	# first, assign the correct images to the  originally presented images
	# this is the same code as in the learning phase
	var image_file_name : String
	
		# first, add the new images to the Images Node (so that from there, we can randomly draw
	for new_image in $NewImages.get_children():
		new_image.is_new_image = true
		new_image.reparent($Images)
	
	# now go over all image child nodes and assign them the corresponding image
	for pickable_image_node in $Images.get_children():
		#get_tree().call_group("xr", "debug_message", "LEARNING - " + pickable_image_node.name + ":: " + image_file_name)
		#pickable_image_node.image_texture = image_file_name
		#get_tree().call_group("xr", "debug_message", "...image_texture assigned: " + pickable_image_node.image_texture)
		pickable_image_node.update_texture("TUTORIAL")
		image_file_name = pickable_image_node.image_texture
		
		# also, save the original image locations (not necessary)
		file.seek_end()
		file.store_line(pickable_image_node.name + "," + image_file_name + "," + MY.transf_to_csv(pickable_image_node.transform))
	file.close()
	

	# next, disable all images so that we later can draw single ones
	$Images.visible = false
	$Images.process_mode = Node.PROCESS_MODE_DISABLED
	
	#get_tree().call_group("images", "set_pickupability", true)
	not_placed_images = $Images.get_children()
	not_placed_images.shuffle()

# this is called if the OPENHAND gesture is detected
func present_next_image(hand_transform: Transform3D) -> void:
	# only do the following if the participant is not currently placing another image
	get_tree().call_group("xr", "debug_message", "currently_placing:" + str(currently_placing))
	if not currently_placing:
		# if there are no more images to place
		if $Images.get_child_count() == 0:
			recall_phase_complete.emit()
		currently_placing = true
		# first, we get a random node from those that have not yet been placed
		# the array has already been shuffled, so we just pop
		image_to_place = not_placed_images.pop_back()
		get_tree().call_group("xr", "debug_message", "trying to place image: " + image_to_place.name)
		# enable this one image
		image_to_place.reparent($PlacedImages)
		image_to_place.make_available_for_placing(hand_transform)
		
		
		
