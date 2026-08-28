# 구매정보레코드관리 오브젝트 카탈로그

FS 문서: `05. 구매정보레코드관리_FS_v10` · RAP 방식: Managed / V4 OData / With Draft

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07EINA` | - | 구매정보레코드 헤더 (UUID PK, 구매정보번호/레코드유형/공급업체/자재/구매조직/구매그룹/기본단위/취소여부) | [`ZTB07EINA.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/tables/ZTB07EINA.tabl.asddls) |
| Table | `ZTB07EINE` | - | 구매정보레코드 아이템 (UUID+플랜트 PK, 구매가격/가격단위/발주단위/통화/최대구매수량/유효종료일/예정배송일수) | [`ZTB07EINE.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/tables/ZTB07EINE.tabl.asddls) |
| Interface | `ZI_B07_EINA` | ZTB07EINA | 헤더 Interface View (05번은 헤더도 Interface로 한 겹 감쌈 — 01~04와 다른 구조) | [`ZI_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZI_B07_EINA.ddls.asddls) |
| Interface | `ZI_B07_EINE` | ZTB07EINE | 아이템 Interface View, `association to parent zr_b07_eina` 포함 | [`ZI_B07_EINE.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZI_B07_EINE.ddls.asddls) |
| Root BO | `ZR_B07_EINA` | ZI_B07_EINA | RAP Root Entity, Text Table Composition(`_Eine`) + 공급업체(`_Lfa1`)/자재(`_Mara`) Association 포함. **Esotx(레코드유형명) association은 아직 미완성(TODO)** | [`ZR_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZR_B07_EINA.ddls.asddls) |
| Projection | `ZC_B07_EINA` | ZR_B07_EINA | OData V4 노출용 Root (필드순서: 공급업체/자재/구매정보번호, Sort: 구매정보번호→자재→공급업체, 검색조건 2개(공급업체/자재) 반영). Value Help는 아직 보류 | [`ZC_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINA.ddls.asddls) |
| Projection | `ZC_B07_EINE` | ZI_B07_EINE | OData V4 노출용 Item (FS상 EINE 관련 요구사항이 따로 없어 최소 구성만 반영) | [`ZC_B07_EINE.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINE.ddls.asddls) |
| Behavior Definition | `ZR_B07_EINA` / `ZC_B07_EINA` | - | 아직 작성 전 | - |
| Behavior Implementation | `ZBP_R_B07_EINA` | - | 아직 작성 전 | - |
| Metadata Extension | `ZC_B07_EINA` | - | 아직 작성 전. List Report는 Infnr/Lifnr/Matnr 3개만 lineItem, Object Page는 구매정보레코드정보/공급업체/자재/아이템 4개 Facet으로 구상 중 | - |
| Service Definition | `ZUI_B07_EINA` | - | 아직 작성 전 | - |
| Service Binding | `ZUI_B07_EINA_V4` | - | 아직 작성 전 | - |

## 주요 필드

`infnr`(구매정보번호) · `esokz`(레코드유형) · `lif_uuid`/`mat_uuid`(공급업체/자재 FK) · `ekorg`(구매조직) · `ekgrp`(구매그룹) · `meins`(기본단위) · `loekz`(취소여부) — 이상 헤더(ZTB07EINA)

`werks`(플랜트) · `netpr`(구매가격) · `peinh`(가격단위) · `bprme`(발주단위) · `waers`(통화) · `bstma`(최대구매수량) · `prdat`(유효종료일) · `aplfz`(예정배송일수) — 이상 아이템(ZTB07EINE)

### 가격 관련 필드 관계 (헷갈리기 쉬움)

`netpr`(구매가격)은 `peinh`(가격단위) 단위당 가격의 총액 — 실제 단가는 `netpr ÷ peinh`이며 이 단가는 `bprme`(발주단위) 1개당 가격이다. `waers`는 `netpr`의 표시 통화. `bstma`(최대구매수량)의 단위는 `bprme`를 따른다(발주단위로 가격을 매겼으니 최대수량도 같은 단위로 관리) — 자재 기본단위(`meins`)가 아니라 발주단위(`bprme`) 기준인 점에 주의.

## 진행 상태 메모 (2026-08-27 기준)

- CDS 4종(Interface 2, Root 1, Projection 2)까지 초안 완료, BDEF/BIMP/MDE는 미착수.
- Root View의 Esotx(레코드유형명) association 코드가 아직 안 나와서, Projection이 참조하는 Esotx가 비어있는 상태 — 다음 작업 시 반드시 먼저 해결 필요.
- 서치헬프(구매단위/공급업체/자재 Value Help)는 Object Page 작업 시 반영 예정으로 보류.
- 공통 Search Help로 플랜트(`ZI_B07_WERKS_F4`, 기존 재사용) 외 별도 신규 서치헬프는 아직 없음.

관련 Search Help: [`ZI_B07_WERKS_F4`](./00_common-searchhelp.md) · 공급업체는 [벤더관리](./03_vendor.md), 자재는 [자재관리](./01_material-mgmt.md) 참조
