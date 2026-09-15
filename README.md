# SAP KDT Advanced — 개인 개발 기록

**SAP S/4HANA RAP** (ABAP RESTful Application Programming Model)  
기반 프로젝트를 진행하며 남기는 개인 개발일지 · 오브젝트 카탈로그 · 소스 저장소입니다.

---

## 프로젝트 개요

> 출처: KDT 심화 2기 프로젝트 종합 가이드

**목표**

- Clean Core를 기반으로 한 RAP 애플리케이션 설계 및 구축
- CDS(Core Data Service) & RAP(ABAP RESTful Application Programming Model) 심화 기술 활용
  - CDS View 설계, Association/Composition 활용, OData Service 노출
  - RAP BO(Business Object) 모델링, CRUD 기능 구현
  - UI Annotation을 활용한 Fiori Elements 화면 구성

**배경**

신제품(스마트폰) 출시를 앞두고, 자재 등록 → 구매 → 입고 → 판매 → 출고 → 회계처리까지 이어지는 업무가 자재관리·구매관리·판매관리·회계관리 시스템에 분리되어 있어 데이터 불일치와 비효율이 발생. 이를 SAP RAP 기반의 하나의 통합 시스템으로 구축하는 것이 프로젝트의 출발점.

- Topic 1: 실시간 재고 분석 및 자재 주문 서비스
- Topic 2: 구매이력 분석 및 주문 서비스

**진행 단계**

| 단계 | 내용 |
| --- | --- |
| 분석 | 프로젝트 선정 및 스코핑, AS-IS/TO-BE 분석 |
| 설계 | 데이터 모델링(ERD), 프로세스 모델링(PFD) |
| 구현 | DB/CDS View 구축, RAP 모델(Behavior) 구현, Fiori UI 구성 |
| 테스트 | 단위 테스트, 통합 테스트, 최종 완료 보고 |

**일정**

| 주차 | 내용 |
| --- | --- |
| 1주 | 메인 프로젝트 선정 및 스코핑 |
| 2주 | 데이터/프로세스 모델링 |
| 2~5주 | 데이터베이스 구축 및 단위 프로그램(RAP) 구현 |
| 5~6주 | 단위/통합 테스트 |
| 6주 | 최종완료보고 및 평가 |

기간: 2026.07.20 ~ 2026.09.14 (KDT 심화 2기 전체 일정) · 개발 기간: 2026.08.03 ~ 2026.09.09

---

## 폴더 구조

| 폴더 | 내용 |
| --- | --- |
| [`portfolio/`](./portfolio) | 최종 산출물 — 개인 포트폴리오(재구성 글 + 원본 PDF), 팀 최종 발표(PDF) |
| [`reference/`](./reference) | FS(Functional Spec) 모듈별 오브젝트 네이밍 카탈로그 (이름표) |
| [`src/`](./src) | 실제 소스 코드 (Table / CDS / BDEF / Behavior Implementation) |
| [`devlog/`](./devlog) | 날짜별 개발일지 · 모듈 실습 로그 · 재사용 가이드 |
| [`ts/`](./ts) | Technical Specification — 최초 설계 → FS 비교/분석 → TS 수정·보완 흐름 정리 (중간평가 제출용) |
| [`images/`](./images) | devlog·TS·portfolio 문서용 스크린샷 (하위 폴더로 구분) |

---

## devlog 하위 구분

- **`devlog/rap-dev/`** — CDS/BDEF 등 RAP 오브젝트 개발일지 (문제→해결 중심)
- **`devlog/module-practice/`** — MM/SD/FI 등 트랜잭션 기반 모듈 실습 로그

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
6. 구매정보레코드관리 (EINA/EINE)
7. 구매오더관리 (EKKO/EKPO, RAP + Classic ABAP 병행)
