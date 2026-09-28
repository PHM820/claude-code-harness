---
name: harness
description: 프로젝트 하네스(AI가 일하는 환경) 점검·설치. 새 프로젝트를 시작할 때, 또는 사용자가 /harness로 요청할 때 사용한다. git, CLAUDE_MAP.md, 프로젝트 CLAUDE.md, .claude/verify.cmd(빌드·테스트 검사), .claude/smoke.cmd(실제 실행 확인)를 확인하고 없는 것을 만든다.
argument-hint: [check = 점검만 | 비우면 점검 후 설치]
---

# /harness — 프로젝트 하네스 점검·설치 (v0.9)

목적: AI(관리자·작업자·밤모드)가 사람 없이 일해도 결과를 **기계적으로 검증**하고, **길을 잃지 않게** 하는 최소 환경을 갖춘다.
원칙: 혼자 하는 작은 프로젝트 기준의 **가벼운 하네스**만. 전용 린트 규칙·아키텍처 계층 강제 같은 무거운 장치는 만들지 않는다.

입력: $ARGUMENTS (`check`면 점검 표만 보여주고 아무것도 만들지 않는다)

---

## 1. 대상과 종류 판별

- 대상: 현재 작업 폴더 (프로젝트 루트).
- **여러 저장소가 든 폴더**(현재 폴더엔 `.git`이 없고 하위 폴더들에 `.git`이 있음, 예: 앱·서버가 각각 별도 저장소인 모노레포형 폴더):
  - 루트에는 **git init을 하지 않는다** (하위 저장소를 삼켜 버림). 루트엔 CLAUDE_MAP.md(하위 프로젝트 목록)만.
  - 하위 저장소 **각각을 대상으로** 2~5장을 적용하고, 보고 표도 하위별로 나눈다.
  - 보고서 끝에 권고: "작업할 때는 하위 폴더(예: `프로젝트명\서버-폴더`)에서 세션을 여는 게 좋습니다 — verify·커밋·/delegate가 그 저장소 기준으로 돕니다."
- 저장소는 하나인데 그 안에 독립 하위 프로젝트가 여럿이면(예: 앱 + 서버 폴더) 하나의 대상으로 보고 verify.cmd가 각 하위로 `pushd`/`popd`.
- **새 프로젝트**: 소스 파일이 거의 없음(대략 10개 미만) 또는 사용자가 새 프로젝트라고 말함.
- **기존 프로젝트**: 그 외.

## 2. 점검 (항상 먼저, 읽기만)

| 항목 | 확인 방법 |
|---|---|
| git | `.git` 존재, `git status`로 커밋 안 된 변경 수 |
| .gitignore | 존재 여부, 스택에 맞는 기본 항목(build, node_modules, .env 등) 포함 여부 |
| CLAUDE_MAP.md | 존재 여부, 적힌 경로가 실제로 있는지 3~5개 표본 확인 |
| 프로젝트 CLAUDE.md | 존재 여부 (있으면 내용은 건드리지 않는다) |
| .claude/verify.cmd | 존재 여부. 있으면 1회 실행해 통과/실패 확인 |
| 테스트 | 테스트 폴더·파일 존재 여부 |
| 스택 | pubspec.yaml / build.gradle(.kts) / package.json / requirements.txt·pyproject.toml / 정적 html / Unity 등 |

## 3. 설치 규칙

**기본은 묻지 않고 자동으로 한다** (사용자 결정 2026-09-25: 매번 묻는 게 번거로움). 묻는 건 아래 "여전히 묻는 것" 3가지뿐이고, 나머지는 하고 나서 보고 표로 알린다.

