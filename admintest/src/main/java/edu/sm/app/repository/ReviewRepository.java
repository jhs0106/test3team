package edu.sm.app.repository;

import edu.sm.app.dto.MemberReview;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

@Mapper
@Repository
public interface ReviewRepository {

    List<MemberReview> findRecentReviews(int limit);
}