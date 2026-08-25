# SAP KDT Advanced — 개인 개발 기록

**SAP S/4HANA RAP** (ABAP RESTful Application Programming Model)  
기반 프로젝트를 진행하며 남기는 개인 개발일지 · 오브젝트 카탈로그 · 소스 저장소입니다.

---

## 폴더 구조

| 폴더 | 내용 |
| --- | --- |
| [`project/`](./project) | 프로젝트 목표·배경·일정 (KDT 심화 2기 프로젝트 가이드 요약) |
| [`reference/`](./reference) | FS(Functional Spec) 모듈별 오브젝트 네이밍 카탈로그 (이름표) |
| [`src/`](./src) | 실제 소스 코드 (Table / CDS / BDEF / Behavior Implementation) |
| [`devlog/`](./devlog) | 날짜별 개발일지 · 모듈 실습 로그 · 재사용 가이드 |
| `images/` | 개발일지용 스크린샷 (날짜별 하위 폴더) |

---

## devlog 하위 구분

- **`devlog/rap-dev/`** — CDS/BDEF 등 RAP 오브젝트 개발일지 (문제→해결 중심)
- **`devlog/module-practice/`** — MM/SD/FI 등 트랜잭션 기반 모듈 실습 로그
- **`devlog/guides/`** — 날짜와 무관하게 재사용하는 매뉴얼/가이드 (예: 러닝허브 접속법)

각 폴더의 `_template.md`를 복사해서 새 글을 작성합니다.

---

## 오브젝트 네이밍 규칙

| 접두어 | 종류 | 설명 |
| --- | --- | --- |
| `ZTB##XXX` | DB Table | 마스터/트랜잭션 테이블 |
| `ZTB##XXX_T` | Text Table | 다국어 텍스트 테이블 |
| `ZR_B##_XXX` | Root BO View | RAP BO의 Root Entity |
| `ZI_B##_XXX` | Interface View | 타 BO에서 참조하는 인터페이스 뷰 |
| `ZC_B##_XXX` | Projection View | OData로 노출되는 Consumption View |
| `ZBP_R_B##_XXX` / `ZBP_RB##_XXX` | Behavior Implementation | Validation/Determination 구현 클래스 |
| `ZUI_B##_XXX` | Service Definition/Binding | OData 서비스 노출 |
| `ZI_B##_XXX_F4` | Search Help View | Value Help용 CDS |

> 이 프로젝트에서 `##`은 `07`로 고정되어 사용됩니다 (예: `ZR_B07_MARA`).

---

## 다루는 모듈 (FS 기준)

1. 공통 (자재타입 등 Search Help)
2. 자재관리 (MARA)
3. FI 계정관리 (SKA1)
4. 공급업체(벤더)관리 (LFA1)
5. 회계계정결정관리 (T030)
