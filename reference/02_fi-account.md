# FI 계정관리 오브젝트 카탈로그

FS 문서: `02. FI계정관리_FS_v10` · RAP 방식: Managed / V2 OData (No Draft)

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07SKA1` | - | FI 계정 마스터 (UUID PK, 계정번호/계정유형) | - |
| Text Table | `ZTB07SKA1_T` | - | FI 계정명 다국어 텍스트 (SPRAS 기반) | - |
| Root BO | `ZR_B07_SKA1` | ZTB07SKA1 | RAP Root Entity, Text Table Composition 포함 | - |
| Interface | `ZI_B07_SKA1TEXT` | ZTB07SKA1_T | 타 BO(벤더 BO 등)에서 FI 계정 Text를 참조하는 인터페이스 뷰 | - |
| Projection | `ZC_B07_SKA1` | ZR_B07_SKA1 | OData V2 노출용 Root | - |
| Projection | `ZC_B07_SKA1TEXT` | ZI_B07_SKA1TEXT | OData V2 노출용 Text Child | - |
| Behavior Definition | `ZR_B07_SKA1` / `ZC_B07_SKA1` | - | Managed (No Draft) | - |
| Behavior Implementation | `ZBP_R_B07_SKA1` | - | Validation/Determination 구현 클래스 | - |
| Metadata Extension | `ZC_B07_SKA1` | - | List Report / Object Page Annotation | - |
| Service Definition | `ZUI_B07_SKA1` | - | ZC_B07_SKA1, ZC_B07_SKA1TEXT expose | - |
| Service Binding | `ZUI_B07_SKA1_V2` | - | OData V2 – UI (Fiori Elements) | - |

## 주요 필드 (ZTB07SKA1)

`saknr`(FI 계정코드) · `glact`(FI 계정유형: Balance Sheet / Cash / P&L 등)

관련 Search Help: [`ZI_B07_GLACT_F4`, `ZI_B07_SAKNR_F4`](./00_common-searchhelp.md)
