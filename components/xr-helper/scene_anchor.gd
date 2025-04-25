extends Node3D

## This provides labels for the META scene (e.g., walls, floor, storage, window etc)

@onready var label : Label3D = $Label3D

###############################################################################

func setup_scene(entity: OpenXRFbSpatialEntity) -> void:
	# create label for detected entity
	var semantic_labels: PackedStringArray = entity.get_semantic_labels()
	label.text = ", ".join(Array(semantic_labels).map(func (x): return x.capitalize()))
