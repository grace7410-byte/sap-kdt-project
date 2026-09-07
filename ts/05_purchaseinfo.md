# [05] 구매정보레코드관리

관련 오브젝트 카탈로그: [`05_purchase-info`](../reference/05_purchase-info.md)

**구현 진행 상황**
1. 헤더(EINA) — 기본값/채번/검증 로직 작성 완료, Search Help 4종(Esokz/Ekorg/Ekgrp/Irtxt) 신규 연결. 저장 시 필수값 오류(Vendor/Material)가 발생하던 진짜 원인을 규명·해결. 잘못된 값 입력 시 예외 처리는 WIP
2. 아이템(EINE) — 기본값/검증 로직 작성 완료, 기본 저장 테스트 확인. 예외 처리는 WIP

## 1) 최초 설계

공급업체·자재를 플랜트별로 조합해 구매가격/최대구매수량/예정배송일수/유효종료일을 관리하는 Purchasing Info Record 기능. 01~04와 달리, 헤더(EINA)도 아이템(EINE)처럼 Interface View를 거쳐 Root로 올라가는 구조를 신규로 채택했다.

```
ZTB07EINA (헤더 테이블)  →  ZI_B07_EINA (헤더 Interface View)  ┐
                                                                ├→ ZR_B07_EINA (Root BO View, Composition으로 결합)
ZTB07EINE (아이템 테이블) →  ZI_B07_EINE (아이템 Interface View) ┘
```

## 2) TS 수정·보완 내역

### 6.2.1. 레코드유형, 가격단위/발주단위, 구매조직/구매그룹 — 신규 Field 추가

FS 2.1 테이블 정의서에는 없지만, FS의 다른 요구사항을 충족하기 위해 필요하다고 판단해 팀이 자체적으로 추가한 필드 5종.

| Field | 변경/추가 이유 |
| --- | --- |
| `Esokz`(레코드유형) | FS 3.3이 "구매정보 레코드타입명 등 필요한 Association 추가"를 요구하지만, 정작 FS 2.1 테이블 정의서에는 레코드유형 코드 필드 자체가 없다는 걸 확인. 텍스트 Association을 구성하려면 참조할 코드 필드가 먼저 있어야 하므로 자체 판단으로 `Esokz`를 신규 추가하고, 이후 `I_Domain*` 기반 텍스트 Association을 이어서 구성하기로 계획 |
| `Ekorg`(구매조직) | 구매정보 레코드는 "어느 구매조직·구매그룹이 이 공급업체-자재 조합을 담당하는지"까지 관리 대상이라고 판단해 추가. 03.벤더관리에서 이미 동일한 목적으로 도입한 필드이나, 05는 헤더(EINA) 레벨에서 별도로 관리해야 하는 정보라 벤더 테이블 필드를 그대로 참조하지 않고 05 자체 필드로 새로 구현 |
| `Ekgrp`(구매그룹) | 위 `Ekorg`와 동일한 맥락 |
| `Peinh`(가격단위) | FS가 요구한 구매가격(`Netpr`)만으로는 "몇 개당 얼마"인지 알 수 없어 실제 단가 계산이 불가능하다고 판단, `Peinh`를 추가해 `Netpr÷Peinh`로 `Bprme` 1개당 단가를 산출하도록 설계 |
| `Bprme`(발주단위) | 실제 발주 시 사용하는 단위(EA/KG/BOX 등)를 별도로 관리해야 최대구매수량(`Bstma`) 등 후속 필드와 단위 기준을 일관되게 맞출 수 있다고 판단해 `Peinh`와 함께 추가 |

관련 오브젝트: [`ZTB07EINA`](../reference/05_purchase-info.md), [`ZTB07EINE`](../reference/05_purchase-info.md) · [코드 보기(헤더)](../src/05_purchase-info/tables/ZTB07EINA.tabl.asddls), [코드 보기(아이템)](../src/05_purchase-info/tables/ZTB07EINE.tabl.asddls)

화면 반영 확인:

<img src="../images/ts/05_purchaseinfo/object_page_fields.png" alt="구매정보레코드 정보 - 레코드유형/구매조직/구매그룹 반영 확인" width="500">

<img src="../images/ts/05_purchaseinfo/item_detail_fields.png" alt="아이템 상세 - 가격단위/발주단위/최대구매수량/유효종료일/예정배송일수 반영 확인" width="500">