| 항목 | 새 프로젝트 | 기존 프로젝트 |
|---|---|---|
| `git init` + `.gitignore` | **자동** | **자동** (단, 여러 저장소 폴더의 루트는 제외 — 1장) |
| CLAUDE_MAP.md | 자동 (전역 규칙) | 없으면 자동 (전역 규칙이 이미 요구함) |
| 프로젝트 CLAUDE.md | 자동 (4장 템플릿) | 없으면 **자동** (있으면 절대 덮어쓰지 않음) |
| `.claude/verify.cmd` | 스택이 정해지면 자동 | 자동 생성 후 1회 실행 → 결과 보고. 1회 실행이 **3(패키지 설치 안 됨)**이면: lock 파일(`package-lock.json`)이 있으면 **자동으로 `npm ci`**(적힌 버전 그대로 설치, 새 패키지 추가 없음) 후 다시 실행. lock 파일이 없으면 설치하지 않고 "준비 안 됨"으로 보고 |
| `.claude/smoke.cmd` (4-4) | 스택이 정해지면 자동 | 자동 생성 후 1회 실행 → 결과 보고 (건너뜀 3도 정상 보고). **"필요할 때 추가"로 미루지 않는다** — 4-4 표에서 "만들지 않음"인 스택만 예외이고, 그때도 보고 표에 사유를 적는다 |
| `.git/info/exclude`에 `.dlg/`, `.claude/worktrees/` | 해당 없음 (.gitignore에 넣음) | 기존 .gitignore가 이 둘을 무시하지 않으면 **자동 추가** (`git check-ignore -q .dlg/x`로 확인). 사용자 파일은 안 바뀜 |
| 첫 커밋 | 자동: `chore: harness 초기 설정` | 이번에 git init한 경우만 **자동** (되돌리기 기준점). 이미 git이던 저장소에는 커밋하지 않음. 커밋 전 `git status`로 민감 파일(.env, .secrets*, *.keystore, *.jks, *.db) 제외 확인 |
| `docs/decisions.md` | 자동 (빈 표) | 하지 않음 |

**여전히 묻는 것 (이것만):**
1. lock 파일 없이 패키지를 새로 설치해야 하는 경우 (버전이 정해지지 않아 결과가 달라질 수 있음)
2. 이미 git인 저장소에 커밋하는 것 (사용자 작업물과 섞임)
3. 파일 삭제·기존 파일 덮어쓰기 (원래 하지 않음 — 필요해 보이면 보고서에 제안)

원래부터 깨진 검사(예: 깨진 샘플 테스트)는 고치거나 지우지 않고 보고 표의 "알려진 문제"로만 적는다 — 묻느라 멈추지 않는다.

기존 `.gitignore`·CLAUDE.md·verify.cmd가 있으면 **덮어쓰지 않는다.** 부족한 점은 보고서에 제안으로만 적는다.

## 4. 만드는 파일

### 4-1. `.claude/verify.cmd` — 한 번 실행하면 "이 프로젝트가 정상인가"를 답하는 명령

