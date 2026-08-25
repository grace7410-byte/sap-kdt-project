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

> 이 최종 로직으로 확정되기까지의 시행착오(인터페이스 뷰 연결 시도 → 실패 → 단순화)는 devlog 2026-08-24(작성 예정) 참고. additionalBinding으로 F4 팝업 선택 시 다른 필드를 자동으로 채우는 기능은 다음 개발일 진행 예정 항목이다.