> 🐛 위 첫 번째 화면에는 "아이템" Facet에서 `Unable to find annotationPath undefined` 오류가 함께 캡처되어 있다. 아이템 MDE와 Facet/헤더 인포 어노테이션을 모두 갖춰놓고도 뜨지 않아 원인을 찾아본 결과, Service Definition(`ZUI_B07_EINA`)에서 아이템(`ZC_B07_EINE`)까지 expose하지 않은 게 원인이었다. `expose ZC_B07_EINE;` 추가로 해결 완료 — 현재 소스([코드 보기](../src/05_purchase-info/srv/ZUI_B07_EINA.srvd.asddls))에는 반영되어 있다.

### 6.2.2. 동일 공급업체 + 자재 조합 중복 방지 체크 로직 추가 — `CheckDuplicate`

FS의 "공급업체, 자재 관련 필요 체크 로직 구현"이라는 열린 지시를 팀이 "동일 공급업체+자재 조합 중복 방지"로 구체화하여 구현.

- **Method:** [`CheckDuplicate`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap)

```abap
METHOD CheckDuplicate.
  READ ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY zr_b07_eina
      FIELDS ( LifUuid MatUuid )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_eina).
  SELECT inf_uuid, lif_uuid, mat_uuid FROM ztb07eina
    INTO TABLE @DATA(lt_db_data).
  LOOP AT lt_eina INTO DATA(ls_eina)
       WHERE LifUuid IS NOT INITIAL AND MatUuid IS NOT INITIAL.
    DATA(lv_is_dup) = abap_false.
    LOOP AT lt_db_data INTO DATA(ls_db_data)
         WHERE lif_uuid = ls_eina-LifUuid
           AND mat_uuid = ls_eina-MatUuid
           AND inf_uuid <> ls_eina-InfUuid.
      lv_is_dup = abap_true.
      EXIT.
    ENDLOOP.
    IF lv_is_dup = abap_true.
      APPEND VALUE #( %tky = ls_eina-%tky ) TO failed-zr_b07_eina.
      APPEND VALUE #( %tky = ls_eina-%tky
                       %msg = new_message( id = 'ZMSGE_B07'
                                            number   = '017'
                                            v1       = 'Purchase Info Record'
                                            v2       = 'Vendor/Material'
                                            severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_eina.
    ENDIF.
  ENDLOOP.
ENDMETHOD.
```

### 6.2.3. 구매조직/구매그룹 자동 설정 — `SetDefaults`

`Ekorg`/`Ekgrp` 자체가 FS 2.1에 없는 팀 자체 추가 필드이므로, 이 필드에 대한 자동설정 로직 자체가 전부 신규다. 공급업체 마스터(03.벤더관리, `ZTB07LFA1`) 값을 기준으로 자동 설정하도록 구현.

- **Method:** [`SetDefaults`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap)

```abap
METHOD SetDefaults.
  DATA: lt_update TYPE TABLE FOR UPDATE zr_b07_eina.
  READ ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY zr_b07_eina
      FIELDS ( Esokz LifUuid Ekorg Ekgrp )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_eina).
  SELECT lif_uuid, ekorg, ekgrp FROM ztb07lfa1
    INTO TABLE @DATA(lt_db_lfa1).
  LOOP AT lt_eina INTO DATA(ls_eina)
       WHERE Esokz IS INITIAL OR Ekorg IS INITIAL OR Ekgrp IS INITIAL.
    READ TABLE lt_db_lfa1 INTO DATA(ls_db_lfa1) WITH KEY lif_uuid = ls_eina-LifUuid.
    APPEND VALUE #( %tky  = ls_eina-%tky
                     Esokz = COND #( WHEN ls_eina-Esokz IS INITIAL THEN '0' ELSE ls_eina-Esokz )
                     Ekorg = COND #( WHEN ls_eina-Ekorg IS INITIAL THEN ls_db_lfa1-ekorg ELSE ls_eina-Ekorg )
                     Ekgrp = COND #( WHEN ls_eina-Ekgrp IS INITIAL THEN ls_db_lfa1-ekgrp ELSE ls_eina-Ekgrp )
                   ) TO lt_update.
  ENDLOOP.
  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zr_b07_eina IN LOCAL MODE
      ENTITY zr_b07_eina
        UPDATE FIELDS ( Esokz Ekorg Ekgrp )
        WITH lt_update.
  ENDIF.
ENDMETHOD.
```

> 위 코드는 `Esokz`(레코드유형) 기본값 `'0'` 설정도 같은 메서드에서 함께 처리한다 — `Esokz`는 6.2.1에서 신규 추가한 필드, `Ekorg`/`Ekgrp` 자동설정이 이번 항목의 핵심.

