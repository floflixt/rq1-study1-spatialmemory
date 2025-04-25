extends XRToolsPickable

###################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# reset rotation to upright (smooth)
func _on_released(pickable: Variant, by: Variant) -> void:
	var curr_rotation_vector = self.get_global_rotation()
	var tween = get_tree().create_tween()
	
	# set the vertical rotation to 0
	curr_rotation_vector.x = 0
	curr_rotation_vector.z = 0
	
	# reset rotation by animating
	tween.tween_property(self, "global_rotation", curr_rotation_vector, 0.3)
	
