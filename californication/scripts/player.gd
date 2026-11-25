extends CharacterBody3D

const BASE_SPEED := 8.0
const BASE_JUMP := 9.0
const GRAVITY := 24.0
const ACCEL := 60.0
const MOUSE_SENS := 0.003

@onready var pivot: Node3D = $CameraPivot
@onready var arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var visual: Node3D = $Visual

var speed := BASE_SPEED
var jump_velocity := BASE_JUMP
var turn_speed := 12.0
var was_on_floor := true


func _ready() -> void:
    apply_stats(GameState.stats)
    _apply_color()
    arm.add_excluded_object(get_rid())
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _exit_tree() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Velocidade e agilidade já afetam o movimento.
# Resistência e direção serão usadas nas missões e nos veículos.
func apply_stats(s: Dictionary) -> void:
    speed = BASE_SPEED * (s["speed"] / 5.0)
    jump_velocity = BASE_JUMP * (0.8 + 0.2 * s["agility"] / 5.0)
    turn_speed = 12.0 * (s["agility"] / 5.0)


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        pivot.rotation.y -= event.relative.x * MOUSE_SENS
        pivot.rotation.x = clamp(
            pivot.rotation.x - event.relative.y * MOUSE_SENS,
            deg_to_rad(-60), deg_to_rad(30))
    elif event.is_action_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event is InputEventMouseButton and event.pressed \
            and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    elif event is InputEventKey and event.pressed and event.keycode == KEY_F1:
        SceneManager.goto("res://scenes/menus/main_menu.tscn")


func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    # Movimento relativo à direção da câmera
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var dir := Basis(Vector3.UP, pivot.rotation.y) * Vector3(input.x, 0.0, input.y)

    velocity.x = move_toward(velocity.x, dir.x * speed, ACCEL * delta)
    velocity.z = move_toward(velocity.z, dir.z * speed, ACCEL * delta)

    # Vira o corpo para a direção do movimento
    if dir.length() > 0.1:
        var target := atan2(-dir.x, -dir.z)
        visual.rotation.y = lerp_angle(visual.rotation.y, target, turn_speed * delta)

    move_and_slide()

    # Animação simples: achata o corpo ao aterrissar
    if is_on_floor() and not was_on_floor:
        _squash()
    was_on_floor = is_on_floor()


func _squash() -> void:
    visual.scale = Vector3(1.2, 0.8, 1.2)
    var t := create_tween()
    t.tween_property(visual, "scale", Vector3.ONE, 0.15)


# Pinta o corpo com a cor do personagem escolhido (provisório até termos modelos)
func _apply_color() -> void:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = GameState.character_color
    $Visual/Body.material_override = mat
