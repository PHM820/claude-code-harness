# claude-code-harness

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Platform: Windows](https://img.shields.io/badge/platform-Windows-0078D6)

Claude Code용 `/harness` 스킬 — AI(관리자·작업자·자동화 모드)가 사람 없이 일해도 "됐다"는
말을 **종료 코드로** 증명하게 만드는, 프로젝트당 5분짜리 최소 검증 환경이다.

AI 코딩 에이전트가 스스로 "완료했다"고 보고하는 것과, 실제로 빌드·테스트가 통과하는 것 사이엔
간극이 있다. `/harness`는 그 간극을 사람이 매번 확인하지 않아도 되게, `.claude/verify.cmd` 하나로
좁힌다. 없으면 만들고, 있으면 그대로 실행해서 결과만 보고한다.

혼자 하는 작은 프로젝트 기준의 가벼운 하네스만 지향한다. 전용 린트 규칙이나 아키텍처 계층
강제 같은 무거운 장치는 만들지 않는다.

## 자동으로 갖추는 것

없는 것만 골라 만든다 (있으면 손대지 않고 점검만). `/harness` 한 번으로:

- **git init + .gitignore** — 아직 저장소가 아니면
- **CLAUDE_MAP.md** — 기능별 파일 지도를 새로 만든다
- **프로젝트 CLAUDE.md** — 60줄 이내 요약형. 최소성 사다리(새 코드 쓰기 전 재사용·표준
  라이브러리부터 확인), 막혔을 때 추측 재시도 대신 원인부터 확보하는 규칙 등 그동안 여러
  프로젝트에서 반복해 온 **공통 작업 지침을 이 템플릿에 박아서** 매 프로젝트에 자동 배포한다
- **`.claude/verify.cmd`** — 스택을 감지해 빌드·테스트 명령을 채워 생성하고, 만든 즉시 1회
  실행해 종료 코드로 결과를 보고한다(0 통과 / 1 실패 / 3 준비 안 됨)
- **`.claude/smoke.cmd`** — 실제로 앱/서버가 켜지는지 확인하는 런타임 스모크 스크립트를 생성·실행
- **첫 커밋** — 이번에 git init한 경우, 위 결과물을 되돌리기 기준점으로 커밋

## 설치

```bash
# ~/.claude/skills/harness/ 로 복사 (Windows: %USERPROFILE%\.claude\skills\harness\)
git clone https://github.com/PHM820/claude-code-harness.git
cp -r claude-code-harness/skills/harness ~/.claude/skills/harness
```

설치 후 Claude Code에서 `/harness` (점검 후 자동 설치) 또는 `/harness check` (점검만) 실행.

**반드시 위 경로(`~/.claude/skills/harness/`)에 폴더 이름을 `harness` 그대로 설치해야 한다.**
스모크 스크립트를 부르는 절대경로(`%USERPROFILE%\.claude\skills\harness\smoke\...`)가
`SKILL.md`에 하드코딩돼 있어, 다른 이름이나 경로로 설치하면 스모크 테스트가 스크립트를 찾지
못한다.

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
