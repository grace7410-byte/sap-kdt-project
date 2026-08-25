// ============================================================
// 변경이력
// 2026-08-18  최초 작성 (SetInitialDefault, CheckInit, SetVendorNumber) — devlog: ../../../devlog/rap-dev/2026-08-18.md
// 2026-08-21  SetVendorNumber 채번 오류 수정: Prefix('V'+6자리)를 로직에서 직접 구성,
//             Number Range 오브젝트명 ZNR_B07LIFNR → ZNRB07_LIF로 변경, OTHERS일 때 CONTINUE 대신 기본값('01') 사용 — devlog: ../../../devlog/rap-dev/2026-08-21.md
// ============================================================
CLASS lhc_ZR_B07_LFA1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS SetInitialDefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_lfa1~SetInitialDefault.

    METHODS CheckInit FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_lfa1~CheckInit.

    METHODS SetVendorNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_b07_lfa1~SetVendorNumber.

ENDCLASS.

CLASS lhc_ZR_B07_LFA1 IMPLEMENTATION.

  METHOD SetInitialDefault.
    MODIFY ENTITIES OF zr_b07_lfa1 IN LOCAL MODE
    ENTITY zr_b07_lfa1
    UPDATE FIELDS ( Waers )
    WITH VALUE #( FOR key IN keys
                    ( %tky = key-%tky
                      Waers = 'KRW' )
                ).
  ENDMETHOD.

  METHOD CheckInit.
    " Read Data
    READ ENTITIES OF zr_b07_lfa1 IN LOCAL MODE
    ENTITY zr_b07_lfa1
    FIELDS ( Name1 Fdgrv )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_lfa1).

    LOOP AT lt_lfa1 INTO DATA(ls_lfa1).
      IF ls_lfa1-Name1 IS INITIAL.
        APPEND VALUE #( %tky = ls_lfa1-%tky ) TO failed-zr_b07_lfa1.

        APPEND VALUE #( %tky = ls_lfa1-%tky
                        %element-Name1 = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '015'
                                            v1 = 'Vendor Name'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_lfa1.
      ENDIF.
      IF ls_lfa1-Fdgrv IS INITIAL.
        APPEND VALUE #( %tky = ls_lfa1-%tky ) TO failed-zr_b07_lfa1.

        APPEND VALUE #( %tky = ls_lfa1-%tky
                        %element-Fdgrv = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '015'
                                            v1 = 'Vendor Type'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_lfa1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " 2026-08-21: 채번 오류 수정. Prefix('V')를 Number Range 서브타입으로 지정하려 했으나
  " 연결 가능한 도메인/데이터 엘리먼트를 새로 만들어야 해서, 대신 숫자만 6자리로 채번한 뒤
  " 로직에서 뒤 6자리를 잘라 앞에 'V'를 붙이는 방식으로 우회.
  METHOD SetVendorNumber.
    DATA: lv_nr_range TYPE inri-nrrangenr,
          lv_number   TYPE inri-nr,
          lt_update   TYPE TABLE FOR UPDATE zr_b07_lfa1.

    " 이미 채번된 값은 넘기고 공급업체 번호 및 분류 조회
    READ ENTITIES OF zr_b07_lfa1 IN LOCAL MODE
      ENTITY zr_b07_lfa1
        FIELDS ( Lifnr Fdgrv )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_vendor).

    LOOP AT lt_vendor INTO DATA(ls_vendor) WHERE Lifnr IS INITIAL.

      " 공급업체 분류 코드에 맞게 채번 앞자리 다르게 설정
      CASE ls_vendor-Fdgrv.
        WHEN 'A1'. lv_nr_range = '01'.
        WHEN 'A2'. lv_nr_range = '02'.
        WHEN 'A3'. lv_nr_range = '03'.
        WHEN 'A4'. lv_nr_range = '04'.
        WHEN 'A5'. lv_nr_range = '05'.
        WHEN 'A6'. lv_nr_range = '06'.
        WHEN OTHERS.
          " 분류 없는 경우 기본값 사용 (이전엔 CONTINUE로 건너뛰어서 채번이 아예 안 되는 게 문제였음)
          lv_nr_range = '01'.
      ENDCASE.

      CALL FUNCTION 'NUMBER_GET_NEXT' " 채번
        EXPORTING
          nr_range_nr = lv_nr_range
          object      = 'ZNRB07_LIF'
        IMPORTING
          number      = lv_number
        EXCEPTIONS
          OTHERS      = 1.

      IF sy-subrc = 0. " prefix 하려면 뒤에서 6자리 끌어와서 앞에 V 붙여주기
        DATA(lv_seq) = substring( val = lv_number
                          off = strlen( lv_number ) - 6 ).
        DATA(lv_lifnr) = |V{ lv_seq }|.

        APPEND VALUE #( %tky = ls_vendor-%tky
                         Lifnr = lv_lifnr ) TO lt_update.
      ELSE.
        APPEND VALUE #( %tky = ls_vendor-%tky
                     %msg = new_message( id = 'ZMSGE_B07'
                                          number = '009'
                                          v1 = 'Vendor Number Range'
                                          severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_lfa1.
      ENDIF.
    ENDLOOP.

    " 채번된 값 반영
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_lfa1 IN LOCAL MODE
        ENTITY zr_b07_lfa1
          UPDATE FIELDS ( Lifnr )
          WITH lt_update.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
