# SAP S/4HANA RAP 프로젝트 Technical Specification

- **문서 유형:** Technical Specification
- **작성일:** 2026-08-24
- **버전:** v1.0 (중간평가 1차 제출본)
- **플랫폼:** S/4HANA (RAP – Managed)
- **대상 오브젝트:** 00.공통(자재타입/SearchHelp), 01.자재관리, 02.FI계정관리, 03.벤더관리, 04.회계계정결정관리
- **작성자:** 박가을 (B07)
- **기준 개발기간:** 2026-08-12 ~ 2026-08-21
- **상태:** 작성 중 (1차 중간평가)

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
6. [종합 – 오류 해결 이력](./README.md#errorlog)
7. [잔여 이슈 (다음 중간평가 반영 예정)](./README.md#remainingissues)

## 개발 진행 척도 (2026-08-24 기준)

| 영역 | FS 문서 | 진행 상태 |
| --- | --- | --- |
| 00. 공통 | 00_공통_자재타입_SearchHelp_FS | 12개 중 11개 생성 완료 (추가 서치헬프 구현 완료) |
| 01. 자재관리 | 01_자재관리_FS | CDS View·Object Page·UI 완료, Behavior(필드제어/Determination/Validation) 및 오류(무한루프, 통화) 해결 완료 |
| 02. FI계정관리 | 02_FI계정관리_FS | CDS View·UI 완료, FS 명시 필수요건 반영 완료 |
| 03. 벤더관리 | 03_밴더관리_FS | CDS View·UI·Behavior(Draft, 자동채번) 완료, 채번 오류 해결 완료 |
| 04. 회계계정결정관리 | 04_회계계정결정관리_FS | CDS View·UI·Behavior(순번 자동채번, 계정 검증) 완료 |
| 05. 구매정보레코드 | 05_구매정보레코드관리_FS | Table 및 CDS View 진행중 |

각 모듈 문서 안의 코드 링크는 원칙적으로 두 곳을 함께 건다: 해당 FS/오브젝트가 정리된 `reference/` 카탈로그 문서, 그리고 실제 코드가 있는 `src/` 파일("코드 보기"). src에 아직 반영되지 않은 오브젝트는 코드 보기 링크를 생략한다.

> *슬라이드쇼에서 link를 누르면 해당 페이지로 이동합니다.*


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

- **[00]** 잔여 Search Help 1개 이상 최종 적용 (공급업체 Lifnr 등) — [`00_common-searchhelp`](../reference/00_common-searchhelp.md)
- **[01]** 테스트(2차) 진행 예정 — [`01_material-mgmt`](../reference/01_material-mgmt.md)
- **[02]** FS 자체에 구체적 지정 요건이 없어 필드제어만으로 FS 요건은 충족했다고 판단. 권장 추가 로직으로 04에서 정립한 `CheckAccountExist` 패턴을 적용해 Validation/Determination 추가 예정 — [`02_fi-account`](../reference/02_fi-account.md)
- **[03]** 테스트(2차) 진행 예정 — [`03_vendor`](../reference/03_vendor.md)
- **[04]** 로직 점검 테스트(1차) 진행 예정 — [`04_account-determination`](../reference/04_account-determination.md)
- **[05]** 구매정보레코드 FS 미착수 — 현재 테이블 생성 및 서치헬프 진행 중 (src에 아직 반영 없음)
- **[종합]** 다음 중간평가 시 02와 05에서 추가 내역이 반영될 예정이다.
