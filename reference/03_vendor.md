# 공급업체(벤더)관리 오브젝트 카탈로그

FS 문서: `03. 밴더관리_FS_v10` · RAP 방식: Managed / V4 OData / With Draft

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07LFA1` | - | 공급업체 마스터 (UUID PK, 공급업체번호/분류/조정계정 등, Text Table 없음) | [`ZTB07LFA1.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/03_vendor/tables/ZTB07LFA1.tabl.asddls) |
| Root BO | `ZR_B07_LFA1` | ZTB07LFA1 | RAP Root Entity, 공급업체분류/조정계정(SKA1) 텍스트 Association 포함 | [`ZR_B07_LFA1.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/03_vendor/cds/ZR_B07_LFA1.ddls.asddls) |
| Projection | `ZC_B07_LFA1` | ZR_B07_LFA1 | OData V4 노출용 Root (정렬/검색조건/텍스트 반영) | [`ZC_B07_LFA1.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/03_vendor/cds/ZC_B07_LFA1.ddls.asddls) |
| Behavior Definition | `ZR_B07_LFA1` | - | Managed, with draft. Field Control/Determination(초기값)/Validation(필수값)/자동채번 완료 | [`ZR_B07_LFA1.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/03_vendor/bdef/ZR_B07_LFA1.bdef.asbdef) |
| Behavior Implementation | `ZBP_R_B07_LFA1` | - | `SetInitialDefault`(통화 KRW), `CheckInit`(필수값), `SetVendorNumber`(자동채번) 구현 완료 (채번 오류 이슈 남아있음) | [`zbp_r_b07_lfa1.clas.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/03_vendor/bimp/zbp_r_b07_lfa1.clas.abap) |
| Metadata Extension | `ZC_B07_LFA1` | - | List Report / Object Page Annotation | [`ZC_B07_LFA1.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/03_vendor/cds/ZC_B07_LFA1.ddlx.asddlx) |
| Service Definition | `ZUI_B07_LFA1` | - | ZC_B07_LFA1 expose | - |
| Service Binding | `ZUI_B07_LFA1_V4` | - | OData V4 – UI (Fiori Elements) | - |

## 주요 필드 (ZTB07LFA1)

`lifnr`(공급업체번호, 분류별 Number Range 자동채번) · `name1`(공급업체명) · `waers`(통화, KRW 고정) · `minbw`(최소주문금액) · `fdgrv`(공급업체분류) · `akont`(조정계정) · `loevm`(삭제여부)

### 공급업체 분류 (ZDB07FDGRV)

| 코드 | 의미 | 채번 Number Range |
| --- | --- | --- |
| A1 | 국내지급 (A/P) | 01 |
| A2 | 해외지급 (A/P) | 02 |
| A3 | 구매처 관계회사 | 03 |
| A4 | 주요 공급업체 | 04 |
| A5 | 인건비 | 05 |
| A6 | 세금 (A/P) | 06 |

관련 Search Help: [`ZI_B07_FDGRV_F4`, `ZI_B07_LFA1_F4`](./00_common-searchhelp.md) · 조정계정(`akont`)은 [FI 계정관리](./02_fi-account.md) 참조
