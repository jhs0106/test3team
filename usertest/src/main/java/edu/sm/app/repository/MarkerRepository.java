package edu.sm.app.repository;

import edu.sm.app.dto.Marker;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Mapper
public interface MarkerRepository {
    void insert(Marker marker) throws Exception;

    List<Marker> findAll() throws Exception;
}