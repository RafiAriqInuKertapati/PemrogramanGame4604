extends CharacterBody2D

class_name Enemy

@export var speed := 50.0
@export var gravity := 900.0
@export var jump_force := 400.0
@export var jump_interval := 2.0  # Interval lompat dalam detik

@export var color_change_interval := 3.0  # Interval perubahan warna dalam detik
@export var speed_change_interval := 5.0  # Interval perubahan kecepatan dalam detik
@export var chase_distance := 200.0  # Jarak untuk mulai mengejar pemain
@export var airborne_chase_speed := 100.0  # Kecepatan mengejar di udara

@export var colors := [
	Color(1, 0, 0, 1),    # Merah
	Color(0, 1, 0, 1),    # Hijau
	Color(0, 0, 1, 1),    # Biru
	Color(1, 1, 0, 1),    # Kuning
	Color(0, 1, 1, 1),	  # Cyan
]

var time_since_last_color_change := 0.0
var time_since_last_speed_change := 0.0

var facing := 1
var time_since_last_jump := 0.0

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	# Logika untuk mengejar pemain
	var player := get_node_or_null("../Player")
	if player:
		var distance_to_player := global_position.distance_to(player.global_position)
		if distance_to_player <= chase_distance:
			if player.global_position.x < global_position.x:
				facing = -1
			else:
				facing = 1
			
			# Mengejar pemain di udara jika pemain sedang terbang
			if player.get("is_flying"):
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * airborne_chase_speed
			else:
				velocity.x = facing * speed
		else:
			velocity.x = facing * speed
	else:
		velocity.x = facing * speed
	
	$Sprite2D.flip_h = velocity.x > 0

	# Logika untuk melompat
	time_since_last_jump += delta
	if time_since_last_jump >= jump_interval and is_on_floor():
		velocity.y = -jump_force
		time_since_last_jump = 0.0

	# Logika untuk mengubah warna
	time_since_last_color_change += delta
	if time_since_last_color_change >= color_change_interval:
		change_color()
		time_since_last_color_change = 0.0

	# Logika untuk mengubah kecepatan
	time_since_last_speed_change += delta
	if time_since_last_speed_change >= speed_change_interval:
		change_speed()
		time_since_last_speed_change = 0.0

	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision.get_collider().name == "Player":
			collision.get_collider().hurt()
		if collision.get_normal().x != 0:
			facing = sign(collision.get_normal().x)
			velocity.y = -100

	if position.y > 10000:
		queue_free()

func change_color() -> void:
	var random_index := randi() % colors.size()
	var chosen_color: Color = colors[random_index]
	$Sprite2D.modulate = chosen_color

func change_speed() -> void:
	# Mengubah kecepatan ke nilai acak antara 25.0 dan 100.0
	speed = randf_range(25.0, 100.0)
	# Membalik arah gerakan secara acak
	if randi() % 2 == 0:
		facing = -facing

func take_damage() -> void:
	$HitSound.play()
	$AnimationPlayer.play("death")
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
