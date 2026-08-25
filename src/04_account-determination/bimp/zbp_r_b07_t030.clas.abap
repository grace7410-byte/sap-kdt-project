*=============================================================
* 변경이력
* 2026-08-20  최초 작성, SetSequenceNumber/CheckAccountExist 확인 — devlog: ../../../devlog/rap-dev/2026-08-20.md
* 2026-08-24  SetShkzg 최종 로직 확인 — 인터페이스 뷰(zi_b07_debit_credit) 연결 방식은 실패, 
*             dd07t 직접 조회 방식이 처음부터 맞는 접근이었음을 확인 — devlog: .../2026-08-24.md
*=============================================================
CLASS lhc_ZR_B07_T030 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_b07_t030 RESULT result.
    METHODS setsequencenumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_b07_t030~setsequencenumber.

    METHODS checkaccountexist FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_t030~checkaccountexist.
    METHODS setshkzg FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_t030~setshkzg.

ENDCLASS.

CLASS lhc_ZR_B07_T030 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD SetSequenceNumber.
    DATA: lt_update TYPE TABLE FOR UPDATE zr_b07_t030.

    READ ENTITIES OF zr_b07_t030 IN LOCAL MODE
          ENTITY zr_b07_t030
            FIELDS ( Bwart Seqnr )
            WITH CORRESPONDING #( keys )
          RESULT DATA(lt_sequence).

    " Seqnr이 비어있는 데이터
    LOOP AT lt_sequence ASSIGNING FIELD-SYMBOL(<fs_seq>) WHERE Seqnr IS INITIAL.

      " DB에서 같은 이동유형의 최대 순번 조회
      SELECT SINGLE MAX( seqnr )
        FROM ztb07t030
        WHERE bwart = @<fs_seq>-Bwart
        INTO @DATA(lv_db_max).

      " 현재 Bwart 중 최대 Seqnr 구하기
      " 루트/read 여러 번 대신 REDUCE 사용 =>
      DATA(lv_batch_max) = REDUCE zr_b07_t030-seqnr(
                                INIT max = 0
                                FOR line IN lt_update " row를 하나씩 꺼내 라인에 담고
                                WHERE ( bwart = <fs_seq>-Bwart )" bwart이 같은 것만 조회
                                  " 하나씩 거칠 때마다 max값을 업데이트하는데 그건 순번이 max보다 클 때만 업데이트된다.
                                NEXT max = COND #( WHEN line-seqnr > max THEN line-seqnr ELSE max ) ).

      DATA(lv_max_seqnr) = COND #( WHEN lv_db_max > lv_batch_max THEN lv_db_max ELSE lv_batch_max ).


      " +1 채번 후 찐 업데이트
      <fs_seq>-Seqnr = lv_max_seqnr + 1.

      APPEND VALUE #( %tky  = <fs_seq>-%tky
                      Seqnr = <fs_seq>-Seqnr ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_t030 IN LOCAL MODE
        ENTITY zr_b07_t030
          UPDATE FIELDS ( Seqnr )
          WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD CheckAccountExist.
    READ ENTITIES OF zr_b07_t030 IN LOCAL MODE
  ENTITY zr_b07_t030
    FIELDS ( Saknr )
    WITH CORRESPONDING #( keys )
  RESULT DATA(lt_t030).

    LOOP AT lt_t030 INTO DATA(ls_t030) WHERE Saknr IS NOT INITIAL.
      SELECT SINGLE saknr FROM ztb07ska1
        WHERE saknr = @ls_t030-Saknr
        INTO @DATA(lv_saknr).

      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
        APPEND VALUE #( %tky = ls_t030-%tky
                         %element-Saknr = if_abap_behv=>mk-on
                         %msg = new_message( id = 'ZMSGE_B07'
                                              number = '020'
                                              v1 = 'FI Account'
                                              v2 = ls_t030-Saknr
                                              severity = if_abap_behv_message=>severity-error ) )
          TO reported-zr_b07_t030.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

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

ENDCLASS.
