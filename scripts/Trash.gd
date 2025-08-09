extends Area2D

signal wrong_bag_placed

func _on_area_entered(area):
	
	var sprite = area.get_node("Sprite2D") 
	
	if sprite:
		var texture = sprite.texture
		if texture:
			var texture_path = texture.resource_path
			
			var texture_filename = texture_path.get_file()
			
			var isGarbage = extract_type_from_filename(texture_filename)
			
			if isGarbage:
				area.queue_free()
				
			else:
				print("This Bag is Fine.")
				emit_signal("wrong_bag_placed")
		else:
			print("No texture found on Sprite2D")
	else:
		print("No Sprite2D node found in area")

func extract_type_from_filename(filename: String) -> bool:
	if filename.contains("Tear") or filename.contains("Color") or filename.contains("Wrong"):
		return true 
	else:
		return false 
