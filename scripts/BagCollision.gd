extends Area2D

@export var sides: int 
var placed_pieces = [] 

signal wrong_piece_placed

func _on_area_entered(area: Area2D):
	if "Piece" in area.name:
		print("The area name contains 'Piece'")
		disable_piece_drag(area)
		var sprite = area.get_node("Sprite2D")
		
		if sprite:
			var texture = sprite.texture
			if texture:
				var texture_path = texture.resource_path
				
				var texture_filename = texture_path.get_file()
				
				var sides_count = extract_sides_from_filename(texture_filename)
				
				if sides_count == sides:
					print("sides matches: ", sides)
					GlobalPackingManager.add_piece()
					
					placed_pieces.append(area)
				else:
					print("sides does not match.")
					emit_signal("wrong_piece_placed")
			else:
				print("no texture found on Sprite2D")
		else:
			print("no Sprite2D node found in area")

func extract_sides_from_filename(filename: String) -> int:
	var sides_count = 0
	if filename.begins_with("3piece"):
		sides_count = 3
	elif filename.begins_with("4piece"):
		sides_count = 4
	elif filename.begins_with("5piece"):
		sides_count = 5
	elif filename.begins_with("6piece"):
		sides_count = 6

	return sides_count

func disable_piece_drag(piece: Area2D):
	if piece:
		piece.set("can_drag", false)
		piece.set("dragging", false)
