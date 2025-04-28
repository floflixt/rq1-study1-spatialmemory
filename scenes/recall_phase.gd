extends Node3D

var not_placed_images: Array[Node]
var image_to_place
var currently_placing : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup() -> void:
	get_tree().call_group("xr", "debug_message", "RECALL - SETUP")
	
	# first, assign the correct images to the  originally presented images
	# this is the same code as in the learning phase
	var image_file_name : String
	# now go over all image child nodes and assign them the corresponding image
	for pickable_image_node in $Images.get_children():
		image_file_name = EXPAR.images_array.pop_back().replace(".import", "")
		#get_tree().call_group("xr", "debug_message", "LEARNING - " + pickable_image_node.name + ":: " + image_file_name)
		pickable_image_node.image_texture = image_file_name
		#get_tree().call_group("xr", "debug_message", "...image_texture assigned: " + pickable_image_node.image_texture)
		pickable_image_node.update_texture("LEARNING")
	
	# first, add the new images to the Images Node (so that from there, we can randomly draw
	for new_image in $NewImages.get_children():
		new_image.is_new_image = true
		new_image.reparent($Images)
	# next, disable all images so that we later can draw single ones
	$Images.visible = false
	$Images.process_mode = Node.PROCESS_MODE_DISABLED
	
	#get_tree().call_group("images", "set_pickupability", true)
	not_placed_images = $Images.get_children()
	not_placed_images.shuffle()

# this is calles if the OPENHAND gesture is detected
func present_next_image(hand_transform: Transform3D) -> void:
	# only do the following if the participant is not currently placing another image
	get_tree().call_group("xr", "debug_message", "currently_placing:" + str(currently_placing))
	if not currently_placing:
		currently_placing = true
		# first, we get a random node from those that have not yet been placed
		# the array has already been shuffled, so we just pop
		image_to_place = not_placed_images.pop_back()
		get_tree().call_group("xr", "debug_message", "trying to place image: " + image_to_place.name)
		# enable this one image
		image_to_place.reparent($PlacedImages)
		image_to_place.make_available_for_placing(hand_transform)
		
		
