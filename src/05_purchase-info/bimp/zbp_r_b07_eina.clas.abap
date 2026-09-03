*=============================================================
* 변경이력
* 2026-08-30  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-30.md
*             헤더(lhc_zr_b07_eina): SetDefaults/SetInfnrNumber/CheckRequired/CheckDuplicate/CheckEsokz
*             아이템(lhc_eine): SetItemDefaults/CheckExist/CheckPositive
* 2026-08-31  아이템(lhc_eine): get_instance_features 신규 추가 (Waers 동적 readonly 제어) —
*             devlog: ../../../devlog/rap-dev/2026-08-31.md
* 2026-09-02  헤더(lhc_zr_b07_eina): SetVendorMaterialUuid 신규 추가(Lifnr/Matnr 입력값을 LifUuid/MatUuid로
*             변환) — 화면 입력창(Lifnr/Matnr)이 실제로는 Association 파생 표시용 필드라 저장 시 FK가
*             비어있는 문제 대응. CheckRequired는 LifUuid/MatUuid 대신 Lifnr/Matnr 필드를 검사하도록 수정
*             (진짜 원인 — CheckRequired가 화면에 아직 안 채워지는 UUID를 검사하고 있었음). SetInfnrNumber는
*             연도+뒤 6자리 조합 로직을 제거하고 NUMBER_GET_NEXT 채번 결과를 그대로 사용하도록 단순화 —
*             devlog: ../../../devlog/rap-dev/2026-09-02.md
* NOTE: SetVendorMaterialUuid가 존재하지 않는 Lifnr/Matnr 입력값에 대해 에러 처리 없이 그냥 넘어가는 문제가
*       남아있음(잘못된 값이어도 저장이 통과됨) — 다음 작업일 처리 예정, 아직 코드 미반영.
* NOTE: "예외 처리 및 추가 로직"은 다음 작업일에 이어서 진행 예정 — WIP 상태입니다.
*=============================================================
CLASS lhc_zr_b07_eina DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_b07_eina RESULT result.
    METHODS setvendormaterialuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_eina~setvendormaterialuuid.
    METHODS setdefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_eina~setdefaults.
    METHODS setinfnrnumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_b07_eina~setinfnrnumber.
    METHODS checkduplicate FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_eina~checkduplicate.
    METHODS checkesokz FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_eina~checkesokz.
    METHODS checkrequired FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_eina~checkrequired.

ENDCLASS.

CLASS lhc_zr_b07_eina IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD SetVendorMaterialUuid.
    DATA: lt_update TYPE TABLE FOR UPDATE zr_b07_eina.

    READ ENTITIES OF zr_b07_eina IN LOCAL MODE
      ENTITY zr_b07_eina
        FIELDS ( LifUuid MatUuid Lifnr Matnr )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_eina).

    SELECT lif_uuid, lifnr FROM ztb07lfa1
      INTO TABLE @DATA(lt_db_lfa1).

    SELECT mat_uuid, matnr FROM ztb07mara
      INTO TABLE @DATA(lt_db_mara).

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

  METHOD SetInfnrNumber.
    DATA: lv_number TYPE inri-nr,
          lt_update TYPE TABLE FOR UPDATE zr_b07_eina.
    READ ENTITIES OF zr_b07_eina IN LOCAL MODE
      ENTITY zr_b07_eina
        FIELDS ( Infnr )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_eina).
    LOOP AT lt_eina INTO DATA(ls_eina) WHERE Infnr IS INITIAL.
      CALL FUNCTION 'NUMBER_GET_NEXT' " 채번
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZNRB07_INF'
        IMPORTING
          number      = lv_number
        EXCEPTIONS
          OTHERS      = 1.
      IF sy-subrc = 0. " 미리 구성해둔 넘버레인지를 그대로 사용(연도+뒤 6자리 가공 로직 제거)
        APPEND VALUE #( %tky  = ls_eina-%tky
                         Infnr = lv_number ) TO lt_update.
      ELSE.
        APPEND VALUE #( %tky = ls_eina-%tky
                     %msg = new_message( id = 'ZMSGE_B07'
                                          number = '009'
                                          v1 = 'Purchase Info Record Number Range'
                                          severity = if_abap_behv_message=>severity-error ) )
        TO reported-zr_b07_eina.
      ENDIF.
    ENDLOOP.
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_eina IN LOCAL MODE
        ENTITY zr_b07_eina
          UPDATE FIELDS ( Infnr )
          WITH lt_update.
    ENDIF.
  ENDMETHOD.

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

ENDCLASS.

CLASS lhc_eine DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setitemdefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_b07_eine~setitemdefaults.
    METHODS checkexist FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_b07_eine~checkexist.
    METHODS checkpositive FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_b07_eine~checkpositive.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR eine RESULT result.

ENDCLASS.

CLASS lhc_eine IMPLEMENTATION.

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

  METHOD get_instance_features.
    " Waers는 Netpr에 @Semantics.amount.currencyCode로 물려있는 통화 필드라
    " field(readonly) 같은 정적 제어를 걸면 활성화 시 에러남(MARA의 Stprs/Waers와 동일한 이유).
    " Composition Child라 ENTITY zi_b07_eine로 직접 못 읽으므로 Root를 거쳐 BY \_Eine로 조회.
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

ENDCLASS.