### 6.2.4. 레코드유형 값 제한 — `CheckEsokz`

`Esokz`도 FS 2.1에 없는 신규 필드라 이 필드의 값 검증 로직 자체가 신규다. 현재는 `'0'` 외 값이면 에러 처리, 향후 확장 예정.

- **Method:** [`CheckEsokz`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap)

```abap
METHOD CheckEsokz.
  READ ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY zr_b07_eina
      FIELDS ( Esokz )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_eina).
  LOOP AT lt_eina INTO DATA(ls_eina) WHERE Esokz IS NOT INITIAL AND Esokz <> '0'.
    APPEND VALUE #( %tky = ls_eina-%tky ) TO failed-zr_b07_eina.
    APPEND VALUE #( %tky = ls_eina-%tky
                     %element-Esokz = if_abap_behv=>mk-on
                     %msg = new_message( id = 'ZMSGE_B07'
                                          number   = '021'
                                          v1       = 'Purchase Info Category'
                                          v2       = ls_eina-Esokz
                                          severity = if_abap_behv_message=>severity-error ) )
      TO reported-zr_b07_eina.
  ENDLOOP.
ENDMETHOD.
```

> ⚠️ 메시지 [021](../src/message-class.md#021)은 원래 01번 자재관리(`In material type &1, product group &2 cannot be used.`)에서 만든 문구라, 여기서 재사용하면 실제 화면 문구가 "In material type Purchase Info Category, product group 0 cannot be used." 처럼 의미가 맞지 않게 표시된다. 코드는 원문 그대로 옮겼고 임의로 고치지 않았으니, 전용 메시지 번호 신규 채번이 필요한지 확인 바람.

### 6.2.5. 아이템 플랜트 존재 검증 — `CheckExist`

FS의 "공급업체, 자재 관련 필요 체크 로직 구현" 지시를 팀이 "플랜트(Werks)가 실제 존재하는 값인지 검증"으로 구체화 — `ZI_B07_WERKS_F4` 대상으로 존재 여부 확인.

- **Method:** [`CheckExist`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap)

```abap
METHOD CheckExist.
  READ ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY zr_b07_eina
    BY \_Eine
    FIELDS ( Werks )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_eine)
    FAILED DATA(lt_failed_read).
  SELECT plant FROM zi_b07_werks_f4
    INTO TABLE @DATA(lt_db_werks).
  LOOP AT lt_eine INTO DATA(ls_eine) WHERE Werks IS NOT INITIAL.
    READ TABLE lt_db_werks INTO DATA(lv_db_werks) WITH KEY plant = ls_eine-Werks.
    IF sy-subrc <> 0.
      APPEND VALUE #( %tky = ls_eine-%tky ) TO failed-eine.
      APPEND VALUE #( %tky = ls_eine-%tky
                       %element-Werks = if_abap_behv=>mk-on
                       %msg = new_message( id = 'ZMSGE_B07'
                                            number   = '020'
                                            v1       = 'Plant'
                                            v2       = ls_eine-Werks
                                            severity = if_abap_behv_message=>severity-error ) )
        TO reported-eine.
    ENDIF.
  ENDLOOP.
ENDMETHOD.
```

> ⚠️ 메시지 [020](../src/message-class.md#020)도 원래 02번(`&1 &2 is not a real account.`, 계정 전용 문구)에서 만든 것을 재사용한 케이스라 "Plant XXXX is not a real account."처럼 부자연스럽게 표시된다. 마찬가지로 코드는 그대로 두고 여기 남겨둠.

## 3) 3차 TS 수정·보완 내역 (중간평가 3차)

기준 개발기간: 2026-08-30 ~ 2026-09-02. 2차 TS(위 2절, 8/31·9/1 devlog 기준 작성)는 헤더 로직과 아이템의 `CheckExist`(플랜트 검증)까지만 다뤘고, 같은 시기에 이미 작성돼 있었지만 문서화가 빠졌던 아이템 로직 3종(6.3.1)을 이번에 정리해 반영한다. 이어서 9/1~9/2에 새로 진행한 Search Help 확장·트러블슈팅과, 저장 자체를 막고 있던 핵심 버그의 수정을 담는다.

> ※ 아래 3절 전체는 아직 화면 캡처 파일이 준비되지 않아 스크린샷을 넣지 않았다. 실제 캡처가 확보되면 `images/ts/05_purchaseinfo/`에 추가해 기존 관례대로 링크할 예정이다.

### 6.3.1. (아이템) 2차 미문서화분 정리 — `SetItemDefaults` / `CheckPositive` / `get_instance_features`

- **`SetItemDefaults`** (Determine on Modify, create · 2026-08-30 작성) — FS 4.1 "기본 구매 통화를 KRW로 지정하고 Read Only 설정", "유효 종료일은 99991231로 설정" 요구사항을 그대로 구현. 아이템은 Composition Child라 `ENTITY zi_b07_eine`로 직접 접근이 안 되어, BDEF `alias Eine`를 걸고 Root(`zr_b07_eina`)를 거쳐 `ENTITY Eine`으로 접근하는 구조로 구현.

```abap
METHOD SetItemDefaults.
  MODIFY ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY Eine
      UPDATE FIELDS ( Waers Prdat )
      WITH VALUE #( FOR key IN keys
                      ( %tky  = key-%tky
                        Waers = 'KRW'
                        Prdat = '99991231' )
                  ).
ENDMETHOD.
```

- **`CheckPositive`** (Validate on Save, create/update, field Peinh · 2026-08-30 작성) — FS에 없는, 팀 자체 판단 추가. `Netpr÷Peinh`로 실단가를 계산하는 설계(6.2.1)상 `Peinh`가 0 이하면 나눗셈이 의미를 잃는다는 점에서 방어 로직 필요성을 자체적으로 도출.

```abap
METHOD CheckPositive.
  READ ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY zr_b07_eina
    BY \_Eine
    FIELDS ( Peinh )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_eine)
    FAILED DATA(lt_failed_read).
  LOOP AT lt_eine INTO DATA(ls_eine) WHERE Peinh <= 0.
    APPEND VALUE #( %tky = ls_eine-%tky ) TO failed-eine.
    APPEND VALUE #( %tky = ls_eine-%tky
                     %element-Peinh = if_abap_behv=>mk-on
                     %msg = new_message( id = 'ZMSGE_B07'
                                          number   = '022'
                                          v1       = 'Price Unit'
                                          severity = if_abap_behv_message=>severity-error ) )
      TO reported-eine.
  ENDLOOP.
ENDMETHOD.
```

> ⚠️ 메시지 [022](../src/message-class.md#022)는 원래 01번 자재관리 `CheckBklas`(`A material of type &1 cannot have a valuation class of &2.`)에서 만든 문구를 v1만 채워(v2 없이) 재사용한 것이라, 실제 화면 문구는 "A material of type Price Unit cannot have a valuation class of ." 처럼 의미가 맞지 않게 표시된다. 코드는 원문 그대로 옮겼다 — 전용 메시지 번호 신규 채번이 필요한지 확인 바람.

- **`get_instance_features`** (Instance Features, Waers · 2026-08-31 작성) — FS 4.1 "기본 구매 통화를 KRW로 지정하고 Read Only 설정" 요구사항 자체는 있었으나, `field(readonly) Waers`로 정적 구현 시 `Netpr`의 `@Semantics.amount.currencyCode: 'Waers'`와 충돌해 "A static read-only field 'WAERS' is not allowed for an editable amount field" 활성화 에러가 발생. 01 자재관리(`Stprs`/`Waers`)에서 이미 겪은 것과 동일한 패턴임을 파악하고 `field(features:instance)` + `get_instance_features` 동적 제어 방식을 재사용해 해결.

```abap
METHOD get_instance_features.
  READ ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY zr_b07_eina
    BY \_Eine
    FIELDS ( Werks )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_eine).

  result = VALUE #( FOR ls_eine IN lt_eine
                      ( %tky         = ls_eine-%tky
                        %field-Waers = if_abap_behv=>fc-f-read_only ) ).
ENDMETHOD.
```

🧪 테스트: 정적 readonly(완전 텍스트)와 달리, 입력창(Input box) 형태는 유지되면서 편집만 막힌 상태로 렌더링되는 것을 확인.

### 6.3.2. Search Help 4종 신규 생성 (2026-09-01)

FS 5.2는 "구매단위, 공급업체, 자재는 Value Help(Search Help) 적용"이라고만 명시했고, 이 3종은 이미 만들어져 있던 서치헬프(`ZI_B07_MEINS_F4`/`ZI_B07_LIFNR_F4`/`ZI_B07_MATNR_F4`)를 연결하기만 하면 되는 범위였다. 팀은 FS가 언급하지 않은 4종을 자체 판단으로 신규 생성했다.

| Search Help | 대상 필드 | 생성 방식 |
| --- | --- | --- |
| [`ZI_B07_ESOKZ_F4`](../reference/00_common-searchhelp.md) | Esokz(레코드유형) | 도메인 FV 기반 서치헬프인 `ZI_B07_BSCHL_F4`(전기키)를 Duplicate해 도메인만 `ESOKZ`로 교체 · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_ESOKZ_F4.ddls.asddls) |
| [`ZI_B07_EKORG_F4`](../reference/00_common-searchhelp.md) | Ekorg(구매조직) | `T024E`/`T024E_ASSIGN`에 SM30으로 데이터 직접 입력(구매조직 `1000`↔회사코드 `K200`), `concat_with_space`로 회사코드+텍스트 결합 컬럼(`CombinedText`) 구성 · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_EKORG_F4.ddls.asddls) |
| [`ZI_B07_EKGRP_F4`](../reference/00_common-searchhelp.md) | Ekgrp(구매그룹) | `T024`(독립 마스터, 기존 데이터 3건) 기반 생성 — F4 팝업 미동작 트러블슈팅은 6.3.3 참고 · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_EKGRP_F4.ddls.asddls) |
| [`ZI_B07_IRTXT_F4`](../reference/00_common-searchhelp.md) | Irtxt(구매정보내역) | 자유 텍스트 필드에 편의용 서치헬프만 연결(Validation은 의도적으로 미생성 — 목록에 없는 문구도 자유 입력 가능해야 한다는 설계 의도 유지), 신규 Data Element(`zeb07irtxt`)/Domain(`ZDB07IRTXT`) FV 신규 구성 · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_IRTXT_F4.ddls.asddls) |

