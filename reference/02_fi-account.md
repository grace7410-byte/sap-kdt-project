# FI 계정관리 오브젝트 카탈로그

FS 문서: `02. FI계정관리_FS_v10` · RAP 방식: Managed / V2 OData (No Draft)

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07SKA1` | - | FI 계정 마스터 (UUID PK, 계정번호/계정유형/회사코드/통화/조정계정유형) | [`ZTB07SKA1.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/tables/ZTB07SKA1.tabl.asddls) |
| Text Table | `ZTB07SKA1_T` | - | FI 계정명 다국어 텍스트 (SPRAS 기반) | [`ZTB07SKA1_T.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/tables/ZTB07SKA1_T.tabl.asddls) |
| Root BO | `ZR_B07_SKA1` | ZTB07SKA1 | RAP Root Entity, Text Table Composition + 계정타입 텍스트 Association 포함 | [`ZR_B07_SKA1.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/cds/ZR_B07_SKA1.ddls.asddls) |
| Interface | `ZI_B07_SKA1TEXT` | ZTB07SKA1_T | 타 BO(벤더 BO 등)에서 FI 계정 Text를 참조하는 인터페이스 뷰 | [`ZI_B07_SKA1TEXT.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/cds/ZI_B07_SKA1TEXT.ddls.asddls) |
| Projection | `ZC_B07_SKA1` | ZR_B07_SKA1 | OData V2 노출용 Root (Redirect/정렬/검색조건 완료) | [`ZC_B07_SKA1.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/cds/ZC_B07_SKA1.ddls.asddls) |
| Projection | `ZC_B07_SKA1TEXT` | ZI_B07_SKA1TEXT | OData V2 노출용 Text Child (Redirect 완료) | [`ZC_B07_SKA1TEXT.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/cds/ZC_B07_SKA1TEXT.ddls.asddls) |
| Behavior Definition | `ZR_B07_SKA1` / `ZC_B07_SKA1` | - | Managed (No Draft). Field Control/Concurrency Control/Mapping 완료, 커스텀 Determination/Validation은 아직 없음 | [`ZR_B07_SKA1.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/bdef/ZR_B07_SKA1.bdef.asbdef), [`ZC_B07_SKA1.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/bdef/ZC_B07_SKA1.bdef.asbdef) |
| Behavior Implementation | `ZBP_R_B07_SKA1` | - | 클래스 지정만 되어 있고 커스텀 로직은 아직 없음 (완전 Managed) | - |
| Metadata Extension | `ZC_B07_SKA1` | - | List Report / Object Page Annotation | [`ZC_B07_SKA1.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/cds/ZC_B07_SKA1.ddlx.asddlx) |
| Metadata Extension | `ZC_B07_SKA1TEXT` | - | 계정명 Object Page Annotation | [`ZC_B07_SKA1TEXT.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/02_fi-account/cds/ZC_B07_SKA1TEXT.ddlx.asddlx) |
| Service Definition | `ZUI_B07_SKA1` | - | ZC_B07_SKA1, ZC_B07_SKA1TEXT expose | - |
| Service Binding | `ZUI_B07_SKA1_V2` | - | OData V2 – UI (Fiori Elements) | - |

## 주요 필드 (ZTB07SKA1)

`saknr`(FI 계정코드) · `glact`(FI 계정유형: Balance Sheet / Cash / P&L 등) · `bukrs`(회사코드) · `waers`(통화) · `mitkz`(조정계정 유형: 하부 서브원장과 연결되는 계정 구분) · `xloev`(삭제여부)

관련 Search Help: [`ZI_B07_GLACT_F4`, `ZI_B07_SAKNR_F4`](./00_common-searchhelp.md)
