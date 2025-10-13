package edu.sm.app.dto;
import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Marker {
    private int target;
    private String title;
    private String description;
    private String img;
    private double lat;
    private double lng;
}