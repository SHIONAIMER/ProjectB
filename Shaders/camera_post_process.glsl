#[compute]
#version 450

// 计算着色器的工作组大小
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// 输入图像
layout(rgba16f, set = 0, binding = 0) uniform image2D color_image;

// 推送常量
layout(push_constant, std430) uniform Params {
	vec2 raster_size;
	float vignette_power;
	float vignette_radius;
} params;

void main() {
	// 获取当前像素坐标
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = ivec2(params.raster_size);

	// 防止越界访问
	if (uv.x >= size.x || uv.y >= size.y) {
		return;
	}

	// 读取原始颜色
	vec4 color = imageLoad(color_image, uv);

	// 计算中心点
	vec2 center = vec2(size) * 0.5;
	
	// 计算当前像素到中心的距离（归一化到0-1）
	vec2 dist = (vec2(uv) - center) / center;
	
	// 计算距离的平方
	float d = dot(dist, dist);
	
	// 计算暗角效果
	// 使用smoothstep实现平滑过渡
	float vignette = 1.0 - smoothstep(
		params.vignette_radius, 
		params.vignette_radius + 0.1, 
		d
	) * params.vignette_power;
	
	// 应用暗角效果
	color.rgb *= vignette;

	// 写回颜色
	imageStore(color_image, uv, color);
}
