# 자재관리 오브젝트 카탈로그

FS 문서: `01. 자재관리_FS_v10` · RAP 방식: Managed / V4 OData / With Draft

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07MARA` | - | 자재 마스터 (UUID PK, 자재코드/유형/그룹/가격/보관위치 등) | - |
| Text Table | `ZTB07MARA_T` | - | 자재명 다국어 텍스트 (SPRAS 기반) | - |
| Root BO | `ZR_B07_MARA` | ZTB07MARA | RAP Root Entity, Text Table Composition 포함 | - |
| Interface | `ZI_B07_MARATEXT` | ZTB07MARA_T | 타 BO에서 자재 Text를 참조할 때 사용하는 인터페이스 뷰 | - |
| Projection | `ZC_B07_MARA` | ZR_B07_MARA | OData V4 노출용 Root (List Report/Object Page) | - |
| Projection | `ZC_B07_MARATEXT` | ZI_B07_MARATEXT | OData V4 노출용 Text Child | - |
| Behavior Definition | `ZR_B07_MARA` / `ZC_B07_MARA` | - | Managed, with draft | - |
| Behavior Implementation | `ZBP_R_B07_MARA` | - | Validation/Determination 구현 클래스 | - |
| Metadata Extension | `ZC_B07_MARA` | - | List Report / Object Page Annotation | - |
| Service Definition | `ZUI_B07_MARA` | - | ZC_B07_MARA, ZC_B07_MARATEXT expose | - |
| Service Binding | `ZUI_B07_MARA_V4` | - | OData V4 – UI (Fiori Elements) | - |

## 주요 필드 (ZTB07MARA)

`matnr`(자재코드) · `mtart`(자재유형) · `bklas`(평가클래스) · `meins`(기본단위) · `stprs`(표준가격) · `peinh`(가격단위) · `waers`(통화) · `lgort`(보관위치) · `werks`(플랜트) · `ersda`(최초생성일) · `matfi`(변경금지)

관련 Search Help: [`ZI_B07_MTART_F4`, `ZI_B07_WERKS_F4`, `ZI_B07_LGORT_F4`, `ZI_B07_BKLAS_F4`](./00_common-searchhelp.md)
