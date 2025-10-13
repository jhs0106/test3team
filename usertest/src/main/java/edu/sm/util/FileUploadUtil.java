// /usertest/src/main/java/edu/sm/util/FileUploadUtil.java
package edu.sm.util;

import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.io.IOException;
import java.util.UUID;

public class FileUploadUtil {

    /**
     * 파일을 지정된 디렉토리에 저장하고, 저장된 파일명(UUID_파일명)을 반환합니다.
     * @param file 업로드할 파일
     * @param uploadDir 파일이 저장될 서버의 물리적 경로 (예: C:/usertest_uploads/imgs/)
     * @return 저장된 파일의 고유 이름 (UUID_OriginalFilename)
     */
    public static String saveFile(MultipartFile file, String uploadDir) throws IOException {
        if (file == null || file.isEmpty()) {
            return null;
        }

        // 1. 고유한 파일명 생성
        String originalFilename = file.getOriginalFilename();
        String uuid = UUID.randomUUID().toString();

        // 파일 확장자 처리
        String extension = "";
        int lastDotIndex = originalFilename.lastIndexOf(".");
        if (lastDotIndex > 0) {
            extension = originalFilename.substring(lastDotIndex);
            originalFilename = originalFilename.substring(0, lastDotIndex);
        }

        // [중요] 파일이 업로드되지 않은 경우 ('empty' 파일) 처리
        if (originalFilename.equals("empty") && file.getSize() == 0) {
            return null;
        }

        String savedFilename = uuid + "_" + originalFilename + extension;

        // 2. 파일 저장 경로 생성 및 폴더 생성 (절대 경로 기준)
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs(); // 디렉토리가 없으면 생성 (재귀적으로 생성)
        }

        // 3. 파일 저장
        File targetFile = new File(dir, savedFilename);
        file.transferTo(targetFile);

        // [핵심] DB에 저장될 순수한 파일 이름만 반환
        return savedFilename;
    }
}