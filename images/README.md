# images/

devlog·TS 문서용 스크린샷 저장 폴더입니다. 소스별로 하위 폴더를 나눠서 사용하세요.

```
images/
├── devlog/
│   └── 2026-08-25/
│       ├── 01-error.png
│       └── 02-fixed.png
└── ts/
    ├── 01_materialmgmt/
    │   └── checkbklas_error.jpg
    ├── 02_fiaccount/
    ├── 03_vendor/
    └── 04_accountdetermination/
```

- **`images/devlog/`** — devlog 스크린샷. 날짜별 하위 폴더(`YYYY-MM-DD/`)로 관리합니다.
- **`images/ts/`** — TS(Technical Specification) 문서용 스크린샷. `ts/*.md` 파일명과 동일한 모듈별 하위 폴더(`01_materialmgmt/`, `02_fiaccount/` 등)로 관리합니다.

devlog에서는 상대경로로 참조합니다.

```markdown
![오류 화면](../../images/devlog/2026-08-25/01-error.png)
```

ts 문서에서는 상대경로로 참조합니다.

```markdown
![CheckBklas 에러 화면](../images/ts/01_materialmgmt/checkbklas_error.jpg)
```
