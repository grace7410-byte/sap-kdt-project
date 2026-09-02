# SAP S/4HANA RAP 프로젝트 Technical Specification

- **문서 유형:** Technical Specification
- **작성일:** 2026-08-24 (v1.0) / 2026-09-01 (v2.0)
- **버전:** v2.0 (중간평가 2차 제출본, 01~05 반영)
- **플랫폼:** S/4HANA (RAP – Managed)
- **대상 오브젝트:** 00.공통(자재타입/SearchHelp), 01.자재관리, 02.FI계정관리, 03.벤더관리, 04.회계계정결정관리, 05.구매정보레코드관리
- **작성자:** 박가을 (B07)
- **기준 개발기간:** 2026-08-12 ~ 2026-09-01 (2차 추가 피드백 반영분 + 05 신규 반영분 기준)
- **상태:** 작성 중 (2차 중간평가) — 01~04 모듈 문서의 "4) 2차 TS 수정·보완 내역" 절이 이번 회차 신규 반영분이다. 05.구매정보레코드관리는 별도 "FS 비교" 단계 없이 "1) 최초 설계"(FS 개요·신규 계층 구조) → "2) TS 수정·보완 내역"(FS 미정의 필드 5종 추가 + 신규 검증 로직 4종) 구성으로 이번에 신규 포함한다(예외 처리·전체 검증 테스트는 아직 WIP — 06과 함께 3차에서 이어서 보완 예정).

## 목적

본 문서는 강사님께서 제공한 5종의 Functional Specification(00.공통, 01.자재관리, 02.FI계정관리, 03.밴더관리, 04.회계계정결정관리)을 기준으로, 실제 설계·개발 과정에서

1. **최초 설계:** FS가 나오기 전 설계 시점 또는 개발 착수 시점에 FS를 아직 정독하지 않은 상태에서 스스로 판단하여 만든 초기 구조
2. **FS 확인 및 비교/분석:** 이후 FS 원문을 재확인하면서 최초 설계와의 차이점을 발견하고, 어떤 케이스에서 왜 FS 방식(혹은 그 이상)이 더 타당한지 분석한 과정
3. **TS 수정·보완:** 위 분석 결과를 반영하여 실제 테이블/CDS View/Behavior/UI를 어떻게 고쳤는지의 흐름을 오브젝트 단위로 정리한 것

을 다룬다. 평가 기준인 "최초 설계 → FS 확인 → 비교/분석 → TS 수정/보완 → 개인 개발"의 과정이 드러나도록, 각 문서는 ① 최초 설계 → ② FS 대비 비교/분석 → ③ 수정·보완 내역(필드/로직/기타) 순서로 구성한다.

## 목차

