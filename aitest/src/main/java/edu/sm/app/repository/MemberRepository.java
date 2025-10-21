package edu.sm.app.repository;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import edu.sm.app.dto.Member;
import edu.sm.common.frame.SmRepository;

@Repository
@Mapper
public interface MemberRepository extends SmRepository<Member, String> {

    @Override
    void insert(Member member);

    @Override
    void update(Member member);

    @Override
    void delete(@Param("loginId") String loginId);

    @Override
    Member select(@Param("loginId") String loginId);

    boolean existsByLoginId(@Param("loginId") String loginId);
}