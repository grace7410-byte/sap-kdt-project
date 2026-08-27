*=============================================================
* 변경이력
* 2026-08-20  최초 작성, SetSequenceNumber/CheckAccountExist 확인 — devlog: ../../../devlog/rap-dev/2026-08-20.md
* 2026-08-24  SetShkzg 최종 로직 확인 — 인터페이스 뷰(zi_b07_debit_credit) 연결 방식은 실패, 
*             dd07t 직접 조회 방식이 처음부터 맞는 접근이었음을 확인 — devlog: .../2026-08-24.md
* 2026-08-26  checkexist(자재평가/전기키/차대변/회계결정코드 필수값+존재 여부 체크),
*             checkduplicate(이동유형+회계결정코드+평가클래스+계정 조합 중복 체크) 신규 추가 — devlog: .../2026-08-26.md
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

    METHODS checkexist FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_t030~checkexist.
    METHODS checkduplicate FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_t030~checkduplicate.

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
                      %msg = new_message(
                                id       = 'ZMSGE_B07'
                                number   = '015'
                                v1       = 'Valuation Class'
                                severity = if_abap_behv_message=>severity-error )
                    ) TO reported-zr_b07_t030.
      ENDIF.
      IF ls_t030-Bschl IS INITIAL.
        APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
        APPEND VALUE #( %tky = ls_t030-%tky
                      %element-Bschl = if_abap_behv=>mk-on
                      %msg = new_message(
                                id       = 'ZMSGE_B07'
                                number   = '015'
                                v1       = 'Posting Key'
                                severity = if_abap_behv_message=>severity-error )
                    ) TO reported-zr_b07_t030.
      ENDIF.
      IF ls_t030-Shkzg IS INITIAL. " 값을 입력한 경우에만 검증할 수 있도록 하기!
        APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
        APPEND VALUE #( %tky = ls_t030-%tky
                      %element-Shkzg = if_abap_behv=>mk-on
                      %msg = new_message(
                                id       = 'ZMSGE_B07'
                                number   = '015'
                                v1       = 'Debit/Credit'
                                severity = if_abap_behv_message=>severity-error )
                    ) TO reported-zr_b07_t030.
      ENDIF.
      READ TABLE lt_db_bklas INTO DATA(lv_db_bklas) WITH KEY bklas = ls_t030-Bklas.
      IF lv_db_bklas IS INITIAL AND ls_t030-Bklas IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
        APPEND VALUE #( %tky = ls_t030-%tky
                      %element-Bklas = if_abap_behv=>mk-on
                      %msg = new_message(
                                id       = 'ZMSGE_B07'
                                number   = '019'
                                v1       = 'Valuation Class'
                                v2 = ls_t030-Bklas
                                severity = if_abap_behv_message=>severity-error )
                    ) TO reported-zr_b07_t030.
      ENDIF.
      READ TABLE lt_db_bschl INTO DATA(lv_db_bschl) WITH KEY bschl = ls_t030-Bschl.
      IF lv_db_bschl IS INITIAL AND ls_t030-Bschl IS NOT INITIAL.
        APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
        APPEND VALUE #( %tky = ls_t030-%tky
                      %element-Bschl = if_abap_behv=>mk-on
                      %msg = new_message(
                                id       = 'ZMSGE_B07'
                                number   = '019'
                                v1       = 'Posting Key'
                                v2 = ls_t030-Bschl
                                severity = if_abap_behv_message=>severity-error )
                    ) TO reported-zr_b07_t030.
      ENDIF.
      READ TABLE lt_db_shkzg INTO DATA(lv_db_shkzg) WITH KEY shkzg = ls_t030-Shkzg.
      IF lv_db_shkzg IS INITIAL AND ls_t030-Shkzg IS NOT INITIAL. " 값을 입력한 경우에만 검증할 수 있도록 하기!
        APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
        APPEND VALUE #( %tky = ls_t030-%tky
                      %element-Shkzg = if_abap_behv=>mk-on
                      %msg = new_message(
                                id       = 'ZMSGE_B07'
                                number   = '019'
                                v1       = 'Debit/Credit'
                                v2 = ls_t030-Shkzg
                                severity = if_abap_behv_message=>severity-error )
                    ) TO reported-zr_b07_t030.
      ENDIF.
      READ TABLE lt_db_ktosl INTO DATA(lv_db_ktosl) WITH KEY ktosl = ls_t030-Ktosl.
      IF lv_db_ktosl IS INITIAL AND ls_t030-Ktosl IS NOT INITIAL. " 값을 입력한 경우에만 검증할 수 있도록 하기!
        APPEND VALUE #( %tky = ls_t030-%tky ) TO failed-zr_b07_t030.
        APPEND VALUE #( %tky = ls_t030-%tky
                      %element-Ktosl = if_abap_behv=>mk-on
                      %msg = new_message(
                                id       = 'ZMSGE_B07'
                                number   = '019'
                                v1       = 'Transaction Key'
                                v2 = ls_t030-Ktosl
                                severity = if_abap_behv_message=>severity-error )
                    ) TO reported-zr_b07_t030.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

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

ENDCLASS.
