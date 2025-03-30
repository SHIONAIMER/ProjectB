shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform float shadow_offset : hint_range(-10.0, 10.0) = 2.0;
uniform float shadow_softness : hint_range(0.0, 10.0) = 1.0;
uniform float highlight_intensity : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // 创建阴影效果
    vec2 shadow_uv = UV + vec2(shadow_offset / 100.0, shadow_offset / 100.0);
    vec4 shadow = texture(TEXTURE, shadow_uv);
    
    // 计算阴影的柔和度
    float shadow_alpha = shadow.a * (1.0 - shadow_softness / 10.0);
    
    // 添加高光效果
    vec2 light_dir = normalize(vec2(0.5, -0.5));
    float highlight = max(0.0, dot(light_dir, UV - 0.5));
    
    // 混合颜色
    vec4 final_color = color;
    final_color.rgb += highlight * highlight_intensity;
    final_color.a = color.a;
    
    // 添加阴影
    final_color = mix(shadow_color, final_color, final_color.a);
    final_color.a = max(color.a, shadow_alpha);
    
    COLOR = final_color;
} 