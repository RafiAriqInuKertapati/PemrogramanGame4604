extends Node2D

class_name LevelBase

@onready var label = $HUD/Label
@onready var player: Player = $Player
@onready var spawn_point := $SpawnPoint

signal score_changed

var item_scene := load("res://items/item.tscn")

var door_scene := load("res://items/door.tscn")

var score := 0: set = set_score

func set_score(value: int) -> void:
	score = value
	score_changed.emit(score) 

func _ready() -> void:
	$Items.hide()
	player.reset(spawn_point.position)
	set_camera_limits()
	spawn_items()
	create_ladders()

	
func set_camera_limits() -> void:
	var map_size = $World.get_used_rect()
	var cell_size = $World.tile_set.tile_size
	$Player/Camera2D.limit_left = (map_size.position.x - 5) * cell_size.x
	$Player/Camera2D.limit_right = (map_size.end.x + 5) * cell_size.x
	
func spawn_items() -> void:
	var item_cells = $Items.get_used_cells(0)
	for cell in item_cells:
		var data = $Items.get_cell_tile_data(0, cell)
		var type = data.get_custom_data("type")
		if type == "door":
			var door = door_scene.instantiate()
			add_child(door)
			door.position = $Items.map_to_local(cell)
			door.body_entered.connect(self._on_door_entered)
		else:
			var item_type := Item.ItemType.CHERRY if type == "cherry" else Item.ItemType.GEM
			var item = item_scene.instantiate()
			add_child(item)
			item.init(item_type, $Items.map_to_local(cell))
			item.picked_up.connect(self._on_item_picked_up)
	
func create_ladders() -> void:
	var cells = $World.get_used_cells(0)
	for cell in cells:
		var data = $World.get_cell_tile_data(0, cell)
		if data.get_custom_data("special") == "ladder":
			var c := CollisionShape2D.new()
			$Ladders.add_child(c)
			c.position = $World.map_to_local(cell)
			var s := RectangleShape2D.new()
			s.size = Vector2(8, 16)
			c.shape = s
	
func _on_item_picked_up(item_type: Item.ItemType) -> void:
	$PickupSound.play()
	if item_type == Item.ItemType.CHERRY:
		score += 2
	elif item_type == Item.ItemType.GEM:
		score += 4



func _on_door_entered(body: PhysicsBody2D) -> void:
	GameState.next_level()

func _on_player_died() -> void:
	GameState.restart()

func _on_ladders_body_entered(body: Node2D) -> void:
	(body as Player).is_on_ladder = true

func _on_ladders_body_exited(body: Node2D) -> void:
	(body as Player).is_on_ladder = false
