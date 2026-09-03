# 구매정보레코드관리 오브젝트 카탈로그

FS 문서: `05. 구매정보레코드관리_FS_v10` · RAP 방식: Managed / V4 OData / With Draft

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07EINA` | - | 구매정보레코드 헤더 (UUID PK, 구매정보번호/레코드유형/공급업체/자재/구매조직/구매그룹/기본단위/취소여부/구매정보내역. 2026-09-01 구매정보내역 필드 `txz01`→`irtxt`(데이터엘리먼트 `zeb07irtxt`, 도메인 `ZDB07IRTXT`)로 교체) | [`ZTB07EINA.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/tables/ZTB07EINA.tabl.asddls) |
| Table | `ZTB07EINE` | - | 구매정보레코드 아이템 (UUID+플랜트 PK, 구매가격/가격단위/발주단위/통화/최대구매수량/유효종료일/예정배송일수/취소여부) | [`ZTB07EINE.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/tables/ZTB07EINE.tabl.asddls) |
| Interface | `ZI_B07_EINA` | ZTB07EINA | 헤더 Interface View (05번은 헤더도 Interface로 한 겹 감쌈 — 01~04와 다른 구조) | [`ZI_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZI_B07_EINA.ddls.asddls) |
| Interface | `ZI_B07_EINE` | ZTB07EINE | 아이템 Interface View, `association to parent zr_b07_eina` + 플랜트 텍스트(`_Werks`) 포함 | [`ZI_B07_EINE.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZI_B07_EINE.ddls.asddls) |
| Root BO | `ZR_B07_EINA` | ZI_B07_EINA | RAP Root Entity, Composition(`_Eine`) + 공급업체(`_Lfa1`)/자재(`_Mara`)/레코드유형명(`_EsokzText`) Association 포함. 2026-09-02 구매그룹(Ekgrp) Value Help 연결(T024 필드 자체의 기본 서치헬프 때문에 Projection이 아닌 이 레벨에서 재정의해야 함) | [`ZR_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZR_B07_EINA.ddls.asddls) |
| Projection | `ZC_B07_EINA` | ZR_B07_EINA | OData V4 노출용 Root (필드순서: 공급업체/자재/구매정보번호, Sort: 구매정보번호→자재→공급업체, 검색조건 2개(공급업체/자재)). 2026-09-01 Value Help 6종 연결(Esokz/Lifnr/Matnr/Ekorg/Meins/Irtxt) — Ekgrp는 2026-09-02에 Root View로 이전 | [`ZC_B07_EINA.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINA.ddls.asddls) |
| Projection | `ZC_B07_EINE` | ZI_B07_EINE | OData V4 노출용 Item, 플랜트(Werks) Value Help(`ZI_B07_WERKS_F4`)+텍스트 반영 | [`ZC_B07_EINE.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINE.ddls.asddls) |
| Behavior Definition | `ZR_B07_EINA`/`zi_b07_eine` · `ZC_B07_EINA`/`ZC_B07_EINE` | - | Managed, with draft. 헤더: UUID 변환(`SetVendorMaterialUuid`, 2026-09-02 신규)/자동채번(Infnr)/기본값(Esokz·Ekorg·Ekgrp)/필수값·중복·레코드유형 Validation. 아이템: 기본값(Waers·Prdat)/플랜트 존재·가격단위 양수 Validation + Waers 동적 readonly(`features:instance`). Projection은 `use draft;` + `use action Prepare` 형태로 재작성. **예외 처리·추가 로직은 여전히 WIP** | [`ZR_B07_EINA.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/bdef/ZR_B07_EINA.bdef.asbdef), [`ZC_B07_EINA.bdef.asbdef`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/bdef/ZC_B07_EINA.bdef.asbdef) |
| Behavior Implementation | `ZBP_R_B07_EINA` | - | `lhc_zr_b07_eina`(헤더): `SetVendorMaterialUuid`(신규)/`SetDefaults`/`SetInfnrNumber`(2026-09-02 연도+뒤6자리 가공 제거, 채번 결과 그대로 사용)/`CheckRequired`(2026-09-02 LifUuid/MatUuid 대신 Lifnr/Matnr 검사로 수정 — 진짜 원인이었음)/`CheckDuplicate`/`CheckEsokz`. `lhc_eine`(아이템, alias `Eine`): `SetItemDefaults`/`CheckExist`/`CheckPositive`/`get_instance_features`(Waers). 미완성 WIP 상태 | [`zbp_r_b07_eina.clas.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap) |
| Metadata Extension | `ZC_B07_EINA` | - | List Report(Infnr/Lifnr/Matnr lineItem) / Object Page(Facet 4개: 구매정보레코드정보/공급업체/자재/아이템) | [`ZC_B07_EINA.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINA.ddlx.asddlx) |
| Metadata Extension | `ZC_B07_EINE` | - | 아이템 Object Page(Facet 1개: 구매정보레코드 아이템, 플랜트/가격정보/수량·일정 필드 배치) | [`ZC_B07_EINE.ddlx.asddlx`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/cds/ZC_B07_EINE.ddlx.asddlx) |
| Service Definition | `ZUI_B07_EINA` | - | `ZC_B07_EINA`, `ZC_B07_EINE` expose (아이템 `ZC_B07_EINE` expose 누락으로 아이템 Facet에서 `Unable to find annotationPath undefined` 오류가 발생했었으나 이미 해결되어 현재 코드에는 반영됨) | [`ZUI_B07_EINA.srvd.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/05_purchase-info/srv/ZUI_B07_EINA.srvd.asddls) |
| Service Binding | `ZUI_B07_EINA_V4` | - | OData V4 – UI (Fiori Elements), 헤더/아이템 모두 화면 출력 확인 | - |

