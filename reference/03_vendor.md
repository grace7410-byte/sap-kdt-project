# 공급업체(벤더)관리 오브젝트 카탈로그

FS 문서: `03. 밴더관리_FS_v10` · RAP 방식: Managed / V4 OData / With Draft

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07LFA1` | - | 공급업체 마스터 (UUID PK, 공급업체번호/분류/조정계정 등) | - |
| Root BO | `ZR_B07_LFA1` | ZTB07LFA1 | RAP Root Entity (Text Table 없음) | - |
| Projection | `ZC_B07_LFA1` | ZR_B07_LFA1 | OData V4 노출용 Root | - |
| Behavior Definition | `ZR_B07_LFA1` / `ZC_B07_LFA1` | - | Managed, with draft | - |
| Behavior Implementation | `ZBP_R_B07_LFA1` | - | Validation/Determination 구현 클래스 (공급업체번호 채번 등) | - |
| Metadata Extension | `ZC_B07_LFA1` | - | List Report / Object Page Annotation | - |
| Service Definition | `ZUI_B07_LFA1` | - | ZC_B07_LFA1 expose | - |
| Service Binding | `ZUI_B07_LFA1_V4` | - | OData V4 – UI (Fiori Elements) | - |

## 주요 필드 (ZTB07LFA1)

`lifnr`(공급업체번호) · `name1`(공급업체명) · `waers`(통화, KRW 고정) · `minbw`(최소주문금액) · `fdgrv`(공급업체분류) · `akont`(조정계정) · `loevm`(삭제여부)

### 공급업체 분류 (ZDB07FDGRV)

| 코드 | 의미 |
| --- | --- |
| A1 | 국내지급 (A/P) |
| A2 | 해외지급 (A/P) |
| A3 | 구매처 관계회사 |
| A4 | 주요 공급업체 |
| A5 | 인건비 |
| A6 | 세금 (A/P) |

관련 Search Help: [`ZI_B07_FDGRV_F4`, `ZI_B07_LFA1_F4`](./00_common-searchhelp.md) · 조정계정(`akont`)은 [FI 계정관리](./02_fi-account.md) 참조
