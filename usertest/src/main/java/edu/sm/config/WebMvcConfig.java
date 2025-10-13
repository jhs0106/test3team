package edu.sm.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
@Slf4j
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    // file:///C:/smspring/imgs/ 가 주입됩니다.
    @Value("${app.dir.imgsdir}")
    String imgdir;

    // C:/smspring/logs/ 가 주입됩니다.
    @Value("${app.dir.logsdir}")
    String logdir;


    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // [확인] imgdir에 file:/// 접두사가 있으므로 이 코드는 올바릅니다.
        registry.addResourceHandler("/imgs/**").addResourceLocations(imgdir);
        // logsdir은 읽기용 경로가 별도로 있다면 해당 경로를 사용해야 합니다. (logsdirRead를 쓰지 않는 경우 그대로 둠)
        registry.addResourceHandler("/logs/**").addResourceLocations(logdir);
    }

    @Override
    public void addCorsMappings(CorsRegistry registry){
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("HEAD", "GET", "POST", "PUT", "DELETE", "OPTIONS")
                .maxAge(3600)
                .allowCredentials(false)
                .allowedHeaders("Authorization", "Cache-Control", "Content-Type");
    }
}