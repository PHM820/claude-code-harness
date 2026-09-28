# CLAUDE_MAP — claude-code-harness

AI(관리자·작업자·밤모드)가 사람 없이 일해도 결과를 기계적으로 검증할 수 있게 하는
최소 프로젝트 환경(하네스)을 점검·자동 구축하는 Claude Code 스킬.

## 기능별 지도

| 기능 | 경로 | 설명 |
|---|---|---|
| /harness 스킬 | `skills/harness/SKILL.md` | v0.9. 점검(git·CLAUDE_MAP·CLAUDE.md·verify.cmd·smoke.cmd 존재 확인) → 없는 것 자동 생성. 기본은 묻지 않고 자동, 예외 3가지(lock 없는 설치·기존 저장소 커밋·삭제)만 확인 질문. verify.cmd 종료코드 0/1/3(3=준비 안 됨). 스택별 verify.cmd 생성은 6갈래(Flutter/Android/Node/Python/정적웹/Unity) 검증된 빠른 경로 + 표에 없는 스택은 매니페스트 파일로 식별해 그 생태계 관용 명령을 판단·실행 검증 후 확정하는 일반 규칙(4-1장) |
| 스택별 smoke 스크립트 | `skills/harness/smoke/android.ps1`, `smoke/server.ps1` | 실제로 앱/서버가 켜지는지 확인하는 런타임 스모크 테스트. 값(패키지명·포트 등)은 프로젝트 파일에서 자동 추출 |

## 설치 방법

`skills/harness/`를 `~/.claude/skills/harness/`로 복사. 파일은 BOM 없는 UTF-8, verify.cmd/smoke.cmd 본문은 ASCII만(cmd.exe가 UTF-8 한글을 깨뜨릴 수 있음).

## 관련 프로젝트

[claude-code-delegate](https://github.com/PHM820/claude-code-delegate) — 이 하네스가 만든 verify.cmd/smoke.cmd로 작업자 결과를 판정하는 관리자-작업자 위임 파이프라인. 함께 쓰면 시너지가 있지만 독립적으로도 동작한다.
