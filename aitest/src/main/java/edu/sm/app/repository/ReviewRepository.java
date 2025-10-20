package edu.sm.app.repository;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import edu.sm.app.dto.MemberReview;

@Repository
@Mapper
public interface ReviewRepository {
    void insertReview(MemberReview review);

    List<MemberReview> findRecentReviews(int limit);
}