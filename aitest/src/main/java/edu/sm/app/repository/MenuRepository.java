package edu.sm.app.repository;

import edu.sm.app.dto.Menu;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Mapper
public interface MenuRepository {

    @Insert("INSERT INTO menu (category_id, menu_name, menu_price, menu_image) " +
            "VALUES (#{categoryId}, #{menuName}, #{menuPrice}, #{menuImage})")
    void insert(Menu menu) throws Exception;

    @Update("UPDATE menu SET category_id=#{categoryId}, menu_name=#{menuName}, " +
            "menu_price=#{menuPrice}, menu_image=#{menuImage} WHERE menu_id=#{menuId}")
    void update(Menu menu) throws Exception;

    @Delete("DELETE FROM menu WHERE menu_id=#{menuId}")
    void delete(Integer menuId) throws Exception;

    @Select("SELECT * FROM menu")
    List<Menu> selectAll() throws Exception;

    @Select("SELECT * FROM menu WHERE menu_id=#{menuId}")
    Menu select(Integer menuId) throws Exception;

    @Select("SELECT m.menu_id, m.category_id, m.menu_name, m.menu_price, m.menu_image, c.category_name " +
            "FROM menu m INNER JOIN category c ON m.category_id=c.category_id " +
            "ORDER BY m.category_id, m.menu_id")
    List<Menu> selectAllWithCategory() throws Exception;

    @Select("SELECT m.menu_id, m.category_id, m.menu_name, m.menu_price, m.menu_image, c.category_name " +
            "FROM menu m INNER JOIN category c ON m.category_id=c.category_id " +
            "WHERE m.category_id=#{categoryId} ORDER BY m.menu_id")
    List<Menu> selectByCategory(Integer categoryId) throws Exception;
}