> Irtxt는 원래 표준 필드명 `txz01`로 구현했으나(8/30), 텍스트류 표준 필드명이 다른 테이블과 겹칠 가능성을 우려해 9/1에 `irtxt`(데이터엘리먼트 `zeb07irtxt`)로 교체했다. FV 건수는 소스 `ZI_B07_IRTXT_F4.ddls.asddls` 상단 주석에 11건으로 적혀 있으나 9/1 devlog에는 "처음엔 11개로 셌는데 최종은 12개"로 기록돼 있어 — 소스 주석과 devlog 기록이 서로 다르다. 어느 쪽이 최종값인지 확인 바람.

관련 오브젝트(Value Help 연결): [`ZC_B07_EINA`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/cds/ZC_B07_EINA.ddls.asddls)

### 6.3.3. Ekgrp Search Help 팝업 미동작 트러블슈팅 (2026-09-01 ~ 09-02)

구매조직(Ekorg) F4는 정상 동작하는데 구매그룹(Ekgrp) F4만 아이콘을 클릭해도 팝업이 열리지 않는 문제. 9/1에 9가지 가설(① CDS Annotation 누락 ② 원천 데이터 부재 ③ Dropdown 용량 설정 ④ CDS 실행/권한/타입 에러 ⑤ Projection/MDE 설정 오류 ⑥ Feature Control 비활성화 ⑦ `additionalBinding` 미보강 ⑧ Service Definition 미노출 ⑨ Gateway 메타데이터 캐시)를 순서대로 검증했으나 전부 기각되어 그날은 미해결로 남겼다.

