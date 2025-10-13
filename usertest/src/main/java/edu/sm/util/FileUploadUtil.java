package edu.sm.util;

import org.springframework.web.multipart.MultipartFile;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

public class FileUploadUtil {
    public static void deleteFile(String filename, String dir) throws IOException {
        Path filePath = Paths.get(dir+filename);
        Files.delete(filePath);
    }

    public static String saveFile(MultipartFile mf, String dir) throws IOException {
        if(mf.isEmpty()) {
            return null;
        }

        String originalFilename = mf.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String savedFilename = UUID.randomUUID().toString() + extension;

        Path uploadPath = Paths.get(dir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        byte [] data;
        try {
            data = mf.getBytes();
            FileOutputStream fo = new FileOutputStream(dir + savedFilename);
            fo.write(data);
            fo.close();
            return savedFilename;
        } catch(Exception e) {
            e.printStackTrace();
            throw new IOException("파일 저장 실패: " + savedFilename, e);
        }
    }
}