extends LineEdit

export var server_id : String

func _on_LineEdit_focus_entered():
	if (text == "Server ID"):
		#hardcoded for now
		text = server_id
