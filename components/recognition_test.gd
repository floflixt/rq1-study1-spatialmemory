extends CanvasLayer

signal response(response_string : String, continue_placing: bool)

@export var image_was_present : bool = false
@export var response_correct : bool
@export var response_given : bool = false

@export var response_string: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if response_given:
		if response_correct:
			$VBoxContainer/RecognitionFeedback.text = "CORRECT"
			$VBoxContainer/RecognitionFeedback.add_theme_color_override("font_color", Color.GREEN)
		else:
			$VBoxContainer/RecognitionFeedback.text = "INCORRECT"
			$VBoxContainer/RecognitionFeedback.add_theme_color_override("font_color", Color.RED)
			
			


func _on_image_was_present_pressed() -> void:
	# response: was present
	# so correct response for image_was_present == true
	response_correct = image_was_present
	response_given = true
	response_string = "was_present" + "," + str(Time.get_ticks_msec())
	$Timer.start()
	$VBoxContainer/HBoxContainer/ImageWasPresent.disabled = true
	$VBoxContainer/HBoxContainer/ImageWasNotPresent.disabled = true

func _on_image_was_not_present_pressed() -> void:
	response_correct = not image_was_present
	response_given = true
	response_string = "was_not_present" + "," + str(Time.get_ticks_msec())
	$Timer.start()
	$VBoxContainer/HBoxContainer/ImageWasPresent.disabled = true
	$VBoxContainer/HBoxContainer/ImageWasNotPresent.disabled = true

func _on_timer_timeout() -> void:
	response.emit(response_string, image_was_present)