## 주요 필드

`infnr`(구매정보번호, `NUMBER_GET_NEXT` 채번 결과를 그대로 사용) · `esokz`(레코드유형, 기본값 '0') · `lif_uuid`/`mat_uuid`(공급업체/자재 FK, `SetVendorMaterialUuid`로 Lifnr/Matnr 입력값을 변환해 채움) · `ekorg`(구매조직, 공급업체 기준 자동설정) · `ekgrp`(구매그룹, 공급업체 기준 자동설정) · `meins`(기본단위) · `loekz`(취소여부) · `irtxt`(구매정보내역, 2026-09-01 `txz01`에서 교체, CDS에서는 `Irtxt`로 노출) — 이상 헤더(ZTB07EINA)

`werks`(플랜트) · `netpr`(구매가격) · `peinh`(가격단위) · `bprme`(발주단위) · `waers`(통화, 기본값 'KRW', `get_instance_features`로 동적 readonly) · `bstma`(최대구매수량) · `prdat`(유효종료일, 기본값 '99991231') · `aplfz`(예정배송일수) · `loekz`(아이템 취소여부) — 이상 아이템(ZTB07EINE)

### 가격 관련 필드 관계 (헷갈리기 쉬움)

`netpr`(구매가격)은 `peinh`(가격단위) 단위당 가격의 총액 — 실제 단가는 `netpr ÷ peinh`이며 이 단가는 `bprme`(발주단위) 1개당 가격이다. `waers`는 `netpr`의 표시 통화. `bstma`(최대구매수량)의 단위는 `bprme`를 따른다(발주단위로 가격을 매겼으니 최대수량도 같은 단위로 관리) — 자재 기본단위(`meins`)가 아니라 발주단위(`bprme`) 기준인 점에 주의.

## Behavior 로직 요약

| 로직 | 대상 | 시점 | 내용 |
| --- | --- | --- | --- |
| `SetVendorMaterialUuid` | 헤더 | Determine on Modify (create) | 화면 입력창(Lifnr/Matnr)은 실제 저장 필드가 아니라 Association 파생 표시용 필드라서, 사용자가 고른 Lifnr/Matnr을 실제 FK(LifUuid/MatUuid)로 변환해 채움. `SetDefaults`보다 먼저 실행되도록 BDEF에서 순서 배치 |
| `SetDefaults` | 헤더 | Determine on Modify (create) | Esokz 기본값 '0', Ekorg/Ekgrp가 비어있으면 공급업체(`ZTB07LFA1`)의 값으로 자동 채움 |
| `SetInfnrNumber` | 헤더 | Determine on Save (create) | `NUMBER_GET_NEXT`(오브젝트 `ZNRB07_INF`, range '01') 채번 결과를 그대로 사용(연도+뒤6자리 가공 로직은 이미 구성된 넘버레인지를 그대로 쓰기로 하며 제거) |
| `CheckRequired` | 헤더 | Validate on Save | Lifnr/Matnr/Meins 필수값 체크. 원래 LifUuid/MatUuid(백엔드 FK)를 검사했었는데, 화면에서 값을 입력해도 UUID는 비어있는 채로 이 검증이 먼저 걸려버려 항상 "필수값 비어있음" 에러가 났던 게 실제 버그의 원인이었음 — 화면 입력 필드(Lifnr/Matnr) 기준으로 수정해 해결 |
| `CheckDuplicate` | 헤더 | Validate on Save | 공급업체+자재 조합 중복 체크 |
| `CheckEsokz` | 헤더 | Validate on Save | Esokz가 '0' 이외의 값이면 에러(현재는 레코드유형 '0' 단일 값만 허용) |
| `SetItemDefaults` | 아이템 | Determine on Modify (create) | Waers 기본값 'KRW', Prdat 기본값 '99991231' |
| `CheckExist` | 아이템 | Validate on Save | Werks가 `ZI_B07_WERKS_F4`에 존재하는 플랜트인지 검증 |
| `CheckPositive` | 아이템 | Validate on Save | Peinh(가격단위)가 0 이하이면 에러 |
| `get_instance_features` | 아이템 | Instance Features | Waers를 동적 readonly 처리(`fc-f-read_only`) — Netpr의 currencyCode 필드라 정적 readonly 불가 |

