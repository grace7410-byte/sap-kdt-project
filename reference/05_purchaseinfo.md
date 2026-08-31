# 구매정보레코드관리 오브젝트 카탈로그

FS 문서: `05. 구매정보레코드관리_FS_v10` · RAP 방식: Managed / V4 OData / With Draft

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07EINA` | - | 구매정보레코드 헤더 (UUID PK, 구매정보번호/레코드유형/공급업체/자재/구매조직/구매그룹/기본단위/취소여부/구매정보내역) | [`ZTB07EINA.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/tables/ZTB07EINA.tabl.asddls) |
| Table | `ZTB07EINE` | - | 구매정보레코드 아이템 (UUID+플랜트 PK, 구매가격/가격단위/발주단위/통화/최대구매수량/유효종료일/예정배송일수/취소여부) | [`ZTB07EINE.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/tables/ZTB07EINE.tabl.asddls) |
| Interface | `ZI_B07_EINA` | ZTB07EINA | 헤더 Interface View (05번은 헤더도 Interface로 한 겹 감쌈 — 01~04와 다른 구조) | [`ZI_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZI_B07_EINA.ddls.asddls) |
| Interface | `ZI_B07_EINE` | ZTB07EINE | 아이템 Interface View, `association to parent zr_b07_eina` + 플랜트 텍스트(`_Werks`) 포함 | [`ZI_B07_EINE.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZI_B07_EINE.ddls.asddls) |
| Root BO | `ZR_B07_EINA` | ZI_B07_EINA | RAP Root Entity, Composition(`_Eine`) + 공급업체(`_Lfa1`)/자재(`_Mara`)/레코드유형명(`_EsokzText`) Association 포함 | [`ZR_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZR_B07_EINA.ddls.asddls) |
| Projection | `ZC_B07_EINA` | ZR_B07_EINA | OData V4 노출용 Root (필드순서: 공급업체/자재/구매정보번호, Sort: 구매정보번호→자재→공급업체, 검색조건 2개(공급업체/자재)). Value Help는 아직 보류 | [`ZC_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINA.ddls.asddls) |
| Projection | `ZC_B07_EINE` | ZI_B07_EINE | OData V4 노출용 Item, 플랜트(Werks) Value Help(`ZI_B07_WERKS_F4`)+텍스트 반영 | [`ZC_B07_EINE.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINE.ddls.asddls) |
| Behavior Definition | `ZR_B07_EINA`/`zi_b07_eine` · `ZC_B07_EINA`/`ZC_B07_EINE` | - | Managed, with draft. 헤더: 자동채번(Infnr)/기본값(Esokz·Ekorg·Ekgrp)/필수값·중복·레코드유형 Validation. 아이템: 기본값(Waers·Prdat)/플랜트 존재·가격단위 양수 Validation. **8/30 시점 WIP — 예외 처리·추가 로직은 다음 작업일에 이어서 진행 예정** | [`ZR_B07_EINA.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/bdef/ZR_B07_EINA.bdef.asbdef), [`ZC_B07_EINA.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/bdef/ZC_B07_EINA.bdef.asbdef) |
| Behavior Implementation | `ZBP_R_B07_EINA` | - | `lhc_zr_b07_eina`(헤더): `SetDefaults`/`SetInfnrNumber`/`CheckRequired`/`CheckDuplicate`/`CheckEsokz`. `lhc_eine`(아이템, alias `Eine`): `SetItemDefaults`/`CheckExist`/`CheckPositive`. 미완성 WIP 상태 | [`zbp_r_b07_eina.clas.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap) |
| Metadata Extension | `ZC_B07_EINA` | - | List Report(Infnr/Lifnr/Matnr lineItem) / Object Page(Facet 4개: 구매정보레코드정보/공급업체/자재/아이템) | [`ZC_B07_EINA.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINA.ddlx.asddlx) |
| Metadata Extension | `ZC_B07_EINE` | - | 아이템 Object Page(Facet 1개: 구매정보레코드 아이템, 플랜트/가격정보/수량·일정 필드 배치) | [`ZC_B07_EINE.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINE.ddlx.asddlx) |
| Service Definition | `ZUI_B07_EINA` | - | `ZC_B07_EINA`, `ZC_B07_EINE` expose | [`ZUI_B07_EINA.srvd.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/srv/ZUI_B07_EINA.srvd.asddls) |
| Service Binding | `ZUI_B07_EINA_V4` | - | OData V4 – UI (Fiori Elements), 헤더/아이템 모두 화면 출력 확인 | - |

