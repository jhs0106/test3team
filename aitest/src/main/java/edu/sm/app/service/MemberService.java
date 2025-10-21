package edu.sm.app.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import edu.sm.app.dto.Member;
import edu.sm.app.repository.MemberRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberService implements SmService<Member, String> {

    private final MemberRepository memberRepository;

    @Override
    @Transactional
    public void register(Member member) throws Exception {
        memberRepository.insert(member);
    }

    @Override
    @Transactional
    public void modify(Member member) throws Exception {
        memberRepository.update(member);
    }

    @Override
    @Transactional
    public void remove(String loginId) throws Exception {
        memberRepository.delete(loginId);
    }

    @Override
    public List<Member> get() throws Exception {
        return memberRepository.selectAll();
    }

    @Override
    public Member get(String loginId) throws Exception {
        return memberRepository.select(loginId);
    }

    public Member registerMember(Member member) {
        if (member == null) {
            throw new IllegalArgumentException("등록 정보가 제공되지 않았습니다.");
        }
        validateRegistration(member);
        try {
            register(member);
        } catch (Exception e) {
            throw new IllegalStateException("회원 가입 처리 중 오류가 발생했습니다.", e);
        }
        Member persisted = memberRepository.select(member.getLoginId());
        if (persisted == null) {
            throw new IllegalStateException("회원 가입 후 정보를 조회할 수 없습니다.");
        }
        return persisted;
    }

    public Member login(String loginId, String password) {
        if (loginId == null || loginId.isBlank()) {
            throw new IllegalArgumentException("아이디를 입력해주세요.");
        }
        if (password == null || password.isBlank()) {
            throw new IllegalArgumentException("비밀번호를 입력해주세요.");
        }
        String normalizedLoginId = loginId.trim();
        String normalizedPassword = password.trim();
        Member member;
        try {
            member = memberRepository.select(normalizedLoginId);
        } catch (Exception e) {
            throw new IllegalStateException("로그인 조회 처리 중 오류가 발생했습니다.", e);
        }
        if (member == null) {
            throw new IllegalArgumentException("존재하지 않는 아이디입니다.");
        }
        if (!member.getPassword().equals(normalizedPassword)) {
            throw new IllegalArgumentException("비밀번호가 올바르지 않습니다.");
        }
        return member;
    }

    private void validateRegistration(Member member) {
        if (member.getLoginId() != null) {
            member.setLoginId(member.getLoginId().trim());
        }
        if (member.getPassword() != null) {
            member.setPassword(member.getPassword().trim());
        }
        if (member.getName() != null) {
            member.setName(member.getName().trim());
        }
        if (member.getGender() != null) {
            member.setGender(member.getGender().trim());
        }
        if (member.getPhoneNumber() != null) {
            member.setPhoneNumber(member.getPhoneNumber().trim());
        }
        if (member.getAddress() != null) {
            member.setAddress(member.getAddress().trim());
        }
        if (member.getAssetStatus() != null) {
            member.setAssetStatus(member.getAssetStatus().trim());
        }
        if (member.getMembershipLevel() != null) {
            member.setMembershipLevel(member.getMembershipLevel().trim());
        }
        if (member.getLoginId() == null || member.getLoginId().isBlank()) {
            throw new IllegalArgumentException("아이디를 입력해주세요.");
        }
        if (member.getPassword() == null || member.getPassword().isBlank()) {
            throw new IllegalArgumentException("비밀번호를 입력해주세요.");
        }
        if (member.getName() == null || member.getName().isBlank()) {
            throw new IllegalArgumentException("이름을 입력해주세요.");
        }
        if (member.getGender() == null || member.getGender().isBlank()) {
            throw new IllegalArgumentException("성별을 선택해주세요.");
        }
        if (member.getPhoneNumber() == null || member.getPhoneNumber().isBlank()) {
            throw new IllegalArgumentException("연락처를 입력해주세요.");
        }
        if (member.getMembershipLevel() == null || member.getMembershipLevel().isBlank()) {
            member.setMembershipLevel("스탠다드");
        }
        if (memberRepository.existsByLoginId(member.getLoginId())) {
            throw new IllegalArgumentException("이미 사용 중인 아이디입니다.");
        }
    }
}