9/2, Eclipse Gateway 에러 로그를 정리하던 중 가장 최근 에러 전문에서 진짜 원인을 발견했다: `T024`의 `Ldest`(출력장치) 필드에 걸린 SAP 표준 Conversion Exit `SPDEV`을 RAP V4 OData가 지원하지 않아, `Ldest` 필드가 노출되는 순간 서비스가 내부 에러로 죽고 있었다.

- **적용 오브젝트:** [`ZI_B07_EKGRP_F4`](../reference/00_common-searchhelp.md) · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_EKGRP_F4.ddls.asddls)

```abap
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매그룹 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_B07_EKGRP_F4
  as select from t024
{
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
  key ekgrp      as Ekgrp,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 20 }]
      eknam      as Eknam,
      ektel      as Ektel,
      telfx      as Telfx,
      tel_number as TelNumber,
      tel_extens as TelExtens,
      smtp_addr  as SmtpAddr
      // Ldest(출력장치) 필드 제거 — RAP V4가 SPDEV Conversion Exit 미지원, 노출 시 내부 에러
}
```

추가로 `T024`의 `Ekgrp` 필드 자체에 표준 서치헬프(`H_T024`)가 걸려 있어 Projection(`ZC_B07_EINA`)에서 `@Consumption.valueHelpDefinition`을 재정의해도 적용되지 않을 수 있다는 점을 확인, Root View(`ZR_B07_EINA`)로 선언 위치를 옮겨 먼저 낚아채도록 재설계했다.

