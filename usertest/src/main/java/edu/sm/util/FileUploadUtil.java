// /usertest/src/main/java/edu/sm/util/FileUploadUtil.java
package edu.sm.util;

import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.io.IOException;
import java.util.UUID;

public class FileUploadUtil {

    public static String saveFile(MultipartFile file, String uploadDir) throws IOException {
        if (file == null || file.isEmpty()) {
            return null;
        }

        String originalFilename = file.getOriginalFilename();
        String uuid = UUID.randomUUID().toString();

        String extension = "";
        int lastDotIndex = originalFilename.lastIndexOf(".");
        if (lastDotIndex > 0) {
            extension = originalFilename.substring(lastDotIndex);
            originalFilename = originalFilename.substring(0, lastDotIndex);
        }

        if (originalFilename.equals("empty") && file.getSize() == 0) {
            return null;
        }

        String savedFilename = uuid + "_" + originalFilename + extension;

        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        File targetFile = new File(dir, savedFilename);
        file.transferTo(targetFile);

        return savedFilename;
    }
}