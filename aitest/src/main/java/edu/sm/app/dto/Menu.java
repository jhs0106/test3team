package edu.sm.app.dto;

import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Menu {
    private Integer menuId;
    private Integer categoryId;
    private String menuName;
    private Integer menuPrice;
    private String menuImage;
    private String categoryName; // JOIN용
}