extends Node2D
var current_scene = null
var amountOfArrow
var bombAll =  false
var die = false
var settingBullet = false
var reachEnd = false
var playerTurn = true
var enemyTurn = false
var playerPos = Vector2()

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	get_tree().change_scene("res://MapControl.tscn")
	
	
func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)
	
func _deferred_goto_scene(path):
#	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )
	