extends Area3D

###################################################################################################

func setup_scene(spatial_entity: OpenXRFbSpatialEntity) -> void:
	var data: Dictionary = spatial_entity.custom_data
	spatial_entity.save_to_storage(OpenXRFbSpatialEntity.STORAGE_LOCAL)
	pass
