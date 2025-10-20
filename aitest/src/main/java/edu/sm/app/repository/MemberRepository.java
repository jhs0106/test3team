package edu.sm.app.repository;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import edu.sm.app.dto.Member;

@Repository
@Mapper
public interface MemberRepository {
    void insertMember(Member member);

    Member findByLoginId(String loginId);

    boolean existsByLoginId(String loginId);
}