- **적용 오브젝트:** [`ZR_B07_EINA`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/cds/ZR_B07_EINA.ddls.asddls)

```abap
Ekorg,
// 서치헬프 -> 여기 있는 이유: Ekgrp에 기본 서치헬프가 적용되어 있어서, 미리 낚아채줘야 함
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_EKGRP_F4', element: 'Ekgrp' } }]
Ekgrp,
```

수정 후에도 반영이 안 되는 캐시 문제가 남아, `ZI_B07_EKGRP_F4` 뷰를 참조하는 03/05 쪽 선언을 먼저 주석 처리하고 뷰 자체를 삭제했다가 재생성하는 방식으로 최종 반영했다.

🧪 테스트: 두 F4 모두 정상 동작 확인.

### 6.3.4. `SetVendorMaterialUuid` 신규 (2026-09-02)

FS는 화면에 공급업체/자재 입력란이 있다는 정도만 전제했고, "그 입력값이 실제로 어떤 백엔드 필드에 들어가는지"는 팀이 직접 구조를 파악해서 풀어야 했던 문제였다. 화면의 `Lifnr`/`Matnr` 입력창이 실제 저장 필드가 아니라 Association에서 끌어오는 표시용 파생 필드(`_Lfa1.Lifnr`, `_Mara.Matnr`)라는 점을 파악하고, 사용자가 입력한 코드값을 실제 FK(`LifUuid`/`MatUuid`)로 변환하는 Determination을 신규로 설계했다. BDEF상 `SetDefaults`보다 먼저 실행되도록 순서를 배치했다(UUID 채움 → 기본값 채움 → 채번 순).

- **적용 Method:** [`SetVendorMaterialUuid`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap) · BDEF: [코드 보기](../src/05_purchase-info/bdef/ZR_B07_EINA.bdef.asbdef)

```abap
METHOD SetVendorMaterialUuid.
  DATA: lt_update TYPE TABLE FOR UPDATE zr_b07_eina.
  READ ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY zr_b07_eina
      FIELDS ( LifUuid MatUuid Lifnr Matnr )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_eina).
  SELECT lif_uuid, lifnr FROM ztb07lfa1 INTO TABLE @DATA(lt_db_lfa1).
  SELECT mat_uuid, matnr FROM ztb07mara INTO TABLE @DATA(lt_db_mara).
  LOOP AT lt_eina INTO DATA(ls_eina)
       WHERE ( LifUuid IS INITIAL AND Lifnr IS NOT INITIAL )
          OR ( MatUuid IS INITIAL AND Matnr IS NOT INITIAL ).
    READ TABLE lt_db_lfa1 INTO DATA(ls_db_lfa1) WITH KEY lifnr = ls_eina-Lifnr.
    READ TABLE lt_db_mara INTO DATA(ls_db_mara) WITH KEY matnr = ls_eina-Matnr.
    APPEND VALUE #( %tky    = ls_eina-%tky
                     LifUuid = COND #( WHEN ls_eina-LifUuid IS INITIAL AND sy-subrc = 0
                                       THEN ls_db_lfa1-lif_uuid ELSE ls_eina-LifUuid )
                     MatUuid = COND #( WHEN ls_eina-MatUuid IS INITIAL
                                       THEN ls_db_mara-mat_uuid ELSE ls_eina-MatUuid )
                   ) TO lt_update.
  ENDLOOP.
  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zr_b07_eina IN LOCAL MODE
      ENTITY zr_b07_eina
        UPDATE FIELDS ( LifUuid MatUuid )
        WITH lt_update.
  ENDIF.
ENDMETHOD.
```

> ⚠️ 잔여 이슈: 존재하지 않는 Lifnr/Matnr을 입력해도(`READ TABLE` 실패) 에러 처리 없이 그냥 넘어간다 — 9/2 테스트 중 공급업체 빈 값·자재 `001`이 의도치 않게 저장되는 현상으로 발견됐고, 아직 코드에 반영되지 않았다. 4절(잔여 이슈) 참고.

### 6.3.5. `CheckRequired` 버그 수정 — 저장 자체가 막히던 진짜 원인 (2026-09-02)

