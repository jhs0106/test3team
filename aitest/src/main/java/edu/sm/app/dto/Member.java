package edu.sm.app.dto;

import java.time.LocalDate;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.format.annotation.DateTimeFormat;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Mapper
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Member {
    private Long memberNo;
    private String loginId;
    private String password;
    private String name;
    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate birthDate;
    private String address;
    private String assetStatus;
    private String phoneNumber;
    private String membershipLevel;
}