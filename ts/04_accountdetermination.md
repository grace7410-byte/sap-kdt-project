# [04] 회계계정결정관리

관련 오브젝트 카탈로그: [`04_account-determination`](../reference/04_account-determination.md)

**구현 진행 상황**
1. ListPage 화면 – 완성도 100%
2. Object Page 화면 – 완성도 100%

## 1) 최초 설계

FI Standard 실습(OBYC)을 바탕으로 회계결정코드·이동유형·평가클래스 외에 전기키(Bschl)를 함께 관리하도록 설계함. 차/대변(Shkzg) 필드는 전기키로 유추 가능하다고 보아 1차 설계에서는 제외함.

## 2) FS 확인 및 비교/분석

FS 4.1/5.2 확인 결과 "차변/대변 수정 가능하게 설정" 요건이 존재함.

- 전기키(Bschl)만 두면 차/대변 여부를 UI에서 바로 파악하기 어려움
- 차/대변(Shkzg)만 두면 상세 전기키 정보가 유실됨
- **결론:** 차/대변(Shkzg) 필드를 추가하고, 전기키(Bschl) 입력 시 차/대변 값이 자동 매핑되도록 로직 구성 (Posting Key 89/86/40/81/01 → 차변 S, 99/96/50/91/31 → 대변 H).

테이블: [`ZTB07T030`](../reference/04_account-determination.md) · [코드 보기](../src/04_account-determination/tables/ZTB07T030.tabl.asddls)

## 3) TS 수정·보완 내역

### 5.3.1. 필드 추가/수정

- **전기키 (Bschl):** 자동 회계전표 생성 목적(FS 1.1) 달성을 위해 추가 (`zeb07bschl` 생성)
- **차변/대변 (Shkzg):** SAP 표준 관례인 H(대변/Credit) / S(차변/Debit)로 정정

### 5.3.2. 텍스트 Association 구성 및 FI계정관리 연계

Root BO: [`ZR_B07_T030`](../reference/04_account-determination.md) · [코드 보기](../src/04_account-determination/cds/ZR_B07_T030.ddls.asddls) · Projection: [코드 보기](../src/04_account-determination/cds/ZC_B07_T030.ddls.asddls)

- **이동유형 (Bwart) / 회계결정코드 (Ktosl) / 차대구분 (Shkzg) / 전기키 (Bschl):** `I_DomainFixedValueText` 연동
- **평가클래스 (Bklas):** `ZI_B07_BKLAS_F4` 연동 · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_BKLAS_F4.ddls.asddls)
- **계정 (Saknr) - `ZR_B07_SKA1`:** 계정명뿐만 아니라 02 모듈의 Root View를 재사용하여 계정타입(`Glact`/`Glatx`)까지 연동 노출. 계정을 지정하고 저장하면 계정명, 계정타입, 계정타입명이 자동 할당됨.

### 5.3.3. 이동유형 / 전기키 / 차대변 Value Help

- [`ZI_B07_BWART_F4`](../reference/00_common-searchhelp.md) (이동유형) · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_BWART_F4.ddls.asddls)
- [`ZI_B07_BSCHL_F4`](../reference/00_common-searchhelp.md) (전기키) · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_BSCHL_F4.ddls.asddls)
- [`ZI_B07_SHKZG_F4`](../reference/00_common-searchhelp.md) (차/대변) · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_SHKZG_F4.ddls.asddls)

전기키 → 차/대변 자동 매핑은 매핑 전용 Interface View(`zi_b07_debit_credit`)를 별도로 두고 Association으로 연결하는 방식을 먼저 검토했으나 실제로는 동작하지 않았고, 최종적으로는 도메인 텍스트 테이블(dd07t)을 직접 조회하는 Determination 방식으로 정리되었다.

- **Method:** [`SetShkzg`](../reference/04_account-determination.md) · [코드 보기](../src/04_account-determination/bimp/zbp_r_b07_t030.clas.abap) — `determination SetShkzg on modify { field Bschl; }`로 전기키 입력 즉시 차/대변이 채워지도록 구성 ([BDEF 코드 보기](../src/04_account-determination/bdef/ZR_B07_T030.bdef.asbdef))

