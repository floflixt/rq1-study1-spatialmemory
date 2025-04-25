extends CanvasLayer

signal rating_confirmed(ratings: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	

func _on_okay_button_pressed() -> void:
	var beauty_rating: int = $RatingBeauty/HBoxContainer/HSlider.value
	var ai_rating: int = $RatingAI/HBoxContainer/HSlider.value
	var ratings: String
	ratings = str(beauty_rating) + "," + str(ai_rating)
	rating_confirmed.emit(ratings)