규칙:
- Windows 배치 파일. **주석·메시지는 영어(ASCII)만** (cmd.exe가 UTF-8 한글을 깨뜨릴 수 있음).
- `npm`, `gradlew.bat`, `flutter` 같은 `.cmd/.bat` 도구는 반드시 `call`로 부른다 (안 그러면 스크립트가 거기서 끝나 버림).
- 프로젝트 안의 실행 파일은 **`.\gradlew.bat`처럼 `.\`를 붙인다.** Claude Code는 `NoDefaultCurrentDirectoryInExePath=1`을 켜 두어 cmd가 현재 폴더를 찾지 않는다 (실측: `gradlew.bat`은 실패, `.\gradlew.bat`은 성공).
- 실패하면 0이 아닌 종료 코드: 각 줄 끝에 `|| exit /b 1`.
- 테스트가 아직 없으면 빌드·정적 분석까지만 넣고 `REM TODO: add tests`.

스택별 기본 명령 (아래 6갈래는 실측까지 끝낸 **검증된 빠른 경로**. 이 표에 스택이 없으면 바로 다음 항목의 일반 규칙을 따른다):

| 스택 | verify.cmd 본문 |
|---|---|
| Flutter | `call flutter analyze \|\| exit /b 1` / `call flutter test \|\| exit /b 1` |
| Android (Gradle) | (자바 지정 줄, 아래) + `call .\gradlew.bat assembleDebug testDebugUnitTest \|\| exit /b 1` |
| Node | package.json의 scripts를 보고: 진짜 `test`가 있으면 `call npm test` (npm 기본값 `echo "Error: no test specified" && exit 1`은 **없는 것으로** 본다). 없으면 `lint`와 `build`를 있는 것 모두 차례로 (`call npm run lint \|\| exit /b 1` 등). scripts가 비어 있고 하위 폴더 package.json에 있으면 그쪽을 `pushd`로 |
| Python | 가상환경(`.venv`·`venv`)이 있으면 그 안의 `Scripts\python.exe`를 쓴다. tests 있으면 `python -m pytest -q \|\| exit /b 1`, 없으면 `python -m compileall -q -x "(venv\|\.venv\|node_modules)" . \|\| exit /b 1` |
| 정적 웹 (html/js만) | 자동 검사 없음 → `echo NO AUTOMATED CHECKS - verify in browser` 후 `exit /b 0`, 보고서에 "브라우저 확인 필요"로 표시 |
| Unity / Godot / 기타 엔진 | 만들지 않고 "수동 확인 필요"로 보고 (Godot 표지: `project.godot`, Unity 표지: `ProjectSettings/`) |
| 하위 프로젝트 여러 개 | 루트 verify.cmd가 각 하위로 `pushd`/`popd` 하며 차례로 실행 |

**위 표에 없는 스택 — 매니페스트 감지 후 판단**: 위 6갈래는 예시일 뿐 전체 목록이 아니다. 표에 없는 언어/생태계(Rust, Go, Java/Maven·Gradle-JVM, Ruby, PHP, .NET 등)를 만나면, 그 생태계의 표지 파일(`Cargo.toml`, `go.mod`, `pom.xml`/`build.gradle`(JVM), `Gemfile`, `composer.json`, `*.csproj` 등)로 스택을 식별하고 **그 생태계에서 관용적으로 쓰이는 빌드·테스트 명령**(예: `cargo build`+`cargo test`, `go build ./...`+`go test ./...`, `mvn -q test`, `bundle exec rspec`, `composer install --dry-run`+`phpunit`, `dotnet build`+`dotnet test`)을 verify.cmd에 넣는다. 표의 6갈래와 같은 원칙을 반드시 지킨다: 실패 시 0이 아닌 종료 코드(`|| exit /b 1`), 준비물 미설치는 3(실패 아님), ASCII만, `call`로 감싸기. **만들고 나서 최소 1회 실제로 실행**해 종료 코드가 의도대로 0/1/3을 구분하는지 확인한 뒤에만 확정한다 — 확인 없이 짐작만으로 내놓지 않는다. 어느 생태계인지 특정할 표지 파일조차 없으면 Unity/Godot과 같은 방식으로 "수동 확인 필요"로 보고한다.

Android·Flutter는 Gradle이 쓸 자바를 Android Studio와 맞춘다 (PATH의 다른 자바 버전 때문에 빌드가 깨지는 것 방지). verify.cmd·smoke.cmd의 `@echo off` 다음 줄:
```bat
if not defined JAVA_HOME if exist "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
```

준비물 확인 (Node): verify.cmd·smoke.cmd 맨 앞(`@echo off` 다음)에 넣는다. 패키지가 설치 안 됐으면 "실패"가 아니라 **건너뜀(3)**으로 끝나 "코드 문제"와 "설치 안 됨"이 섞이지 않는다. `if not exist node_modules`로 쓰지 않는다 — /delegate 작업자 worktree에는 node_modules가 없고 상위(원본) 폴더 것을 쓰므로 잘못 건너뛴다. 아래처럼 Node와 같은 방식(상위 폴더로 올라가며)으로 찾는다. `<pkg>`는 lint·build가 쓰는 devDependency 하나(보통 `typescript`, 없으면 `vite` 등 첫 devDependency):
```bat
node -e "const p=require('path'),f=require('fs');let d=process.cwd();for(;;){if(f.existsSync(p.join(d,'node_modules','<pkg>')))process.exit(0);const u=p.dirname(d);if(u===d)process.exit(3);d=u}"
if errorlevel 3 (echo SKIPPED: packages not installed - run npm install & exit /b 3)
```
(실측: 설치된 프로젝트 0, 그 안의 worktree 0, 미설치 폴더 3.) Python도 같은 원칙: 가상환경이 필요한 프로젝트인데 `.venv`·`venv`가 없으면 `exit /b 3`.

**verify.cmd 종료 코드: 0 통과 / 1 실패 / 3 준비 안 됨(검사 못 함).** 3은 실패로 세지 않는다.

예시 (Flutter):
```bat
@echo off
REM Project health check - run by /delegate judge and before reporting work as done.
call flutter analyze || exit /b 1
call flutter test || exit /b 1
echo VERIFY OK
```

### 4-2. 프로젝트 CLAUDE.md (60줄 이내, "지도"형)
```markdown
# <프로젝트 이름>

