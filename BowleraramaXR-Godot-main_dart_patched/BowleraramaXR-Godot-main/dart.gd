extends XRToolsPickable

signal consumed(dart: Node, stuck: bool, reason: String)

@export var settle_speed: float = 0.30
@export var settle_time: float = 0.60
@export var max_flight_time: float = 8.0
@export var bounds_x: float = 2.40
@export var bounds_front_z: float = 1.60
@export var bounds_back_z: float = -6.00
@export var floor_y: float = -0.20
@export var target_group: StringName = &"dart_target"
@export var reset_on_hit_group: StringName = &"dart_reset_on_hit"
@export var glow_idle: float = 1.5
@export var glow_held: float = 3.2

var is_stuck := false
var _in_flight := false
var _settle_clock := 0.0
var _life_clock := 0.0

@onready var _glow_parts: Array[MeshInstance3D] = [$Shaft, $Flights]

func _ready() -> void:
    super()
    contact_monitor = true
    max_contacts_reported = 8
    body_entered.connect(_on_body_entered)
    picked_up.connect(_on_picked_up)
    dropped.connect(_on_dropped)
    _set_glow(glow_idle)

func arm_at(marker: Node3D) -> void:
    is_stuck = false
    enabled = true
    visible = true
    freeze = true
    sleeping = false
    collision_layer = original_collision_layer
    collision_mask = original_collision_mask
    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO
    global_transform = marker.global_transform
    _reset_timers()
    _set_glow(glow_idle)

func _on_picked_up(_dart: XRToolsPickable) -> void:
    if is_stuck:
        return
    _in_flight = false
    _reset_timers()
    _set_glow(glow_held)

func _on_dropped(_dart: XRToolsPickable) -> void:
    if is_stuck:
        return
    _in_flight = true
    _reset_timers()
    _set_glow(glow_idle)

func _physics_process(delta: float) -> void:
    if is_stuck or not _in_flight or is_picked_up():
        return

    _life_clock += delta
    if _life_clock >= max_flight_time:
        _consume(false, "timeout")
        return

    var p := global_position
    if p.y < floor_y:
        _consume(false, "floor")
        return
    if absf(p.x) > bounds_x or p.z > bounds_front_z or p.z < bounds_back_z:
        _consume(false, "bounds")
        return

    if linear_velocity.length() < settle_speed:
        _settle_clock += delta
        if _settle_clock >= settle_time:
            _consume(false, "settled")
    else:
        _settle_clock = 0.0

func _on_body_entered(body: Node) -> void:
    if is_stuck or is_picked_up() or not _in_flight:
        return
    if body.is_in_group(target_group):
        _stick_to_target(body)
        return
    if body.is_in_group(reset_on_hit_group):
        _consume(false, "miss")

func _stick_to_target(target_node: Node) -> void:
    is_stuck = true
    _in_flight = false
    enabled = false
    freeze = true
    sleeping = true
    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO
    collision_layer = 0
    collision_mask = 0

    var current_transform := global_transform
    var old_parent := get_parent()
    if old_parent:
        old_parent.remove_child(self)
    target_node.add_child(self)
    global_transform = current_transform
    _set_glow(glow_idle)
    consumed.emit(self, true, "stuck")

func _consume(stuck: bool, reason: String) -> void:
    _in_flight = false
    enabled = false
    freeze = true
    sleeping = false
    linear_velocity = Vector3.ZERO
    angular_velocity = Vector3.ZERO
    collision_layer = 0
    collision_mask = 0
    consumed.emit(self, stuck, reason)

func _reset_timers() -> void:
    _settle_clock = 0.0
    _life_clock = 0.0

func _set_glow(energy: float) -> void:
    for part in _glow_parts:
        var mat := part.get_surface_override_material(0) as StandardMaterial3D
        if mat:
            mat.emission_energy_multiplier = energy