```abap
METHOD SetShkzg.
  DATA: lt_update TYPE TABLE FOR UPDATE zr_b07_t030.

  READ ENTITIES OF zr_b07_t030 IN LOCAL MODE
       ENTITY zr_b07_t030
         FIELDS ( Bschl )
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_bschl).

  DELETE lt_bschl WHERE Bschl IS INITIAL.
  CHECK lt_bschl IS NOT INITIAL.

  LOOP AT lt_bschl ASSIGNING FIELD-SYMBOL(<fs_bschl>).
    SELECT SINGLE ddtext
      FROM dd07t
      WHERE domname     = 'ZDB07BSCHL'
        AND domvalue_l  = @<fs_bschl>-Bschl
        AND ddlanguage  = @sy-langu
      INTO @DATA(lv_shkzg).

    IF sy-subrc = 0.
      APPEND VALUE #( %tky  = <fs_bschl>-%tky
                       Shkzg = lv_shkzg ) TO lt_update.
    ENDIF.
  ENDLOOP.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zr_b07_t030 IN LOCAL MODE
      ENTITY zr_b07_t030
        UPDATE FIELDS ( Shkzg )
        WITH lt_update.
  ENDIF.
ENDMETHOD.
```

> 이 최종 로직으로 확정되기까지의 시행착오(인터페이스 뷰 연결 시도 → 실패 → 단순화)는 devlog 2026-08-24(작성 예정) 참고.

## 4) 2차 TS 수정·보완 내역 (중간평가 2차)

피드백 3건: ① 자재평가/전기키/차대변에 존재하지 않는 데이터 저장, ② 해당 필드 미입력 저장(의도한 것이면 무관하나 ①과 함께 통합 처리하기로 판단), ③ 순번(Seqnr)이 Key라 이동유형+회계결정코드+평가클래스+계정 조합이 중복 저장 가능. 여기에 더해 전기키 F4 선택 시 UX 개선 작업(추가)도 함께 진행.

### 5.4.1. 전기키 F4 선택 시 차/대변 즉시 자동 채움

- **적용 Annotation:** `additionalBinding` · [`ZC_B07_T030`](../reference/04_account-determination.md) · [코드 보기](../src/04_account-determination/cds/ZC_B07_T030.ddls.asddls)
- **사유:** 위 5.3.3의 `SetShkzg` Determination은 서버 라운드트립(on modify) 후에 값이 채워지는 방식이었는데, 서치헬프 CDS(`ZI_B07_BSCHL_F4`)에 동일 소스 컬럼(DomainText)을 별칭만 다르게(`BschlText`, `ShkzgOut`) 한 번 더 select할 수 있다는 점을 활용해, F4 팝업에서 행을 선택하는 즉시 UI 레벨에서 Shkzg를 채우도록 개선. 기존 플랜트→저장위치(00 공통)는 `#FILTER`(후보를 좁힘)였던 것과 비교해, 전기키→차대구분은 1:1 대응 관계이므로 `#RESULT`가 적합하다고 판단. 이후 `Shkzg`는 `@UI.readOnly: true`로 고정. 반대 방향(차대구분→전기키 필터링)은 Shkzg가 이미 readonly라 F4를 열 일이 없어 구현 비용 대비 실익이 낮다고 보고 보류.

```abap
/*********  전기키  ************/
// 서치헬프 (additionalBinding: F4에서 행 선택 시 Shkzg 자동 채움)
@Consumption.valueHelpDefinition: [{
  entity: { name: 'ZI_B07_BSCHL_F4', element: 'Bschl' },
  additionalBinding: [
    { element: 'ShkzgOut', localElement: 'Shkzg', usage: #RESULT }
  ]
}]
// 텍스트
@ObjectModel.text.element: ['Bsctx'] //함께 띄우기
@UI.textArrangement: #TEXT_FIRST
Bschl,
Bsctx,

/********* 차/대변 (전기키 선택 시 자동 채워지므로 readOnly) ************/
@UI.readOnly: true
Shkzg,
Shktx,
```

🧪 테스트: 기존에는 빈 상태였다가, 전기키로 31을 선택하면 바로(자동으로) 차/대변도 31에 맞는 값으로 변경되는 것을 확인.

### 5.4.2. 자재평가/전기키/차대구분/회계결정코드 필수·존재 통합 검증

