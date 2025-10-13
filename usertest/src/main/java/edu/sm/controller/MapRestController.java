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

    // [수정] 파일 저장을 위해 application.yml의 파일 쓰기용 절대 경로를 사용합니다.
    @Value("${app.dir.uploadimgsdir}")
    private String uploadDir; // ex: C:/smspring/imgs/

    /**
     * 클라이언트에서 전송된 마커 정보(제목, 설명, 파일, 위/경도)를 저장합니다.
     */
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
            // 1. 파일 업로드 및 저장된 파일명 획득 (uploadDir: C:/smspring/imgs/ 로 파일 저장됨)
            savedImageName = FileUploadUtil.saveFile(imageFile, uploadDir);

            // 2. Marker 객체 생성 및 DB 저장
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

    /**
     * DB에 저장된 모든 마커 목록을 조회합니다.
     */
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