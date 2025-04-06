@tool
extends CompositorEffect
class_name PostProcessShader

var rd: RenderingDevice
var shader: RID
var pipeline: RID

@export_file("*.glsl") var shader_path: String = "res://Shaders/camera_post_process.glsl"

func _init() -> void:
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	RenderingServer.call_on_render_thread(_initialize_compute)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			rd.free_rid(shader)

func set_shader_path(path: String) -> void:
	shader_path = path
	reload_shader()

func reload_shader() -> void:
	if shader.is_valid():
		rd.free_rid(shader)
	RenderingServer.call_on_render_thread(_initialize_compute)

#region
func _initialize_compute() -> void:
	rd = RenderingServer.get_rendering_device()
	if not rd:
		return
		
	if not FileAccess.file_exists(shader_path):
		push_error("Shader file not found: " + shader_path)
		return

	var shader_file := load(shader_path)
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()

	shader = rd.shader_create_from_spirv(shader_spirv)
	if shader.is_valid():
		pipeline = rd.compute_pipeline_create(shader)

func _render_callback(p_effect_callback_type: EffectCallbackType, p_render_data: RenderData) -> void:
	if rd and p_effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and pipeline.is_valid():
		# 获取渲染场景缓冲区，用于访问渲染缓冲
		var render_scene_buffers := p_render_data.get_render_scene_buffers()
		if render_scene_buffers:
			var size: Vector2i = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			@warning_ignore("integer_division")
			var x_groups := (size.x - 1) / 8 + 1
			@warning_ignore("integer_division")
			var y_groups := (size.y - 1) / 8 + 1
			var z_groups := 1

			var push_constant := PackedFloat32Array([
				size.x,
				size.y,
				0.0,
				0.0,
			])

			var view_count: int = render_scene_buffers.get_view_count()
			for view in view_count:
				var input_image: RID = render_scene_buffers.get_color_layer(view)

				var uniform := RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform.binding = 0
				uniform.add_id(input_image)
				var uniform_set := UniformSetCacheRD.get_cache(shader, 0, [uniform])

				var compute_list := rd.compute_list_begin()
				rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
				rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
				rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
				rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)
				rd.compute_list_end()
#endregion
