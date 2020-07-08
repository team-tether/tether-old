tool
extends Node

class_name State, "res://addons/node_fsm_plugin/state_icon.svg"

signal state_changed

const AUTO_STATE_PREFIX := 'go_to ' # Prefix for implicit state change
const AUTO_TARGET_METHOD_PREFIX := '.' # Prefix for implicit target method calls

enum StateType {NORMAL, PUSH}

export(String) var state_name: String = ''
export(StateType) var state_type: int

var fsm
var target: Node
var _timers_registry: Dictionary = {}


func _get_configuration_warning() -> String:
	var warning: PoolStringArray = PoolStringArray()

	if get_script() == load("res://addons/node_fsm_plugin/state_node.gd"):
		warning.append('"%s" State must extend the script and not use it directly' % name)

	return warning.join('\n')


func get_state_name() -> String:
	if state_name:
		return state_name
	return name


func is_active_state() -> bool:
	return fsm.active and fsm.current_state == self


func reset_all_timers() -> void:
	for method in _timers_registry.keys():
		reset_timer(method)


func reset_timer(method: String) -> void:
	_timers_registry[method].timer_delta = 0.0
	_timers_registry[method].executed = false


func _get_timer_value(timeout: float, timeout_end: float = 0) -> float:
	var timer_at: float = timeout

	if timeout_end:
		randomize()
		timer_at = rand_range(timeout, timeout_end)

	return timer_at


func register_timer(method: String, timeout: float, timeout_end: float = 0) -> String:
	var new_timer: Dictionary = {
		'method': method,
		'trigger_at': _get_timer_value(timeout, timeout_end),
		'timer_delta': 0.0,
		'executed': false
	}

	_timers_registry[method] = new_timer

	return method


func _ready() -> void:
	if Engine.editor_hint:
		set_process_input(false)
		set_process(false)
		set_physics_process(false)
	else:
		on_ready()
		on_timers_register()


func _process(delta: float) -> void:
	if is_active_state():
		_dispatch_timers(delta)


func _dispatch_timers(delta: float) -> void:
	for timer in _timers_registry.values():
		timer.timer_delta += delta

		if not timer.executed:

			if timer.timer_delta > timer.trigger_at:
				# If the timer is still active check for the defined method in order

				# 1. Current node method
				if has_method(timer.method):
					call(timer.method)
					timer.executed = true

				# 2. Target node method
				elif timer.method.begins_with(AUTO_TARGET_METHOD_PREFIX):
					var target_method_name: String = timer.method.lstrip(AUTO_TARGET_METHOD_PREFIX)
					target.call(target_method_name)
					timer.executed = true

				# 3. State name in FSM
				elif timer.method.begins_with(AUTO_STATE_PREFIX):
					var state_name: String = timer.method.lstrip(AUTO_STATE_PREFIX)
					go_to(state_name)
					timer.executed = true


# Public state transition methods #

func go_to(state: String) -> void:
	emit_signal('state_changed', state)


func go_to_previous() -> void:
	go_to(fsm.PREVIOUS)


# Public methods to override #

func on_timers_register() -> void:
	pass


func on_ready() -> void:
	pass


# NOTE: leaving 'target' not typed to avoid errors when
#		using typing in the extended scripts
func on_enter(target) -> void:
	pass


func on_exit(target) -> void:
	pass


func on_input(target, event: InputEvent) -> void:
	pass


func on_process(target, delta: float) -> void:
	pass


func on_physics_process(target, delta: float) -> void:
	pass