- **적용 Method:** [`CheckExist (신규)`](../reference/04_account-determination.md) · [코드 보기](../src/04_account-determination/bimp/zbp_r_b07_t030.clas.abap) · BDEF: [코드 보기](../src/04_account-determination/bdef/ZR_B07_T030.bdef.asbdef)
- **사유:** 최초에는 피드백 ③(존재하지 않는 값 저장)만 해결하려고 4개 필드의 존재 검증만 구현(02 FI계정관리 `CheckExist` 패턴 재사용, 원본 테이블이 아닌 각 서치헬프 뷰 `zi_b07_bklas_f4`/`bschl`/`shkzg`/`ktosl`에서 조회). 이후 Shkzg가 F4 선택 시 자동 채워지더라도 사용자가 그 값을 지울 수 있다는 점을 재인지하여, 피드백 ①(미입력 저장)까지 같은 메서드 안에서 함께 처리하기로 판단 — 같은 LOOP 안에 필수값(빈 값) 체크 IF문 4개를 존재검증 앞에 추가. 강사님이 언급하지 않은 Ktosl(회계결정코드)도 계정 검증을 만드는 김에 함께 검증하기로 자체 판단으로 포함.

```abap
validation CheckExist on save { create; update; field Bklas, Bschl, Shkzg, Ktosl; }
```

