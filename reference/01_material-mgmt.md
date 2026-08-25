# 자재관리 오브젝트 카탈로그

FS 문서: `01. 자재관리_FS_v10` · RAP 방식: Managed / V4 OData / With Draft

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07MARA` | - | 자재 마스터 (UUID PK, 자재코드/유형/그룹/가격/보관위치 등) | - |
| Text Table | `ZTB07MARA_T` | - | 자재명 다국어 텍스트 (SPRAS 기반) | - |
| Root BO | `ZR_B07_MARA` | ZTB07MARA | RAP Root Entity, Text Table Composition + 자재타입/플랜트 텍스트 Association 포함 (필드 일부 미반영, 진행중) | [`ZR_B07_MARA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/cds/ZR_B07_MARA.ddls.asddls) |
| Interface | `ZI_B07_MARATEXT` | ZTB07MARA_T | 타 BO에서 자재 Text를 참조할 때 사용하는 인터페이스 뷰 | [`ZI_B07_MARATEXT.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/cds/ZI_B07_MARATEXT.ddls.asddls) |
| Projection | `ZC_B07_MARA` | ZR_B07_MARA | OData V4 노출용 Root (Redirect 완료, 정렬/검색/Value Help 반영) | [`ZC_B07_MARA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/cds/ZC_B07_MARA.ddls.asddls) |
| Projection | `ZC_B07_MARATEXT` | ZI_B07_MARATEXT | OData V4 노출용 Text Child (Redirect 완료) | [`ZC_B07_MARATEXT.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/cds/ZC_B07_MARATEXT.ddls.asddls) |
| Metadata Extension | `ZC_B07_MARA` | - | List Report / Object Page Annotation (lineItem/identification/facet) | [`ZC_B07_MARA.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/cds/ZC_B07_MARA.ddlx.asddlx) |
| Metadata Extension | `ZC_B07_MARATEXT` | - | 자재명 Object Page Annotation | [`ZC_B07_MARATEXT.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/cds/ZC_B07_MARATEXT.ddlx.asddlx) |
| Behavior Definition | `ZR_B07_MARA` / `ZC_B07_MARA` | - | Managed, with draft. WAERS는 동적 features 제어. Validation 5종 중 CheckInit/CheckCreated/CheckSpart 구현됨. `ZI_B07_MARATEXT`(alias MaraText) 자식 Behavior도 포함(재구성, 확인 필요) | [`ZR_B07_MARA.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/bdef/ZR_B07_MARA.bdef.asbdef), [`ZC_B07_MARA.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/bdef/ZC_B07_MARA.bdef.asbdef) |
| Behavior Implementation | `ZBP_R_B07_MARA` | - | `SetInitialDefault`/`SetReadOnly`(무한루프 수정)/`get_instance_features`(조건부)/`SetLanguageDefault`/`CheckSpart` 구현 완료. `CheckMaterial`/`CheckSLoc`은 본문 비어있음, `get_instance_authorizations`도 비어있어 덤프 발생 | [`zbp_r_b07_mara.clas.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/bimp/zbp_r_b07_mara.clas.abap) |
| Service Definition | `ZUI_B07_MARA` | - | ZC_B07_MARA, ZC_B07_MARATEXT expose | [`ZUI_B07_MARA.srvd.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/01_material-mgmt/service/ZUI_B07_MARA.srvd.asddls) |
| Service Binding | `ZUI_B07_MARA_V4` | - | OData V4 – UI (Fiori Elements), 완료 | - |

## 주요 필드 (ZTB07MARA)

`matnr`(자재코드) · `mtart`(자재유형) · `bklas`(평가클래스) · `meins`(기본단위) · `spart`(제품군, 2026-08-21 추가) · `stprs`(표준가격) · `peinh`(가격단위) · `waers`(통화) · `lgort`(보관위치) · `werks`(플랜트) · `ersda`(최초생성일) · `matfi`(변경금지)

관련 Search Help: [`ZI_B07_MTART_F4`, `ZI_B07_WERKS_F4`, `ZI_B07_LGORT_F4`, `ZI_B07_BKLAS_F4`](./00_common-searchhelp.md)