0. [문서 개요](./README.md) - 이 문서
1. [`[00] 공통` – 자재타입 등 Search Help](./00_common.md)
2. [`[01] 자재관리`](./01_materialmgmt.md)
3. [`[02] FI계정관리`](./02_fiaccount.md)
4. [`[03] 벤더(공급업체)관리`](./03_vendor.md)
5. [`[04] 회계계정결정관리`](./04_accountdetermination.md)
6. [`[05] 구매정보레코드관리`](./05_purchaseinfo.md)
7. [종합 – 오류 해결 이력](./README.md#errorlog)
8. [잔여 이슈 (다음 중간평가 반영 예정)](./README.md#remainingissues)

## 개발 진행 척도 (2026-09-01 기준)

| 영역 | FS 문서 | 진행 상태 |
| --- | --- | --- |
| 00. 공통 | 00_공통_자재타입_SearchHelp_FS | 12개 중 11개 생성 완료 (추가 서치헬프 구현 완료) |
| 01. 자재관리 | 01_자재관리_FS | CDS View·Object Page·UI 완료. 2차: 자재타입-평가클래스 조합 검증(`CheckBklas` 확장), 가격/가격단위 양수 체크(`CheckPositive` 신규) 반영 |
| 02. FI계정관리 | 02_FI계정관리_FS | CDS View·UI 완료. 2차: 계정번호 중복 체크(`CheckDuplicate` 신규), 회사코드/통화/조정계정유형 존재 검증(`CheckExist` 신규) 반영 |
| 03. 벤더관리 | 03_밴더관리_FS | CDS View·UI·Behavior(Draft, 자동채번) 완료. 2차: Value Help 3종 연결, 구매조직/구매그룹 라벨 중복 수정, 거래종료(Loevm) 편집 제어 반영 |
| 04. 회계계정결정관리 | 04_회계계정결정관리_FS | CDS View·UI·Behavior(순번 자동채번, 계정 검증) 완료. 2차: 전기키 F4 선택 시 차/대변 즉시 자동 채움(additionalBinding), 필수·존재 통합 검증(`CheckExist`), 조합 중복 방지(`CheckDuplicate`) 반영 |
| 05. 구매정보레코드 | 05_구매정보레코드관리_FS | CDS 4종+MDE 2종+Service Definition/Binding(헤더+아이템 모두 expose) 완료, Value Help 7종 연결. FS 미정의 필드 5종(Esokz/Ekorg/Ekgrp/Peinh/Bprme) 추가 + 헤더(SetDefaults/CheckDuplicate/CheckEsokz)·아이템(CheckExist) 신규 검증 로직 반영해 이번 2차 TS에 신규 포함. 예외 처리·전체 검증 테스트는 WIP — 06과 함께 3차에서 이어서 보완 예정 |

각 모듈 문서 안의 코드 링크는 원칙적으로 두 곳을 함께 건다: 해당 FS/오브젝트가 정리된 `reference/` 카탈로그 문서, 그리고 실제 코드가 있는 `src/` 파일("코드 보기"). src에 아직 반영되지 않은 오브젝트는 코드 보기 링크를 생략한다.


---


# [종합] 오류 해결 이력 (Reuse 관점) <a id="errorlog"></a>

| 오류 | 원인 | 해결 방식 | 재사용 범위 |
| --- | --- | --- | --- |
| **WAERS 필드 편집 모순** | currencyCode 지정 필드는 정적 readonly 불가 | `field(features:instance)` + `get_instance_features`로 동적 제어 전환 ([`01_material-mgmt`](../reference/01_material-mgmt.md) · [코드 보기](../src/01_material-mgmt/bimp/zbp_r_b07_mara.clas.abap)) | 01 자재 외, 통화 필드를 갖는 모든 모듈에 재사용 가능 |
| **ENDLESS_ON_SAVE_DUMP 무한루프** | 이미 목표값과 동일한 레코드까지 매번 MODIFY하여 Determination 재귀 호출 | 변경이 필요한 레코드만 필터링 후 MODIFY ([`01_material-mgmt`](../reference/01_material-mgmt.md) · [코드 보기](../src/01_material-mgmt/bimp/zbp_r_b07_mara.clas.abap)) | 모든 on-save/on-modify Determination 공통 패턴화 |
| **공급업체 채번 식별성 저하** | 넘버레인지 서브타입으로 접두어를 넣으려면 별도 DE/Domain 필요 | FM 결과값의 뒷자리만 추출 후 코드 레벨에서 접두어(V) 부여 ([`03_vendor`](../reference/03_vendor.md) · [코드 보기](../src/03_vendor/bimp/zbp_r_b07_lfa1.clas.abap)) | 04 등 향후 접두어가 필요한 채번 로직에 재사용 가능 |
| **언어 서치헬프 다국어 혼재** | 언어 텍스트 테이블(T002T)을 마스터 테이블처럼 잘못 조인 | 언어 마스터(T002) → 언어 텍스트(T002T) 2단 조인으로 정정 ([`00_common-searchhelp`](../reference/00_common-searchhelp.md) · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_SPRAS_F4.ddls.asddls)) | 다국어 텍스트가 필요한 모든 F4 Help에 재사용 |
| **Composition Child Key 자동할당 불가** | Fiori가 인스턴스 생성 시점에 Key(Spras)값을 먼저 요구함 | 필드 mandatory 강제 + Validation(부모 저장 시 자식 존재 재검증)으로 우회 ([`01_material-mgmt`](../reference/01_material-mgmt.md) · [코드 보기](../src/01_material-mgmt/bdef/ZR_B07_MARA.bdef.asbdef)) | Text Table 등 언어키를 Key로 갖는 모든 Composition 구조에 재사용 가능 |


---


# 잔여 이슈 (다음 중간평가 반영 예정) <a id="remainingissues"></a>

- **[00]** 공급업체(Lifnr) 서치헬프는 2차에서 신규 생성(`ZI_B07_LIFNR_F4`) 완료 — [`00_common-searchhelp`](../reference/00_common-searchhelp.md)
- **[01]** 2차 피드백(①~③) 반영 완료 — [`01_material-mgmt`](../reference/01_material-mgmt.md)
- **[02]** 1차 잔여 이슈였던 `CheckAccountExist` 패턴 적용을 2차에서 `CheckDuplicate`/`CheckExist`로 반영 완료 — [`02_fi-account`](../reference/02_fi-account.md)
- **[03]** 2차 피드백(①~③) 반영 완료 — [`03_vendor`](../reference/03_vendor.md)
- **[04]** 2차 피드백(①~③) + UX 개선(additionalBinding) 반영 완료 — [`04_account-determination`](../reference/04_account-determination.md)
- **[05]** 구매정보레코드 CDS/MDE/Service(헤더+아이템 expose)/Value Help까지 완료. FS 미정의 필드 5종 추가 + 헤더·아이템 신규 검증 로직(SetDefaults/CheckDuplicate/CheckEsokz/CheckExist)은 이번 2차 TS에 신규 반영했으나, 개별 화면 테스트와 예외 처리는 아직 WIP — [`05_purchase-info`](../reference/05_purchase-info.md) 참고, 3차 때 06과 함께 이어서 정리 예정
- **[종합]** 이번 2차에서 01~04 강사 피드백 반영 + 05 신규 로직 반영까지 완료했다. 다음 3차 중간평가 시 05 테스트 마무리·06 TS가 신규로 반영될 예정이다.
