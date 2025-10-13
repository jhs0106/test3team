package edu.sm.controller;

import edu.sm.app.dto.Marker;
import edu.sm.app.service.MarkerService;
import edu.sm.util.FileUploadUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequiredArgsConstructor
@Slf4j
public class MapRestController {
    private final MarkerService markerService;

    @Value("${upload.dir:C:/uploads/}")
    private String uploadDir;

    @PostMapping("/registermarker")
    public Object registerMarker(
            @RequestParam("markerTitle") String title,
            @RequestParam("markerDescription") String description,
            @RequestParam("markerImage") MultipartFile imageFile,
            @RequestParam("lat") double lat,
            @RequestParam("lng") double lng
    ) {
        String savedImageName = null;
        try {
            savedImageName = FileUploadUtil.saveFile(imageFile, uploadDir);

            Marker marker = Marker.builder()
                    .title(title)
                    .description(description)
                    .img(savedImageName)
                    .lat(lat)
                    .lng(lng)
                    .build();

            markerService.saveMarker(marker);

            return "success";

        } catch (IOException e) {
            log.error("파일 업로드/저장 실패: {}", e.getMessage());
            return "File upload failed";
        } catch (Exception e) {
            log.error("데이터베이스 저장 실패: {}", e.getMessage());
            return "Database save failed";
        }
    }

    @GetMapping("/getallmarkers")
    public List<Marker> getAllMarkers() {
        try {
            List<Marker> markers = markerService.getAllMarkers();
            return markers;
        } catch (Exception e) {
            log.error("마커 목록 조회 실패: {}", e.getMessage());
            return List.of();
        }
    }
}