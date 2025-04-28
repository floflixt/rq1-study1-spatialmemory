extends CanvasLayer

signal response_new_image
signal response_image_was_present

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_image_was_present_pressed() -> void:
	response_image_was_present.emit()


func _on_image_was_not_present_pressed() -> void:
	response_new_image.emit()
