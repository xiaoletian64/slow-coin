extends Node
signal shaken
var previous: = Vector3.ZERO
var initialized: = false
var peak_time: = -10.0
var cooldown: = 0.0
var elapsed: = 0.0
func sample(acceleration: Vector3, delta: float) -> void :
	elapsed += delta
	cooldown = maxf(0, cooldown - delta)
	if not initialized:
		previous = acceleration
		initialized = true
		return
	var jerk: float = (acceleration - previous).length()
	previous = acceleration
	if cooldown > 0 or jerk < 13: return
	if elapsed - peak_time < 0.6:
		cooldown = 2.0
		peak_time = -10
		shaken.emit()
	else: peak_time = elapsed
func _process(delta: float) -> void :
	if OS.has_feature("mobile"): sample(Input.get_accelerometer(), delta)