<한 줄 목표>

## 먼저 볼 것
- 기능별 파일 지도: `CLAUDE_MAP.md`
- 검증: `.claude/verify.cmd` (작업 완료 보고 전에 실행)
- 결정 기록: `docs/decisions.md`

## 실행 방법
- <앱/서버 실행 명령>

## 공통 규칙
- <이름 짓기, 폴더 배치, 에러 처리 방식 — 정해지면 채움>
- 코드를 새로 쓰기 전에: 필요한가 → 이미 있나(재사용) → 표준 라이브러리 → 플랫폼 기능 →
  기존 의존성 → 한 줄로 되나 순으로 확인하고 가능한 가장 앞 단계에서 멈춘다. 단, 입력 검증·
  보안·접근성·데이터 손실 방지는 줄이는 대상이 아니다.

## 막힐 때
- 실패하면 추측으로 재시도하지 않는다. 에러 메시지·로그·중간값을 직접 확인해 원인을 먼저
  확보한 뒤 다음 행동을 정한다.
- 같은 목적으로 2번 실패했으면 3번째 방법을 찾기 전에 "이거 꼭 필요한가, 이미 답이 나온 것
  아닌가"를 먼저 묻는다.
- 검증된 것과 논리로만 맞다고 보는 것을 섞어 보고하지 않는다("A는 실측 확인, B는 미검증"처럼
  구분).

