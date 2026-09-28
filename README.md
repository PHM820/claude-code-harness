# claude-code-harness

Claude Code용 `/harness` 스킬 — AI(관리자·작업자·자동화 모드)가 사람 없이 일해도 결과를
**기계적으로 검증**할 수 있게, 프로젝트에 최소한의 검증 환경을 점검·자동 구축한다.

혼자 하는 작은 프로젝트 기준의 가벼운 하네스만 지향한다. 전용 린트 규칙이나 아키텍처 계층
강제 같은 무거운 장치는 만들지 않는다.

## 만드는 것

- **git + .gitignore** (없으면)
- **CLAUDE_MAP.md** — 기능별 파일 지도
- **프로젝트 CLAUDE.md** — 60줄 이내 요약형
- **`.claude/verify.cmd`** — 한 번 실행하면 "이 프로젝트가 정상인가"를 종료 코드로 답하는 명령(0 통과 / 1 실패 / 3 준비 안 됨)
- **`.claude/smoke.cmd`** — 실제로 앱/서버가 켜지는지 확인하는 런타임 스모크 테스트

## 설치

```bash
# ~/.claude/skills/harness/ 로 복사 (Windows: %USERPROFILE%\.claude\skills\harness\)
git clone https://github.com/PHM820/claude-code-harness.git
cp -r claude-code-harness/skills/harness ~/.claude/skills/harness
```

설치 후 Claude Code에서 `/harness` (점검 후 자동 설치) 또는 `/harness check` (점검만) 실행.

## 요구사항

- **Windows 전용이다.** `verify.cmd`/`smoke.cmd`는 Windows 배치 파일이고, 스모크 스크립트는 PowerShell로 작성돼 있다. macOS/Linux 지원은 없다.
- Android 검증은 Android Studio가 설치돼 있어야 JBR(내장 Java) 자동 감지가 동작한다.

## 지원 스택

Flutter, Android(Gradle), Node.js, Python, 정적 웹(html/js)은 실측까지 마친 전용 규칙이 있다.
그 외 스택(Rust, Go, Java/Maven, Ruby, PHP, .NET 등)은 매니페스트 파일(`Cargo.toml`, `go.mod` 등)로
식별해 그 생태계의 관용적 빌드·테스트 명령을 판단하고, 실제 실행으로 검증한 뒤 확정하는 일반
규칙을 따른다(SKILL.md 4-1장).

## 함께 쓸 수 있는 것

[claude-code-delegate](https://github.com/PHM820/claude-code-delegate) — 이 하네스가 만든
`verify.cmd`/`smoke.cmd`의 종료 코드로 작업자 결과를 판정하는 관리자-작업자 위임 파이프라인.
필수 의존은 아니며, 없어도 delegate 쪽은 자체 폴백으로 동작한다.

## 라이선스

MIT