```abap
METHOD CheckExist.
  READ ENTITIES OF zr_b07_t030 IN LOCAL MODE
    ENTITY zr_b07_t030
    FIELDS ( Bklas Bschl Shkzg Ktosl ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_t030).
  SELECT bklas FROM zi_b07_bklas_f4
      INTO TABLE @DATA(lt_db_bklas). " 직접 만든 서치헬프용으로 4개 값만 미리 담기
  SELECT bschl FROM zi_b07_bschl_f4
      INTO TABLE @DATA(lt_db_bschl). " 직접 만든 서치헬프용으로 10개 값만 미리 담기
  SELECT shkzg FROM zi_b07_shkzg_f4
      INTO TABLE @DATA(lt_db_shkzg). " 직접 만든 서치헬프용으로 2개 값만 미리 담기
  SELECT ktosl FROM zi_b07_ktosl_f4
      INTO TABLE @DATA(lt_db_ktosl). " 직접 만든 서치헬프용으로 10개 값만 미리 담기
  LOOP AT lt_t030 INTO DATA(ls_t030).
    IF ls_t030-Bklas IS INITIAL.
      APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
      APPEND VALUE #( %tky = ls_t030-%tky
                    %element-Bklas = if_abap_behv=>mk-on
                    %msg = new_message( id = 'ZMSGE_B07' number = '015' v1 = 'Valuation Class'
                                        severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_t030.
    ENDIF.
    IF ls_t030-Bschl IS INITIAL.
      APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
      APPEND VALUE #( %tky = ls_t030-%tky
                    %element-Bschl = if_abap_behv=>mk-on
                    %msg = new_message( id = 'ZMSGE_B07' number = '015' v1 = 'Posting Key'
                                        severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_t030.
    ENDIF.
    IF ls_t030-Shkzg IS INITIAL. " 값을 입력한 경우에만 검증할 수 있도록 하기!
      APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
      APPEND VALUE #( %tky = ls_t030-%tky
                    %element-Shkzg = if_abap_behv=>mk-on
                    %msg = new_message( id = 'ZMSGE_B07' number = '015' v1 = 'Debit/Credit'
                                        severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_t030.
    ENDIF.
    READ TABLE lt_db_bklas INTO DATA(lv_db_bklas) WITH KEY bklas = ls_t030-Bklas.
    IF lv_db_bklas IS INITIAL AND ls_t030-Bklas IS NOT INITIAL.
      APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
      APPEND VALUE #( %tky = ls_t030-%tky
                    %element-Bklas = if_abap_behv=>mk-on
                    %msg = new_message( id = 'ZMSGE_B07' number = '019' v1 = 'Valuation Class'
                                        v2 = ls_t030-Bklas severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_t030.
    ENDIF.
    READ TABLE lt_db_bschl INTO DATA(lv_db_bschl) WITH KEY bschl = ls_t030-Bschl.
    IF lv_db_bschl IS INITIAL AND ls_t030-Bschl IS NOT INITIAL.
      APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
      APPEND VALUE #( %tky = ls_t030-%tky
                    %element-Bschl = if_abap_behv=>mk-on
                    %msg = new_message( id = 'ZMSGE_B07' number = '019' v1 = 'Posting Key'
                                        v2 = ls_t030-Bschl severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_t030.
    ENDIF.
    READ TABLE lt_db_shkzg INTO DATA(lv_db_shkzg) WITH KEY shkzg = ls_t030-Shkzg.
    IF lv_db_shkzg IS INITIAL AND ls_t030-Shkzg IS NOT INITIAL. " 값을 입력한 경우에만 검증할 수 있도록 하기!
      APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
      APPEND VALUE #( %tky = ls_t030-%tky
                    %element-Shkzg = if_abap_behv=>mk-on
                    %msg = new_message( id = 'ZMSGE_B07' number = '019' v1 = 'Debit/Credit'
                                        v2 = ls_t030-Shkzg severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_t030.
    ENDIF.
    READ TABLE lt_db_ktosl INTO DATA(lv_db_ktosl) WITH KEY ktosl = ls_t030-Ktosl.
    IF lv_db_ktosl IS INITIAL AND ls_t030-Ktosl IS NOT INITIAL. " 값을 입력한 경우에만 검증할 수 있도록 하기!
      APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
      APPEND VALUE #( %tky = ls_t030-%tky
                    %element-Ktosl = if_abap_behv=>mk-on
                    %msg = new_message( id = 'ZMSGE_B07' number = '019' v1 = 'Transaction Key'
                                        v2 = ls_t030-Ktosl severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_t030.
    ENDIF.
  ENDLOOP.
ENDMETHOD.
```
> 메시지 [`015`](../src/message-class.md#015), [`019`](../src/message-class.md#019)

cf. 회계결정코드(Ktosl)는 이미 mandatory 설정이 있어서 필수값 체크는 프레임워크가 자동으로 해줌. 계정타입은 이상한 값을 넣어도 Determination이 자동으로 다시 채워주는 것을 확인.

🧪 테스트: 3개 항목(필수 미입력/존재하지 않는 값 입력) 모두 정상 동작 확인.

### 5.4.3. 이동유형+회계결정코드+평가클래스+계정 조합 중복 방지

- **적용 Method:** [`CheckDuplicate (신규)`](../reference/04_account-determination.md) · [코드 보기](../src/04_account-determination/bimp/zbp_r_b07_t030.clas.abap) · BDEF: [코드 보기](../src/04_account-determination/bdef/ZR_B07_T030.bdef.asbdef)
- **사유:** `Seqnr`이 Key라서 매번 새 값(max+1)으로 채번되기 때문에, 완전히 똑같은 조합(이동유형+회계결정코드+평가클래스+계정)이 이미 있어도 시스템이 "새 레코드"로 인식해서 그냥 저장되는 구조적 허점을 확인.

```abap
validation CheckDuplicate on save { create; update; field Bwart, Ktosl, Bklas, Saknr; }
```

```abap
METHOD CheckDuplicate.
  READ ENTITIES OF zr_b07_t030 IN LOCAL MODE
    ENTITY zr_b07_t030
      FIELDS ( Bwart Ktosl Bklas Saknr )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_t030).

  SELECT map_uuid, bwart, ktosl, bklas, saknr FROM ztb07t030
    INTO TABLE @DATA(lt_db_data).

  LOOP AT lt_t030 INTO DATA(ls_t030)
       WHERE Bwart IS NOT INITIAL AND Ktosl IS NOT INITIAL
         AND Bklas IS NOT INITIAL AND Saknr IS NOT INITIAL.

    DATA(lv_is_dup) = abap_false.

    LOOP AT lt_db_data INTO DATA(ls_db_data)
         WHERE bwart    = ls_t030-Bwart
           AND ktosl    = ls_t030-Ktosl
           AND bklas    = ls_t030-Bklas
           AND saknr    = ls_t030-Saknr
           AND map_uuid <> ls_t030-MapUuid.

      lv_is_dup = abap_true.
      EXIT.
    ENDLOOP.

    IF lv_is_dup = abap_true.
      APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
      APPEND VALUE #( %tky = ls_t030-%tky
                       %msg = new_message( id = 'ZMSGE_B07'
                                            number   = '017'
                                            v1       = 'Account Determination'
                                            v2       = |{ ls_t030-Bwart }/{ ls_t030-Ktosl }/{ ls_t030-Bklas }|
                                            severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_t030.
    ENDIF.
  ENDLOOP.
ENDMETHOD.
```
> 메시지 [`017`](../src/message-class.md#017)

🧪 테스트: 이동유형/트랜잭션키/평가클래스/계정을 동일하게 넣고 저장했을 때 피드백 예시처럼 정상적으로 중복 체크됨.

> additionalBinding으로 F4 팝업에서 행 선택 시 다른 필드를 자동으로 채우는 기능은 5.4.1에서 반영 완료되었다.
