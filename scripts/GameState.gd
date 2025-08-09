extends Node

var current_station = 3

var difficulty = 1

var expansionPoints = 3
var pointsNeeded = 50
var scaleVar = 0
var scaleMax = 1.4

func get_station():
	return current_station

func next_station():
	current_station += 1
	
func station1():
	current_station = 0
	
func batch_completed():
	var newPoints = 10
	newPoints -= (1 * ((5 - Stars.stars) * 4))
	newPoints = max(newPoints, 1)
	
	expansionPoints += newPoints
	print("set expanpoints to: " + str(expansionPoints))
	Stars.reset_stars()
	
func calculate_expansion_points():
	scaleVar = min(float(expansionPoints / (scaleMax * pointsNeeded)), 0.7)
	print("set scaleVar to: " + str(scaleVar) + " expansionPoints = " + str(expansionPoints) + " divided by = " + str((scaleMax * pointsNeeded)))
	return scaleVar

func updateDifficulty():
	if expansionPoints > 40:
		difficulty = 5
	elif expansionPoints > 30:
		difficulty = 4
	elif expansionPoints > 20:
		difficulty = 3
	elif expansionPoints > 10:
		difficulty = 2
	else:
		difficulty = 1
