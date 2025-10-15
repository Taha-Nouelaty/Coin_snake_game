extends CanvasLayer

signal restart
signal library
signal skinshop

func _on_restart_button_pressed():
	restart.emit()
		# Replace with function body.


func _on_library_pressed() -> void:
	library.emit()


func _on_skin_shop_pressed() -> void:
	skinshop.emit()
