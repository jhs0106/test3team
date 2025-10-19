package edu.sm.app.dto;

import lombok.Data;

import java.util.List;

@Data
public class Hotel {
  // 도시 이름
  private String city;
  // 호텔 이름 목록
  private List<String> names;
}