FS 4.1 "저장시: 공급업체, 자재, 구매 단위 필수 체크" 요구사항 자체는 있었다. 문제는 어떤 필드를 검사해야 하는지였다 — 8/30 최초 구현은 백엔드 FK인 `LifUuid`/`MatUuid`를 검사하고 있었는데, 사용자가 화면에서 Lifnr/Matnr 값을 입력해도 그 시점엔 UUID가 아직 비어있어 항상 필수값 에러가 먼저 발생하고, 후속 검증(존재 여부 등)에는 도달하지도 못하는 상태였다. 9/1~9/2 이틀간 "서치헬프로 값을 선택해도 `Field Vendor/Material is required and cannot be empty.`로 저장이 막힌다"는 문제로 나타났다.

원인 규명까지 3차 시도를 거쳤다: 1차로 `SetVendorMaterialUuid`(6.3.4)를 신규 작성하면 해결될 거라 예상했으나 그것만으론 부족했고, 2차로 `@ObjectModel.foreignKey.association` 어노테이션 대체를 시도했으나 안 되어 원상복구했으며, 3차로 에러 메시지가 정확히 어느 로직에서 나오는지 역추적한 끝에 `CheckRequired`가 검사하는 필드 자체가 잘못됐음을 발견했다.

- **적용 Method:** [`CheckRequired (수정)`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap)

