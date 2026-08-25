// ============================================================
// 변경이력
// 2026-08-14  최초 작성 (SetInitialDefault, SetReadOnly) — devlog: ../../../devlog/rap-dev/2026-08-14.md
// ============================================================
// NOTE: Validation 메서드(validate_matnr 등)는 8/14 기준 이름만 정해지고 실제 코드는 없어 미포함.
CLASS lhc_ZR_B07_MARA DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS SetInitialDefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_mara~SetInitialDefault.

    METHODS SetReadOnly FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_b07_mara~SetReadOnly.

    " TODO: Validation 메서드 4종 (validate_matnr, validate_plant_sloc, validate_ersda 등) 추가 예정

ENDCLASS.

CLASS lhc_ZR_B07_MARA IMPLEMENTATION.

  METHOD SetInitialDefault.
    MODIFY ENTITIES OF zr_b07_mara IN LOCAL MODE
    ENTITY zr_b07_mara
    UPDATE FIELDS ( Waers Peinh Ersda )
    WITH VALUE #( FOR key IN keys
                    ( %tky = key-%tky
                      Waers = 'KRW'
                      Peinh = 1
                      Ersda = sy-datum )
                ).
  ENDMETHOD.

  METHOD SetReadOnly.
    MODIFY ENTITIES OF zr_b07_mara IN LOCAL MODE
    ENTITY zr_b07_mara
    UPDATE FIELDS ( Matfi )
    WITH VALUE #( FOR key IN keys
                    ( %tky = key-%tky
                      Matfi = 'X' )
                ).
  ENDMETHOD.

ENDCLASS.
