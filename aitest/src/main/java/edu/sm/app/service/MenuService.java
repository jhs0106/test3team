package edu.sm.app.service;

import edu.sm.app.dto.Menu;
import edu.sm.app.repository.MenuRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MenuService implements SmService<Menu, Integer> {

    private final MenuRepository menuRepository;

    @Override
    public void register(Menu menu) throws Exception {
        menuRepository.insert(menu);
    }

    @Override
    public void modify(Menu menu) throws Exception {
        menuRepository.update(menu);
    }

    @Override
    public void remove(Integer menuId) throws Exception {
        menuRepository.delete(menuId);
    }

    @Override
    public List<Menu> get() throws Exception {
        return menuRepository.selectAll();
    }

    @Override
    public Menu get(Integer menuId) throws Exception {
        return menuRepository.select(menuId);
    }

    public List<Menu> getAllWithCategory() throws Exception {
        return menuRepository.selectAllWithCategory();
    }

    public List<Menu> getByCategory(Integer categoryId) throws Exception {
        return menuRepository.selectByCategory(categoryId);
    }
}