```abap
METHOD CheckRequired.
  READ ENTITIES OF zr_b07_eina IN LOCAL MODE
    ENTITY zr_b07_eina
*        FIELDS ( LifUuid MatUuid Meins )
*        WITH CORRESPONDING #( keys )
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_eina).
  LOOP AT lt_eina INTO DATA(ls_eina).
*      IF ls_eina-LifUuid IS INITIAL.
    IF ls_eina-Lifnr IS INITIAL.
      APPEND VALUE #( %tky = ls_eina-%tky ) TO failed-zr_b07_eina.
      APPEND VALUE #( %tky = ls_eina-%tky
                      %element-LifUuid = if_abap_behv=>mk-on
                      %msg = new_message( id = 'ZMSGE_B07'
                                          number = '015'
                                          v1 = 'Vendor'
                                          severity = if_abap_behv_message=>severity-error ) )
          TO reported-zr_b07_eina.
    ENDIF.
*      IF ls_eina-MatUuid IS INITIAL.
    IF ls_eina-Matnr IS INITIAL.
      APPEND VALUE #( %tky = ls_eina-%tky ) TO failed-zr_b07_eina.
      APPEND VALUE #( %tky = ls_eina-%tky
                      %element-MatUuid = if_abap_behv=>mk-on
                      %msg = new_message( id = 'ZMSGE_B07'
                                          number = '015'
                                          v1 = 'Material'
                                          severity = if_abap_behv_message=>severity-error ) )
          TO reported-zr_b07_eina.
    ENDIF.
    IF ls_eina-Meins IS INITIAL.
      APPEND VALUE #( %tky = ls_eina-%tky ) TO failed-zr_b07_eina.
      APPEND VALUE #( %tky = ls_eina-%tky
                      %element-Meins = if_abap_behv=>mk-on
                      %msg = new_message( id = 'ZMSGE_B07'
                                          number = '015'
                                          v1 = 'Base Unit'
                                          severity = if_abap_behv_message=>severity-error ) )
          TO reported-zr_b07_eina.
    ENDIF.
  ENDLOOP.
ENDMETHOD.
```
> 메시지 [`015`](../src/message-class.md#015)

> ⚠️ `%element`는 여전히 `LifUuid`/`MatUuid`(백엔드 필드) 기준으로 남아 있다 — 화면 입력 필드인 `Lifnr`/`Matnr`로 바꾸는 작업은 9/2에 발견만 되고 아직 코드에 반영되지 않았다(4절 잔여 이슈 참고). 코드는 원문 그대로 옮겼다.

핵심 원인 요약: 수정 전(UUID 체크)에는 화면에 값을 입력해도 백엔드 UUID가 비어있어 `CheckRequired`의 필수값 에러가 최우선으로 발생했고, 상위 단계인 필수값 에러가 터지면 후속 단계(외래키/Value Help 존재 여부 검증)는 도달하지 못했다. 자연키(Lifnr/Matnr) 체크로 바꾸며 필수값 에러가 해소되니, 다음 검증 단계인 `Meins` 존재 여부 체크가 정상적으로 동작하기 시작했다.

🧪 테스트: 공급업체를 고쳤더니 Vendor 오류가 사라지고 Material 오류만 남아 자재도 동일하게 수정, 이후 저장까지 정상 완료됨을 확인. 저장 이후 공급업체명/구매조직/구매그룹(공급업체 입력 시), 자재명(자재 입력 시)이 채워지는 것도 함께 확인. 아이템 없이도 저장되는 것을 확인.

### 6.3.6. `SetInfnrNumber` 단순화 (2026-09-02)

FS 5.2가 "연도별로 채번해서 저장(예: 2026000005)"이라는 구체적인 포맷 예시를 제시했으나, 팀은 이미 구성해둔 넘버레인지(`ZNRB07_INF`)의 채번 결과를 그대로 쓰는 방향으로 단순화했다 — FS 예시를 그대로 따르지 않고 팀 판단으로 재가공 로직을 제거한 경우다.

- **적용 Method:** [`SetInfnrNumber (수정)`](../reference/05_purchase-info.md) · [코드 보기](../src/05_purchase-info/bimp/zbp_r_b07_eina.clas.abap)

```abap
IF sy-subrc = 0. " 미리 구성해둔 넘버레인지를 그대로 사용(연도+뒤 6자리 가공 로직 제거)
*        DATA(lv_seq)   = substring( val = lv_number
*                            off = strlen( lv_number ) - 6 ).
*        DATA(lv_infnr) = |{ sy-datum(4) }{ lv_seq }|.
  APPEND VALUE #( %tky  = ls_eina-%tky
                   Infnr = lv_number ) TO lt_update.
```

🧪 테스트: 채번 결과가 `5500000000` 형태(넘버레인지 원본)로 저장되는 것을 확인 — 이전 방식(연도+뒤6자리 가공)이 아님을 재검증.

## 4) 잔여 이슈 및 다음 계획

- `SetVendorMaterialUuid`: 존재하지 않는 Lifnr/Matnr 입력 시 에러 처리 없이 그냥 통과되는 문제 — 미해결(6.3.4 참고).
- `CheckRequired`: 에러 하이라이트 필드가 여전히 `%element-LifUuid`/`%element-MatUuid`로 남아 있어, 화면 입력 필드(`%element-Lifnr`/`%element-Matnr`) 기준으로 바꾸는 작업 필요 — 미착수(6.3.5 참고).
- `get_instance_authorizations`: Draft+Managed 조합에서 비어있으면 권한이 안 열린다는 이슈가 있어 채우려 했으나 `%action-Activate` 관련 에러로 보류, 현재 빈 채로 유지.
- 메시지 번호 021(Esokz, 6.2.4)/020(Werks, 6.2.5)/022(Peinh, 6.3.1)가 각각 다른 모듈 문구를 재사용해 실제 화면 문구가 부자연스러움 — 전용 메시지 신규 채번 필요.
- 단위(Meins)에 잘못된 값을 넣었을 때 뜨는 오류 메시지가 "값이 존재하지 않음"이 아니라 형식 오류처럼 표시되는 문제 — 원인 파악 보류.
- Infnr(구매정보번호)이 Create 시 사용자가 직접 입력 가능한 상태로 남아있음(자동채번 필드인데 편집 가능) — readonly 처리 필요, 미착수.
- 서치헬프로 선택한 값의 텍스트(Liftx/Maktx) 자동 매핑 Determination, 저장 시 코드↔텍스트 불일치 검증 Validation — 미착수(TODO).
- Loekz(구매정보 취소) 필드는 FS 요구사항은 아니나, 생성 시점엔 불필요하다고 판단해 생성 시 readonly 처리하는 Feature Control 추가가 TODO로 남음(자체 판단 항목).

## 테스트 현황

9/2 devlog 기준, 헤더(SetVendorMaterialUuid/SetDefaults/SetInfnrNumber/CheckRequired/CheckDuplicate/CheckEsokz)·아이템(SetItemDefaults/CheckExist/CheckPositive/get_instance_features) 로직 10개 중 대부분은 화면에서 개별 동작을 확인했다 — 공급업체/자재/구매단위 선택 후 저장 성공, 채번(Infnr) 정상 반영, 통화(Waers) 동적 readonly 렌더링, 구매그룹 F4 정상 동작 등. 다만 예외 케이스(잘못된 값 입력 시 처리)는 위 4절에 정리한 대로 `SetVendorMaterialUuid`/`CheckRequired` 하이라이트 수정이 남아 있어, 전체 검증 테스트는 아직 마무리되지 않았다.

관련 Search Help: [`ZI_B07_WERKS_F4`](./00_common.md), [`ZI_B07_ESOKZ_F4`](./00_common.md), [`ZI_B07_EKORG_F4`](./00_common.md), [`ZI_B07_EKGRP_F4`](./00_common.md), [`ZI_B07_IRTXT_F4`](./00_common.md), 공급업체는 [벤더관리](./03_vendor.md), 자재는 [자재관리](./01_materialmgmt.md) 참조
