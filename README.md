# CAL 연구실 웹사이트

국립부경대학교 Control & Automation Lab. 소개 사이트입니다. 빌드 과정이 없는 정적 HTML이라, 파일을 고치고 올리면 바로 반영됩니다.

## 파일 구조

| 파일 | 내용 |
|---|---|
| `index.html` | 홈: 첫 화면, 연구 주제, 최근 과제, 문의 |
| `research.html` | 연구 분야 |
| `projects.html` | 연구 과제 (진행 중인 과제 + 1993년부터 수행한 과제) |
| `papers.html` | 논문 전체 목록 |
| `patents.html` | 특허 전체 목록 |
| `professor.html` | 지도교수 |
| `members.html` | 구성원 (대학원생, 학부생, 졸업생) |
| `gallery.html` | 사진 (연도 탭 → 연도별 앨범) |
| `tools/resize-photos.ps1` | 사진 페이지용 사진 크기 줄이기 |
| `contact.html` | 연락처 (영어판은 `en/contact.html`) |
| `en/` | 위 페이지들의 영어판 (파일 이름 같음). 내용을 고치면 한국어판과 같이 고쳐 주세요 |
| `credits.html` | 사진 출처 |
| `site.css` | 이 사이트 전용 스타일 (몇 줄) |
| `assets/` | 디자인 키트(글꼴 크기, 버튼, 움직임). **수정하지 마세요** |
| `assets/img/` | 사진 |

**상단 메뉴를 바꿀 때**: 메뉴와 바닥글은 페이지마다 복사되어 있습니다. 메뉴 항목을 바꾸면 모든 페이지(한국어 9개 + 영어 8개 + contact, credits)의 `<header>`와 `<footer>`를 같이 고쳐야 합니다.

## 자주 하는 작업

**새 논문 추가**: `papers.html`과 `en/papers.html`의 목록 맨 위에 `<li>` 한 줄을 추가합니다. SCI 논문이면 끝에 `<span class="t-label">SCI</span>`를 붙입니다. 특허(`patents.html`), 과제(`projects.html`)도 같은 방식입니다. 개수가 바뀌면 홈 첫 화면과 각 페이지 설명의 숫자(67편, 28건, 25건)도 고쳐 주세요.

**구성원 추가**: `members.html`에서 `<article class="member">` 블록을 복사해 이름과 과정을 바꾸고, 빈 칸(`<div class="slot">`) 안의 주석 예시처럼 `<img>`를 넣습니다. 사진은 `assets/img/members/`에 두세요(세로 4:5 권장).

**사진 갤러리**: `gallery.html`은 연도마다 `<section class="year" data-year="2015">`, 그 안에 행사마다 `<section class="album">`이 있습니다.
1. 사진을 `assets/img/gallery/연도 행사/` 폴더에 넣습니다 (예: `assets/img/gallery/2026 졸업식/`).
2. **사진 크기를 줄입니다** (아래 "사진 줄이기").
3. 해당 연도 안에 앨범을 추가하고, 사진 한 장마다 아래 한 줄을 넣습니다. `href`와 `src`에 **같은 파일 경로**를 넣으세요.
   `<a class="slot" href="assets/img/gallery/2026 졸업식/01.jpg" target="_blank" rel="noopener"><img src="assets/img/gallery/2026 졸업식/01.jpg" alt="졸업식 사진 1" loading="lazy"></a>`
4. `en/gallery.html`에도 같은 앨범을 넣되, 경로 앞에 `../`를 붙입니다.
5. 새 연도는 위쪽 연도 탭에 `<a href="#2027">2027</a>`, 아래에 `<section class="year" data-year="2027">`를 추가합니다.

**사진 줄이기**: 휴대폰·카메라 원본은 장당 수 MB라 사이트가 느려지고 GitHub 저장소가 커집니다. 사진을 넣은 뒤 **GitHub에 올리기 전에** 사이트 폴더에서 아래를 실행하세요. 긴 변 1600px보다 크거나 500KB가 넘는 사진만 1600px로 줄여 **같은 이름으로 덮어씁니다** (파일 이름이 같아 HTML은 고칠 필요 없음).
   `powershell -ExecutionPolicy Bypass -File tools/resize-photos.ps1`
   (Claude Code 대화창에서는 앞에 `! `를 붙여 실행. 경로는 역슬래시 대신 `/`를 쓰세요)
   원본은 반드시 사이트 폴더 밖에 따로 보관하세요. 한 번 GitHub에 올라간 큰 파일은 나중에 지워도 저장소 기록에 남습니다.

**사진 교체**: 지금 사진 대부분은 Wikimedia Commons의 **임시 사진**입니다. HTML의 `<!-- 사진 교체 -->` 주석이 붙은 자리를 찾아, `assets/img/`에 새 파일을 넣고 `src`/`srcset`과 `alt`(사진 설명)를 바꿉니다. 바꾼 사진은 `credits.html`에서도 지워 주세요. 사진은 가로 1600px 이상, 300KB 이하의 JPG를 권장합니다.

**로컬에서 보기**: 폴더에서 `npx serve .` 또는 `python -m http.server`를 실행한 뒤 브라우저로 엽니다.

## 배포 (GitHub Pages)

1. GitHub에 저장소를 만들고 이 폴더를 push합니다.
2. Settings → Pages → Branch: `main`, 폴더: `/ (root)`로 설정합니다.
3. 몇 분 뒤 `https://<계정>.github.io/<저장소>/`에서 열립니다.
4. 도메인을 연결하면 `index.html`의 `canonical` 주석을 풀어 주세요.
