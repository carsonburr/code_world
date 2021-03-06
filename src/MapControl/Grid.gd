extends TileMap

#the size of the tile
var tile_size = get_cell_size()
var half_tile_size = tile_size/2

enum ENTITY_TYPES {PLAYER, ENEMY, BULLET, ARROW}

#the size of the map
var grid_size = Vector2(11, 11)
var grid = []
var positions = []
var randiX
var randiY
var finding = true

#placement of the object on the map
var playerX
var playerY
var arrowX
var arrowY
var bombX
var bombY
var potionX
var potionY
var stairX
var stairY

#other scene that is needed to be used in this project
onready var TDoor = preload("res://src/Door/TopDoor.tscn")
onready var BDoor = preload("res://src/Door/BotDoor.tscn")
onready var LDoor = preload("res://src/Door/LeftDoor.tscn")
onready var RDoor = preload("res://src/Door/RightDoor.tscn")
onready var red = preload("res://src/Enemy/Red.tscn")
onready var Arrow = preload("res://src/Item/Arrow.tscn")
onready var Player = preload("res://src/Player/Player.tscn")
onready var Bomb = preload("res://src/Item/Bomb.tscn")
onready var Map = preload("res://src/MapControl/createMap.tscn")
onready var Health = preload("res://src/UI/Health.tscn")
onready var Item_UI = preload("res://src/UI/Item_UI.tscn")
onready var Stair = preload("res://src/Item/Stair.tscn")
onready var Potion = preload("res://src/Item/Potion.tscn")

var player
var enemy
func _ready():
	# Will create a global map at the start of a 25 room by 25 room grid
	if (global.global_map == null):
		global.create_global_map()
	
	# Moves the location of the character on the global map
	global.move_global_map()
	
	var createmap = Map.instance()

	add_child(createmap)
	
	var hp = Health.instance()
	var item_ui = Item_UI.instance()
	add_child(hp)
	add_child(item_ui)
	
	randomize()
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null)
	set_process(true)
	
	#function to set the items, player, and enemy
	_setPlayer()
	_setItems()
	_setDoors()
	_setEnemies()
	#setBullets()
	
func _setEnemies():
	#get the scene 
	enemy = red.instance()
	#place the node onto the map
	enemy.set_pos(map_to_world(Vector2(5,5)) + half_tile_size)
	#add it as a child to this scene
	add_child(enemy)
	
	var tile = global.room_rep.get_tile(5, 5)
	
	var entity = Entity.new()
	entity.init(enemy.get_path(), tile);
	enemy.set_entity(entity)
		
		
func _setPlayer():
	
	if (global.last_door != null):
		print ("Last door: " + global.last_door)
	
	if global.last_door == null:
		playerX = random()
		playerY = random()
	elif global.last_door.casecmp_to("TopDoor") == 0:
		playerX = 5
		playerY = 9
	elif global.last_door.casecmp_to("BotDoor") == 0:
		playerX = 5
		playerY = 1
	elif global.last_door.casecmp_to("LeftDoor") == 0:
		playerX = 9
		playerY = 5
	elif global.last_door.casecmp_to("RightDoor") == 0:
		playerX = 1
		playerY = 5
	

	player = Player.instance()
	player.set_pos(map_to_world(Vector2(playerX, playerY)) + half_tile_size)
	add_child(player)
	
	var tile = global.room_rep.get_tile(playerX, playerY)
	
	global.player_rep = Entity.new()
	global.player_rep.init(player.get_path(), tile);
	player.set_entity(global.player_rep)
	global.interpreter.set_playerbot(global.player_rep)
	
	var player_pos = Vector2(playerX, playerY)
	positions.append(player_pos)


func _setItems():
	
	while (true):
		random_X_Y()
		arrowX = randiX
		arrowY = randiY
		
		random_X_Y()
		bombX = randiX
		bombY = randiY
		
		random_X_Y()
		potionX = randiX
		potionY = randiY
		
		random_X_Y()
		stairX = randiX
		stairY = randiX
		if (arrowX != bombX != stairX != potionX && arrowY != bombY != stairY != potionY):
			break
	
	var arrow = Arrow.instance()
	arrow.set_pos(map_to_world(Vector2(arrowX,arrowY)) + half_tile_size)
	add_child(arrow)
	
	var bomb = Bomb.instance()
	bomb.set_pos(map_to_world(Vector2(bombX,bombY)) + half_tile_size)
	add_child(bomb)
	
	var potion = Potion.instance()
	potion.set_pos(map_to_world(Vector2(potionX,potionY)) + half_tile_size)
	add_child(potion)

	_setStairs()


func _setStairs():
	if (global.room_counter > 3 + global.score):
		randomize()
		var c = randi() % (3 + global.score + 1)
		print (c)
		if (c == 1):
			var stair = Stair.instance()
			stair.set_pos(map_to_world(Vector2(random(),random())) + half_tile_size)
			add_child(stair)
	pass

func _setDoors():
	###LEFT door
	var doorL = LDoor.instance()
	doorL.set_pos(map_to_world(Vector2(0,5)) + half_tile_size)
	add_child(doorL)
	###TOP door
	var doorT = TDoor.instance()
	doorT.set_pos(map_to_world(Vector2(5,0)) + half_tile_size)
	add_child(doorT)
	###BOTTOM door
	var doorB = BDoor.instance()
	doorB.set_pos(map_to_world(Vector2(5,10)) + half_tile_size)
	add_child(doorB)
	###RIGHT door
	var doorR = RDoor.instance()
	doorR.set_pos(map_to_world(Vector2(10,5)) + half_tile_size)
	add_child(doorR)

#random for placement of the items
func random():
	return (randi() % 9)+1
	
#random for X and Y
func random_X_Y():
	randiX = random()
	randiY = random()
	pass

func can_move_ent(ent, direction):
	return ent.move_tile_relative(direction.x, direction.y)

#function to check if the space is open to move
func is_cell_vacant(pos, direction):
	var grid_pos = world_to_map(pos) + direction
	
	#not over the length or width of the map
	if grid_pos.x < grid_size.x and grid_pos.x >= 0:
		if grid_pos.y < grid_size.y and grid_pos.y >= 0:
			return true if grid[grid_pos.x][grid_pos.y] == null else false
	return false
	
#movement for player and enemy
func update_child_pos(child_node):
	
	#get the character current location then erase it
	var grid_pos = world_to_map(child_node.get_pos())
	grid[grid_pos.x][grid_pos.y] = null
	
	#create the new location
	var new_grid_pos = grid_pos + child_node.direction
	grid[new_grid_pos.x][new_grid_pos.y] = child_node.type
	
	#make the new location on the map
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	return target_pos
	pass
	

func update_bullet_pos(child_node):
	var grid_pos = world_to_map(child_node.get_pos())
	grid[grid_pos.x][grid_pos.y] = null
	var new_grid_pos = grid_pos + child_node.direction
	grid[new_grid_pos.x][new_grid_pos.y] = child_node.type
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	if new_grid_pos.x == 10 or new_grid_pos.y == 10:
		grid[new_grid_pos.x][new_grid_pos.y] = null
		setBullets()
		global.reachEnd = true
	return target_pos
	pass

#Control the turn between enemy and player
func _process(delta):
	if global.playerTurn:
		player.set_process(true)
	else:
		player.set_process(false)
	if global.enemyTurn:
		enemy.set_process(true)
	else:
		enemy.set_process(false)

