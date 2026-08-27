# 회계계정결정관리 오브젝트 카탈로그

FS 문서: `04. 회계계정결정관리_FS_v10` · RAP 방식: Managed / V2 OData (No Draft)

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07T030` | - | 회계결정코드 마스터 (이동유형/순번 PK, 전기키/차대변 필드 포함) | [`ZTB07T030.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/04_account-determination/tables/ZTB07T030.tabl.asddls) |
| Root BO | `ZR_B07_T030` | ZTB07T030 | RAP Root Entity, 이동유형/트랜잭션키/평가클래스/계정/전기키/차대변 텍스트 Association 6개 포함 | [`ZR_B07_T030.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/04_account-determination/cds/ZR_B07_T030.ddls.asddls) |
| Projection | `ZC_B07_T030` | ZR_B07_T030 | OData V2 노출용 Root (검색조건/정렬/텍스트 어노테이션 포함. 2026-08-25 전기키 F4에 additionalBinding 추가해 선택 즉시 차/대변 자동 채움, 차/대변 필드는 readOnly) | [`ZC_B07_T030.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/04_account-determination/cds/ZC_B07_T030.ddls.asddls) |
| Behavior Definition | `ZR_B07_T030` / `ZC_B07_T030` | ZTB07T030 | Managed, strict(2), No Draft | [`ZR_B07_T030.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/04_account-determination/bdef/ZR_B07_T030.bdef.asbdef), [`ZC_B07_T030.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/04_account-determination/bdef/ZC_B07_T030.bdef.asbdef) |
| Behavior Implementation | `ZBP_R_B07_T030` | - | 순번 자동채번, 계정 존재 검증, 차/대변 텍스트 결정. `CheckExist`(평가클래스/전기키/차대변/회계결정코드 필수값+존재 여부), `CheckDuplicate`(이동유형+회계결정코드+평가클래스+계정 조합 중복 체크, 2026-08-26 신규) | [`zbp_r_b07_t030.clas.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/04_account-determination/bimp/zbp_r_b07_t030.clas.abap) |
| Metadata Extension | `ZC_B07_T030` | - | List Report / Object Page Annotation (facet 2개: 회계결정정보/계정정보) | [`ZC_B07_T030.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/04_account-determination/cds/ZC_B07_T030.ddlx.asddlx) |
| Service Definition | `ZUI_B07_T030` | - | ZC_B07_T030 expose | - |
| Service Binding | `ZUI_B07_T030_V2` | - | OData V2 – UI (Fiori Elements) | - |

## 주요 필드 (ZTB07T030)

`bwart`(이동유형) · `seqnr`(순번, 이동유형별 자동 채번) · `ktosl`(회계결정코드: BSX/WRX/PRD 등) · `bklas`(평가클래스) · `bschl`(전기키) · `shkzg`(차/대변) · `saknr`(FI 계정번호)

## Behavior 로직 요약

| 로직 | 시점 | 내용 |
| --- | --- | --- |
| `SetSequenceNumber` | Determine on Save (create) | 동일 이동유형(`bwart`) 내 DB/배치 최대 순번 + 1로 자동 채번 |
| `CheckAccountExist` | Validate on Save | `saknr`이 `ZTB07SKA1`에 존재하는 FI 계정인지 검증 |
| `SetShkzg` | Determine on Modify (field Bschl) | 전기키(`bschl`) 도메인 텍스트(`ZDB07BSCHL`)를 조회해 차/대변(`shkzg`) 자동 설정 (저장 시점 fallback). 2026-08-25부터는 `ZC_B07_T030`의 `additionalBinding`으로 F4 선택 즉시 화면에서 채워짐 |
| `CheckExist` | Validate on Save | `bklas`/`bschl`/`shkzg`/`ktosl` 필수값 체크 + 각 서치헬프 뷰(`ZI_B07_BKLAS_F4`/`ZI_B07_BSCHL_F4`/`ZI_B07_SHKZG_F4`/`ZI_B07_KTOSL_F4`) 기준 존재 여부 검증 (2026-08-26 신규) |
| `CheckDuplicate` | Validate on Save | `bwart`+`ktosl`+`bklas`+`saknr` 조합이 기존 레코드와 완전히 동일하면 저장 차단 (2026-08-26 신규, `seqnr`이 Key라 조합 중복이 걸러지지 않던 문제 해결) |

관련 Search Help: [`ZI_B07_BWART_F4`, `ZI_B07_KTOSL_F4`, `ZI_B07_SAKNR_F4`, `ZI_B07_GLACT_F4`, `ZI_B07_BSCHL_F4`, `ZI_B07_SHKZG_F4`](./00_common-searchhelp.md) · 계정번호는 [FI 계정관리](./02_fi-account.md) 참조