## 하지 말 것
- 키·비밀번호를 코드에 넣지 않는다 (.env 사용)
- 테스트를 건너뛰거나 주석 처리해서 통과시키지 않는다
```
긴 설명은 여기 쓰지 않고 `docs/`로 보낸다 (OpenAI 하네스 사례: 최상위 문서는 짧은 목차 역할).

### 4-3. `.gitignore`
스택별 표준 항목 + 항상: `.env`, `*.keystore`, `*.jks`, `local.properties`, `.claude/settings.local.json`, `.dlg/` (smoke 스크린샷·합치기 패치 저장), `.claude/worktrees/` (/delegate 작업자 복사본).
기존 `.gitignore`에 `.dlg/`·`.claude/worktrees/`가 없으면 `.gitignore`는 건드리지 않고 `.git/info/exclude`(이 컴퓨터에만 적용되는 무시 목록)에 추가한다 — 사용자 파일을 안 바꾸면서 자동 커밋에 섞이는 걸 막는다.

### 4-4. `.claude/smoke.cmd` — 실제로 실행해 보는 확인 (프로젝트별 설계 없이 자동)

verify.cmd(빌드·테스트)는 "코드가 맞는가", smoke는 "**실제로 켜지는가**"를 본다. 스택별 표준 스크립트가 이 스킬 폴더 `smoke/`에 있고, 프로젝트마다 다른 값은 **파일에서 자동으로 읽어** 채운다. 새로 설계하지 않는다.

| 스택 | smoke.cmd 내용 | 자동으로 읽는 값 |
|---|---|---|
| Android | `call .\gradlew.bat assembleDebug` → `smoke\android.ps1` | 패키지: `app/build.gradle(.kts)`의 `applicationId` / APK: `app\build\outputs\apk\debug\app-debug.apk` |
| Flutter | `call flutter build apk --debug` → `smoke\android.ps1` | 패키지: `android/app/build.gradle(.kts)`의 `applicationId` / APK: `build\app\outputs\flutter-apk\app-debug.apk` |
| Node 서버·웹앱 | `smoke\server.ps1` | 시작 명령: scripts의 `dev` → `start` 순 / URL: 설정·.env의 PORT, 없으면 vite=5173, next=3000, 그 외 3000 (추정이면 보고에 "포트 추정" 표시) |
| 정적 웹 (html/js) | 만들지 않음 → 아래 "AI 화면 확인"만 | 시작 페이지: `index.html`. `.claude/launch.json`이 있으면 그 설정으로 브라우저 창에서 열고, 없으면 `python -m http.server <빈 포트> --bind 127.0.0.1`로 띄워서 본 뒤 끈다 |
| Python / Unity / Godot / 기타 | 만들지 않음 → "수동 확인" | 봇처럼 실행하면 외부로 메시지가 나가는 프로그램은 자동 실행 금지 |

smoke.cmd 예시 (Android):
```bat
@echo off
REM Runtime smoke check. Exit: 0 ok, 1 fail, 3 skipped (no device / port busy)
call .\gradlew.bat assembleDebug || exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claude\skills\harness\smoke\android.ps1" -Package com.example.app -Apk "app\build\outputs\apk\debug\app-debug.apk"
exit /b %ERRORLEVEL%
```

종료 코드 약속: **0 통과 / 1 실패 / 3 건너뜀**(기기 없음, 부팅 안 됨, 포트 사용 중). 3은 실패가 아니라 "확인 못 함"으로 보고한다.
- android.ps1은 **에뮬레이터를 스스로 켜지 않는다** (연결된 기기만 사용, 부팅 완료 `sys.boot_completed` 확인 후 진행). 설치 → 실행 → 8초 뒤 프로세스 살아 있는지·crash 로그 확인 → 스크린샷 `.dlg\smoke\screen.png`.
- server.ps1은 서버를 띄워 URL이 응답하는지 보고, **항상 프로세스를 끄고** 끝낸다. 시작 전에 이미 그 포트가 응답하면 건너뜀(3). 응답 코드가 500 미만이면(404 포함) "켜짐"으로 본다 — API 서버는 `/`에 페이지가 없는 게 정상.
- Android 패키지: `applicationId`에 더해 debug 빌드의 `applicationIdSuffix`(예: `.debug`)가 있으면 붙여서 넘긴다. productFlavors가 있으면 APK 경로·패키지를 추정하지 말고 "수동 확인"으로 보고.
- Node 서버가 `.env`를 읽는데 `.env`가 없으면(키가 필요한 경우) smoke.cmd는 만들되 보고에 "환경변수 필요 — 실패해도 코드 문제가 아닐 수 있음"으로 표시한다. 키는 사용자가 직접 넣는다.
- 서버가 켜질 때 외부 호출(스크래핑·주기 작업)을 하는 건 허용하되, **메시지 발송·결제 같은 외부 부작용**이 켜질 때 일어나면 smoke를 만들지 않는다.

### 4-5. AI 화면 확인 (스크립트 없이, 관리자가 직접)
smoke가 통과하면 관리자가 눈으로 한 번 더 본다:
- 앱: `.dlg\smoke\screen.png`를 Read로 열어 첫 화면이 정상인지(빈 화면·에러 문구·깨진 레이아웃) 확인.
- 웹: 앱의 브라우저 창으로 페이지를 열어 **콘솔 에러 0개** 확인 + 화면 확인.
- 보고에는 "AI 화면 확인"으로 따로 적는다. 사용자가 직접 확인하는 수동 체크리스트를 대신하지는 않는다.

### 4-6. 언제 돌리나
| 상황 | verify | smoke + AI 화면 확인 |
|---|---|---|
| 평소 작업 완료 보고 전 | 항상 | UI·화면 파일을 바꿨을 때만 |
| /delegate 최종 판정 | 항상 | UI·화면 파일을 바꿨을 때만 |
| /delegate-all 마일스톤 종료 점검 | 항상 | **항상** |
| 밤모드 | check만 | 하지 않음 (기기·서버를 무인으로 띄우지 않음) |

## 5. 보고

```
하네스 점검 — <프로젝트> (<새 / 기존>, 스택: <...>)
| 항목 | 전 | 후 | 비고 |
|---|---|---|---|
| git | 없음 | 생성 | 첫 커밋 abc123 |
| verify.cmd | 없음 | 생성 | 1회 실행: 통과 / 실패(<에러 요약 1줄>) |
...
알려진 문제 / 제안: <원래 깨진 검사, lock 없는 설치 필요 등 — 없으면 생략>
```
- verify.cmd 1회 실행이 실패해도 파일은 만든다 (프로젝트가 원래 깨져 있을 수 있음). 실패 원인은 추측으로 고치지 않고 에러 요약(실제 에러 메시지 한 줄 포함)만 보고한다.
- **원래부터 깨진 검사가 있으면** 멈추지 않고 "알려진 문제"에 추천안과 함께 적는다 (① 고친다 ② 지운다(템플릿 샘플 등) ③ 당분간 verify에서 뺀다 중 추천 하나). 그대로 두면 verify가 항상 실패해 /delegate 판정이 의미 없다는 점도 한 줄 적는다.
- 준비물이 없으면(verify 3) 3장 표대로 lock 파일이 있을 때만 `npm ci`를 자동 실행한다. 설치는 package.json이 있는 프로젝트마다 한 번이며, 그 안의 하위 폴더는 상위의 node_modules를 쓰므로 따로 필요 없다.
- 직접 실행해 확인한 것 / 파일만 만든 것을 구분해 적는다.

## 6. 기타
- **서브에이전트(작업자·마일스톤 리드)로 실행 중이면 이 스킬을 실행하지 않는다.** 필요해 보이면 리포트의 blocker에 적는다.
- **AskUserQuestion 남발 방지 훅**: 프로젝트 단위가 아니라 Claude Code 전역(`~/.claude/settings.json`의 `hooks.PreToolUse`)에 1회 설치됨 (2026-09-25). `~/.claude/hooks/check-askuserquestion.js`가 옵션 2개 이하+설명 짧은 AskUserQuestion 호출을 자동 차단하고 텍스트 질문으로 유도한다. 차단 이력은 `~/.claude/hooks/mistake-log.jsonl`에 누적 기록(다른 실수 패턴 훅도 같은 로그를 공유하도록 `~/.claude/hooks/lib/mistake-log.js`로 분리). 새 프로젝트마다 설치할 필요 없음 — 이미 전역이라 모든 프로젝트에 자동 적용됨.
- `/delegate-all`이 새 프로젝트 준비 때 이 절차를 호출한다. 그 경우 5장 보고는 /delegate-all의 기획 승인 화면에 합쳐서 한 번만 보여준다.
- 한 세션에서 같은 프로젝트를 두 번 점검하지 않는다 (사용자가 다시 요청한 경우 제외).
- 파일은 BOM 없는 UTF-8로 저장한다 (verify.cmd는 ASCII).
- 밤모드 중에는 `check`만 하고 결과를 기록에 남긴다 (설치는 사용자가 있을 때).
