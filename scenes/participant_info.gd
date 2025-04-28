extends Node3D

signal participant_info_collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# this is called when the participant confirms their code by pressing the button
func _on_participant_id_2_valid_sgic_entered() -> void:
	# using the sgic hash to randomize means that we get the same result and don't need to
	# read any save files
	# first, we use the now saved sgic to randomize
	if !EXPAR.is_debug_mode:
		# set seed based on sgic string
		EXPAR.rng_seed = EXPAR.sgic.hash()
	# set the seed
	seed(EXPAR.rng_seed)
	# shuffle the list of images for a new random order
	EXPAR.images_array.shuffle()
	
	match EXPAR.current_expversion:
		EXPAR.ExpVersion.LEARNING:
			# first session
			# let's create some save files for the rest of the experiment
			if EXPAR.create_save_files("LEARN"):
				# tell the scene manager to continue
				participant_info_collected.emit()
		EXPAR.ExpVersion.RECALL:
			# second session
			if EXPAR.create_save_files("RECALL"):
				participant_info_collected.emit()
