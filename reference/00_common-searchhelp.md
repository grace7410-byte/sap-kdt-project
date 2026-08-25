# 공통 Search Help 오브젝트 카탈로그

FS 문서: `00. 공통(자재타입_SearchHelp)_FS_v10`

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Search Help | `ZI_B07_MTART_F4` | I_MaterialType | 자재타입 Value Help (FERT/HALB/ROH/HAWA/HIBE/VERP만 노출) | [`ZI_B07_MTART_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_MTART_F4.ddls.asddls) |
| Search Help | `ZI_B07_WERKS_F4` | T001W + T001K | 플랜트 Value Help (회사코드 K200 기준, 필드별 검색조건/라벨 완료, I_Plant로 재작성 예정) | [`ZI_B07_WERKS_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_WERKS_F4.ddls.asddls) |
| Search Help | `ZI_B07_LGORT_F4` | I_StorageLocation | 저장위치 Value Help (플랜트에 종속, 필드별 검색조건/라벨 완료) | [`ZI_B07_LGORT_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_LGORT_F4.ddls.asddls) |
| Search Help | `ZI_B07_BKLAS_F4` | T025T | 평가클래스 Value Help (3000/3300/7900/7920, T025T 기반으로 재작성) | [`ZI_B07_BKLAS_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_BKLAS_F4.ddls.asddls) |
| Search Help | `ZI_B07_MEINS_F4` | T006A | 단위 Value Help (BAG/EA/G/KG만 노출) | [`ZI_B07_MEINS_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_MEINS_F4.ddls.asddls) |
| Search Help | `ZI_B07_SPRAS_F4` | ZTB07MARA_T + T002 + T002T | 언어 Value Help (사용중인 언어키 기준 KO/EN 텍스트) | [`ZI_B07_SPRAS_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_SPRAS_F4.ddls.asddls) |
| Search Help | `ZI_B07_GLACT_F4` | I_DomainFixedValueText (GLACCOUNT_TYPE) | 계정타입 Value Help | [`ZI_B07_GLACT_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_GLACT_F4.ddls.asddls) |
| Search Help | `ZI_B07_KTOSL_F4` | ZTB07T030A | 회계결정코드(트랜잭션키) Value Help (BSX/WRX/PRD 등) | [`ZI_B07_KTOSL_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_KTOSL_F4.ddls.asddls) |
| Search Help | `ZI_B07_SAKNR_F4` | ZTB07SKA1 + ZTB07SKA1_T | FI 계정번호 Value Help | [`ZI_B07_SAKNR_F4.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/00_common-searchhelp/cds/ZI_B07_SAKNR_F4.ddls.asddls) |
| Search Help | `ZI_B07_BSCHL_F4` | - | 전기키 Value Help | - |
| Search Help | `ZI_B07_SHKZG_F4` | - | 차/대변 Value Help | - |
| Search Help | `ZI_B07_FDGRV_F4` | - | 공급업체 분류 Value Help | - |
| Search Help | `ZI_B07_LFA1_F4` | ZTB07LFA1 | 공급업체 Value Help | - |
| Search Help | `ZI_B07_MATNR_F4` | ZTB07MARA | 자재번호 Value Help | - |

> 네이밍 규칙: `ZI_B##_<Name>_F4`
