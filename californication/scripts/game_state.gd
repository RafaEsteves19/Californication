extends Node
# Dados globais do jogo (autoload "GameState").

# Personagens provisórios. Estatísticas de 1 a 10.
# Para mudar o equilíbrio do jogo, é só editar os números aqui.
var characters := [
    {
        "id": "velocista",
        "name": "Velocista",
        "color": Color(0.95, 0.35, 0.3),
        "stats": {"speed": 8, "resilience": 3, "agility": 6, "driving": 4},
    },
    {
        "id": "tanque",
        "name": "Tanque",
        "color": Color(0.3, 0.45, 0.95),
        "stats": {"speed": 4, "resilience": 9, "agility": 3, "driving": 6},
    },
    {
        "id": "acrobata",
        "name": "Acrobata",
        "color": Color(0.35, 0.85, 0.45),
        "stats": {"speed": 6, "resilience": 4, "agility": 9, "driving": 5},
    },
]

var selected_index := 0
var selected_character := ""
var stats := {}
var character_color := Color.WHITE


func _ready() -> void:
    _setup_input()
    select_character(0)


func select_character(index: int) -> void:
    selected_index = index
    var c: Dictionary = characters[index]
    selected_character = c["name"]
    stats = c["stats"].duplicate()
    character_color = c["color"]


# Registra as teclas por código, sem precisar mexer no Mapa de Entrada.
func _setup_input() -> void:
    var actions := {
        "move_forward": [KEY_W, KEY_UP],
        "move_back": [KEY_S, KEY_DOWN],
        "move_left": [KEY_A, KEY_LEFT],
        "move_right": [KEY_D, KEY_RIGHT],
        "jump": [KEY_SPACE],
        "interact": [KEY_E],
        "vehicle_toggle": [KEY_F],
        "vehicle_menu": [KEY_V],
    }
    for action in actions:
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        for key in actions[action]:
            var ev := InputEventKey.new()
            ev.physical_keycode = key
            InputMap.action_add_event(action, ev)


# ---------------------------------------------------------------- Veículos
# Para adicionar um veículo novo, é só acrescentar um bloco nesta lista.
var vehicles := [
    {
        "id": "carro", "name": "Carro",
        "color": Color(0.9, 0.75, 0.1), "size": Vector3(2.0, 1.3, 4.0),
        "max_speed": 28.0, "accel": 14.0, "turn": 1.8,
    },
    {
        "id": "buggy", "name": "Buggy",
        "color": Color(0.9, 0.4, 0.1), "size": Vector3(1.8, 1.0, 3.0),
        "max_speed": 34.0, "accel": 20.0, "turn": 2.3,
    },
    {
        "id": "caminhao", "name": "Caminhão",
        "color": Color(0.3, 0.5, 0.35), "size": Vector3(2.4, 1.8, 6.0),
        "max_speed": 20.0, "accel": 8.0, "turn": 1.3,
    },
]

# Só o carro começa desbloqueado; os outros são liberados por missões (Etapa 7)
var unlocked_vehicles := ["carro"]


func is_vehicle_unlocked(id: String) -> bool:
    return id in unlocked_vehicles


func unlock_vehicle(id: String) -> void:
    if id not in unlocked_vehicles:
        unlocked_vehicles.append(id)


func get_vehicle(id: String) -> Dictionary:
    for v in vehicles:
        if v["id"] == id:
            return v
    return {}