## 주요 필드

`infnr`(구매정보번호, 연도4자리+6자리 자동채번) · `esokz`(레코드유형, 기본값 '0') · `lif_uuid`/`mat_uuid`(공급업체/자재 FK) · `ekorg`(구매조직, 공급업체 기준 자동설정) · `ekgrp`(구매그룹, 공급업체 기준 자동설정) · `meins`(기본단위) · `loekz`(취소여부) · `txz01`(구매정보내역, CDS에서는 `Irtxt`로 노출) — 이상 헤더(ZTB07EINA)

`werks`(플랜트) · `netpr`(구매가격) · `peinh`(가격단위) · `bprme`(발주단위) · `waers`(통화, 기본값 'KRW' readonly) · `bstma`(최대구매수량) · `prdat`(유효종료일, 기본값 '99991231') · `aplfz`(예정배송일수) · `loekz`(아이템 취소여부) — 이상 아이템(ZTB07EINE)

### 가격 관련 필드 관계 (헷갈리기 쉬움)

`netpr`(구매가격)은 `peinh`(가격단위) 단위당 가격의 총액 — 실제 단가는 `netpr ÷ peinh`이며 이 단가는 `bprme`(발주단위) 1개당 가격이다. `waers`는 `netpr`의 표시 통화. `bstma`(최대구매수량)의 단위는 `bprme`를 따른다(발주단위로 가격을 매겼으니 최대수량도 같은 단위로 관리) — 자재 기본단위(`meins`)가 아니라 발주단위(`bprme`) 기준인 점에 주의.

## Behavior 로직 요약

| 로직 | 대상 | 시점 | 내용 |
| --- | --- | --- | --- |
| `SetDefaults` | 헤더 | Determine on Modify (create) | Esokz 기본값 '0', Ekorg/Ekgrp가 비어있으면 공급업체(`ZTB07LFA1`)의 값으로 자동 채움 |
| `SetInfnrNumber` | 헤더 | Determine on Save (create) | `NUMBER_GET_NEXT`(오브젝트 `ZNRB07_INF`, range '01')로 채번 후 연도(4자리)+뒤 6자리로 구성 |
| `CheckRequired` | 헤더 | Validate on Save | LifUuid/MatUuid/Meins 필수값 체크(생성시 mandatory 대신 validation으로만 체크) |
| `CheckDuplicate` | 헤더 | Validate on Save | 공급업체+자재 조합 중복 체크 |
| `CheckEsokz` | 헤더 | Validate on Save | Esokz가 '0' 이외의 값이면 에러(현재는 레코드유형 '0' 단일 값만 허용) |
| `SetItemDefaults` | 아이템 | Determine on Modify (create) | Waers 기본값 'KRW', Prdat 기본값 '99991231' |
| `CheckExist` | 아이템 | Validate on Save | Werks가 `ZI_B07_WERKS_F4`에 존재하는 플랜트인지 검증 |
| `CheckPositive` | 아이템 | Validate on Save | Peinh(가격단위)가 0 이하이면 에러 |

## 진행 상태 메모 (2026-08-30 기준)

- CDS 4종 + MDE 2종 + Service Definition/Binding까지 완료, 화면(List Report/Object Page, 헤더+아이템)까지 출력 확인.
- BDEF/BIMP는 CRUD 골격 + 위 로직까지는 작성됐지만, "예외 처리 및 추가 로직"은 미완성 — 다음 작업일에 이어서 진행 예정.
- 서치헬프: 헤더 쪽(공급업체/자재/구매단위) Value Help는 아직 보류. 아이템 쪽 플랜트(Werks)는 8/30에 완료.
- 임시 테스트 데이터를 SE16N으로 직접 입력(헤더/아이템 각 3건, UUID는 999/998/997로 임시 채번) — 정식 데이터 아님, 화면 확인용.
- MDE의 Irtxt/Meins가 둘 다 PirInfo qualifier position 30으로 겹쳐 있어 다음 작업 시 확인 필요.

관련 Search Help: [`ZI_B07_WERKS_F4`](./00_common-searchhelp.md) · 공급업체는 [벤더관리](./03_vendor.md), 자재는 [자재관리](./01_material-mgmt.md) 참조
