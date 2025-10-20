package edu.sm.app.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import edu.sm.app.dto.Member;
import edu.sm.app.repository.MemberRepository;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;

    @Transactional
    public Member register(Member member) {
        if (member == null) {
            throw new IllegalArgumentException("등록 정보가 제공되지 않았습니다.");
        }
        validateRegistration(member);
        memberRepository.insertMember(member);
        Member persisted = memberRepository.findByLoginId(member.getLoginId());
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
        Member member = memberRepository.findByLoginId(normalizedLoginId);
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