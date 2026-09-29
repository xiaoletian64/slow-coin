extends RigidBody3D
signal metal_hit(strength: float)
signal surface_hit
var audio_contacts := {}
var audio_cooldown := 0.25

const RADIUS := 0.235
const HEIGHT := 0.095
static var shared_shape: CylinderShape3D
const TokenMesh=preload("res://scripts/token_mesh.gd")
static var metal: StandardMaterial3D
static var silver:ShaderMaterial
static var custom_stamp:Texture2D
static var stamp_material:ShaderMaterial
var bonus_coin := false
var in_pinboard := false
var target_checked := false
var previous_y := 0.0
var pin_stall := 0.0
var guide_distance:=-1.0
var guide_speed:=2.0

func set_pinboard(value: bool) -> void:
	in_pinboard=value
	can_sleep=not value
	if value:sleeping=false
	axis_lock_linear_z=value
	axis_lock_angular_x=value
	axis_lock_angular_y=value

func _init() -> void:
	max_contacts_reported = 8
	mass = 0.025
	continuous_cd = true
	linear_damp = 0.3
	angular_damp = 0.65
	can_sleep = true
	if shared_shape == null:
		shared_shape = CylinderShape3D.new()
		shared_shape.radius = RADIUS
		shared_shape.height = HEIGHT
		metal = StandardMaterial3D.new()
		metal.albedo_color = Color.WHITE
		metal.vertex_color_use_as_albedo=true
		metal.cull_mode=BaseMaterial3D.CULL_DISABLED
		metal.metallic = 0.65
		metal.roughness = 0.3
	var shape := CollisionShape3D.new()
	shape.shape = shared_shape
	add_child(shape)
	var physics := PhysicsMaterial.new()
	physics.friction = 0.48
	physics.bounce = 0.05
	physics_material_override = physics
	var visual:=MeshInstance3D.new()
	visual.name="Visual"
	visual.mesh=TokenMesh.get_mesh()
	visual.material_override=metal
	add_child(visual)

func snapshot() -> Dictionary:
	return {"guide_distance":guide_distance,"guide_speed":guide_speed,"p":vec(position), "r":vec(rotation), "v":vec(linear_velocity), "a":vec(angular_velocity), "s":sleeping,"bonus":bonus_coin,"pinboard":in_pinboard,"target_checked":target_checked,"previous_y":previous_y,"pin_stall":pin_stall}

static func vec(v: Vector3) -> Array:
	return [v.x, v.y, v.z]

static func unvec(values: Array) -> Vector3:
	return Vector3(float(values[0]), float(values[1]), float(values[2]))

static func valid(data: Dictionary) -> bool:
	for key in ["p", "r", "v", "a"]:
		if not data.get(key) is Array or data[key].size() != 3:
			return false
		for value in data[key]:
			if not (value is float or value is int) or not is_finite(float(value)) or absf(float(value)) > 100.0:
				return false
	for key in ["previous_y","pin_stall"]:
		var value=data.get(key,0.0)
		if not (value is int or value is float) or not is_finite(float(value)) or absf(float(value))>100:return false
	for key in ["guide_distance","guide_speed"]:
		var n=data.get(key,-1.0 if key=="guide_distance" else 2.0)
		if not (n is int or n is float) or not is_finite(float(n)):return false
	var d:float=float(data.get("guide_distance",-1.0))
	var speed:float=float(data.get("guide_speed",2.0))
	if (d!=-1.0 and (d<0 or d>2.68)) or speed<0 or speed>5.5:return false
	if d>=0 and not data.get("pinboard",false):return false
	return data.get("s") is bool and data.get("bonus",false) is bool and data.get("pinboard",false) is bool and data.get("target_checked",false) is bool

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	audio_cooldown=maxf(0,audio_cooldown-state.step)
	var touching := {}
	var strongest := 0.0
	var surface_strength:=0.0
	for i in range(state.get_contact_count()):
		var other=state.get_contact_collider_object(i)
		if not is_instance_valid(other):continue
		var id:int=other.get_instance_id()
		touching[id]=true
		# Persistent stack pressure is not a fresh impact. The global mixer
		# coalesces both sides, including collisions against sleeping coins.
		if audio_contacts.has(id):continue
		if other.get_script()==get_script():
			strongest=maxf(strongest,state.get_contact_impulse(i).length())
		else:
			surface_strength=maxf(surface_strength,state.get_contact_impulse(i).length())
	audio_contacts=touching
	if surface_strength>=0.025 and audio_cooldown<=0:
		audio_cooldown=0.18
		surface_hit.emit()
	elif strongest>=0.012 and audio_cooldown<=0:
		audio_cooldown=0.18
		metal_hit.emit(clampf(strongest/0.07,0.2,1.0))

static func set_custom_stamp(texture:Texture2D)->void:
	custom_stamp=texture
	if texture==null:return
	if stamp_material==null:
		stamp_material=ShaderMaterial.new()
		var shader:=Shader.new()
		shader.code="""shader_type spatial;
render_mode cull_disabled;
uniform sampler2D design : source_color;
varying vec3 local_pos;
varying vec3 local_normal;
varying vec4 coin_color;
void vertex(){local_pos=VERTEX;local_normal=NORMAL;coin_color=COLOR;}
void fragment(){
 vec3 tint=coin_color.rgb;
 if(abs(local_normal.y)>.8 && length(local_pos.xz)<.182){
  vec2 uv=local_pos.xz/.364+vec2(.5);
  if(local_pos.y<0.)uv.x=1.-uv.x;
  vec4 ink=texture(design,uv);
  tint*=mix(1.,mix(.35,1.18,ink.r),ink.a);
 }
 ALBEDO=tint; METALLIC=.75; ROUGHNESS=.36;
}"""
		stamp_material.shader=shader
	stamp_material.set_shader_parameter("design",texture)

func set_silver(enabled:bool)->void:
	if custom_stamp!=null:
		$Visual.mesh=TokenMesh.get_mesh(enabled,true)
		$Visual.material_override=stamp_material
		return
	if enabled and silver==null:
		silver=ShaderMaterial.new()
		var shader:=Shader.new()
		shader.code="""shader_type spatial;
render_mode cull_disabled;
varying vec3 coin_pos;
varying vec4 coin_color;
void vertex(){coin_pos=VERTEX;coin_color=COLOR;}
void fragment(){
float shade=dot(coin_color.rgb,vec3(0.299,0.587,0.114));
float scratch=sin(coin_pos.x*1170.0+sin(coin_pos.z*93.0)*2.0)*0.018;
ALBEDO=vec3(0.48,0.52,0.56)*(shade+scratch);
METALLIC=0.78; ROUGHNESS=0.32+scratch;
}"""
		silver.shader=shader
	get_node("Visual").mesh=TokenMesh.get_mesh(enabled)
	get_node("Visual").material_override=silver if enabled else metal