## 진행 상태 메모 (2026-09-02 기준)

- CDS 4종 + MDE 2종 + Service Definition/Binding(헤더+아이템 모두 expose)까지 완료, 화면(List Report/Object Page, 헤더+아이템)까지 출력 확인.
- 헤더 Value Help 7종(레코드유형/공급업체/자재/구매조직/구매그룹/구매단위/구매정보내역) 전부 연결 완료. 구매그룹(Ekgrp)만 T024 필드 자체의 기본 서치헬프 때문에 Projection이 아닌 Root View에서 재정의.
- 🐛 **해결**: 공급업체/자재 값을 입력해도 `Field Vendor/Material is required and cannot be empty.`로 저장이 막히던 문제 — 진짜 원인은 `CheckRequired`가 화면에 아직 채워지지 않는 백엔드 UUID(LifUuid/MatUuid)를 검사하고 있었던 것. 화면 입력 필드(Lifnr/Matnr) 기준으로 검사하도록 수정하고, UUID 변환은 별도 `SetVendorMaterialUuid` Determination으로 분리해 해결.
- 🐛 **해결**: 구매그룹(Ekgrp) F4 팝업 미동작 — 원인은 `Ldest`(출력장치) 필드에 걸린 Conversion Exit `SPDEV`을 RAP V4 OData가 지원하지 않아 서비스가 내부 에러났던 것. `ZI_B07_EKGRP_F4`에서 `Ldest` 필드를 제거해 해결.
- 🐛 **신규 발견, 미해결**: `SetVendorMaterialUuid`가 존재하지 않는 Lifnr/Matnr 입력값에 대해서는 에러 처리 없이 그냥 넘어가는 문제 — 잘못된 값을 넣어도 LifUuid/MatUuid가 빈 채로 저장이 통과된다(테스트 중 발견: 공급업체 빈 값, 자재 "001"이 의도치 않게 저장됨). `SetVendorMaterialUuid`에 존재 여부 실패 시 에러 처리 추가 + `CheckRequired`의 하이라이트 필드를 `%element-Lifnr`/`%element-Matnr`로 바꾸는 작업이 필요 — 다음 작업일 처리 예정, 아직 코드 미반영.
- 🐛 **보류**: 단위(Meins)에 잘못된 값을 넣었을 때 뜨는 오류 메시지가 "값이 존재하지 않음"이 아니라 형식 오류처럼 표시되는 문제 — 원인 파악 보류.
- Infnr(구매정보번호)이 Create 시 사용자가 직접 입력 가능한 상태로 남아있음(자동채번 필드인데 편집 가능) — readonly 처리 필요, 아직 미착수.
- 서치헬프로 선택한 값의 텍스트(Liftx/Maktx) 자동 매핑 Determination, 저장 시 코드↔텍스트 불일치 검증 Validation은 아직 미착수(TODO).
- Loekz(구매정보 취소) 필드는 FS 요구사항은 아니나, 설계상 생성 시점엔 불필요하다고 판단해 생성 시 readonly 처리하는 Feature Control 추가가 TODO로 남음(자체 판단 항목).
- 임시 테스트 데이터를 SE16N으로 직접 입력(헤더/아이템 각 3건, UUID는 999/998/997로 임시 채번) — 정식 데이터 아님, 화면 확인용.
- MDE의 Irtxt/Meins가 둘 다 PirInfo qualifier position 30으로 겹쳐 있어 다음 작업 시 확인 필요.

관련 Search Help: [`ZI_B07_WERKS_F4`](./00_common-searchhelp.md), [`ZI_B07_EKORG_F4`](./00_common-searchhelp.md), [`ZI_B07_EKGRP_F4`](./00_common-searchhelp.md), [`ZI_B07_ESOKZ_F4`](./00_common-searchhelp.md), [`ZI_B07_IRTXT_F4`](./00_common-searchhelp.md) · 공급업체는 [벤더관리](./03_vendor.md), 자재는 [자재관리](./01_material-mgmt.md) 참조
