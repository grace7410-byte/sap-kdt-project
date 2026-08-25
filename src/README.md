# src/ — 실제 소스 코드

FS 모듈별로 폴더를 나누고, 그 안을 오브젝트 타입별 하위 폴더로 구성합니다.

```
src/
├── 00_common-searchhelp/
├── 01_material-mgmt/
├── 02_fi-account/
├── 03_vendor/
└── 04_account-determination/   ← 현재 코드 존재
    ├── tables/
    ├── cds/
    ├── bdef/
    └── bimp/
```

## 확장자 규칙 (ADT 실제 확장자 기준)

| 오브젝트 | ADT 타입 | 확장자 |
| --- | --- | --- |
| DB Table (CDS 기반) | TABL | `.tabl.asddls` |
| CDS View | DDLS | `.ddls.asddls` |
| Metadata Extension | DDLX | `.ddlx.asddlx` |
| Behavior Definition | BDEF | `.bdef.asbdef` |
| Behavior Implementation (클래스) | CLAS | `.clas.abap` |
| Service Definition | SRVD | `.srvd.asddls` |
| Access Control (필요시) | DCLS | `.dcls.asdcls` |

Service Binding은 소스가 없는 설정값이라 별도 파일을 만들지 않고 `reference/`에만 이름을 남깁니다.

새 모듈 코드를 추가할 때는 `reference/`의 해당 모듈 카탈로그에도 코드 경로 링크를 함께 추가해 주세요.

## 버전 관리 규칙

- **`src/` 파일 = 항상 최신 상태.** devlog에서 오브젝트 링크를 누르면 이 최신 코드로 연결됩니다.
- **devlog 본문 = 그 당시 스냅샷.** 작성 시점 코드 그대로 남겨두고 이후 수정하지 않습니다.
- **src 파일을 업데이트할 때마다 파일 최상단에 변경이력을 한 줄 추가**합니다.

```
// ============================================================
// 변경이력
// 2026-08-12  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// 2026-08-13  _Mara association Redirect 처리 — devlog: ../../../devlog/rap-dev/2026-08-13.md
// ============================================================
```

- CDS/BDEF/Table 파일: `//` 주석 사용
- 클래스(`.clas.abap`) 파일: `*` 라인 주석 사용
- 상대경로(`../../../devlog/...`)는 파일 위치 기준(보통 `src/<모듈>/<타입>/` 3단계 아래)으로 작성
