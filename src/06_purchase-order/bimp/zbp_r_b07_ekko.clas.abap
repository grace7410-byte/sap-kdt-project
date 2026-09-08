// ============================================================
// 변경이력
// 2026-09-08  최초 작성. Elikz(입고완료) 삭제 제한, Waers(통화) 채번 전까지만 편집 가능하도록
//             인스턴스 피처 제어, early numbering 시 %is_draft 매핑 누락 수정
//             — devlog: ../../../devlog/rap-dev/2026-09-08.md
// ============================================================
CLASS lhc_zi_b07_ekpo DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ekpo RESULT result.

    METHODS SetInfoRecordDefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ekpo~SetInfoRecordDefault.

    METHODS SetItemDefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ekpo~SetItemDefaults.
    METHODS SetMaterialUuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Ekpo~SetMaterialUuid.
    METHODS CheckRequired FOR VALIDATE ON SAVE
      IMPORTING keys FOR Ekpo~CheckRequired.
    METHODS CheckDuplicateItem FOR VALIDATE ON SAVE
      IMPORTING keys FOR Ekpo~CheckDuplicateItem.

    METHODS CheckPositiveQty FOR VALIDATE ON SAVE
      IMPORTING keys FOR Ekpo~CheckPositiveQty.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zr_b07_ekko\_Ekpo.

ENDCLASS.

CLASS lhc_zi_b07_ekpo IMPLEMENTATION.

  METHOD get_instance_features.
    " 추가 구현(FS X): 입고완료(Elikz=X)된 아이템은 삭제 불가
    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY ekpo
        FIELDS ( Elikz )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekpo).

    CHECK lt_ekpo IS NOT INITIAL.

    " 추가 구현: 통화(Waers)는 아이템이 실제 DB에 이미 존재하면(=기존 저장분) 읽기전용
    SELECT ebeln_uuid, ebelp FROM ztb07ekpo
      FOR ALL ENTRIES IN @lt_ekpo
      WHERE ebeln_uuid = @lt_ekpo-EbelnUuid
        AND ebelp      = @lt_ekpo-Ebelp
      INTO TABLE @DATA(lt_db_ekpo).

    result = VALUE #( FOR ls_ekpo IN lt_ekpo
                        ( %tky    = ls_ekpo-%tky
                          %delete = COND #( WHEN ls_ekpo-Elikz = abap_true
                                             THEN if_abap_behv=>fc-o-disabled
                                             ELSE if_abap_behv=>fc-o-enabled )
                          %field-Waers
                                  = COND #( WHEN line_exists( lt_db_ekpo[ ebeln_uuid = ls_ekpo-EbelnUuid
                                                                          ebelp      = ls_ekpo-Ebelp ] )
                                            THEN if_abap_behv=>fc-f-read_only
                                            ELSE if_abap_behv=>fc-f-unrestricted ) ) ).
  ENDMETHOD.

  METHOD SetItemDefaults.
    DATA: lt_update TYPE TABLE FOR UPDATE zi_b07_ekpo.

    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY Ekpo
      BY \_Ekko
      FIELDS ( Waers )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekko_hdr).

    LOOP AT lt_ekko_hdr INTO DATA(ls_hdr).
      APPEND VALUE #( %tky  = ls_hdr-%tky
                       Waers = ls_hdr-Waers ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_ekko IN LOCAL MODE
        ENTITY Ekpo
          UPDATE FIELDS ( Waers )
          WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD SetInfoRecordDefault.
    DATA: lt_update TYPE TABLE FOR UPDATE zi_b07_ekpo.

    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY Ekpo
        FIELDS ( Infnr Werks Netpr )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekpo).

    DELETE lt_ekpo WHERE Infnr IS INITIAL.
    CHECK lt_ekpo IS NOT INITIAL.

    SELECT inf_uuid, infnr, mat_uuid FROM ztb07eina
      FOR ALL ENTRIES IN @lt_ekpo
      WHERE infnr = @lt_ekpo-Infnr
      INTO TABLE @DATA(lt_db_eina).

    SELECT inf_uuid, werks, netpr FROM ztb07eine
      FOR ALL ENTRIES IN @lt_db_eina
      WHERE inf_uuid = @lt_db_eina-inf_uuid
      INTO TABLE @DATA(lt_db_eine).

    SELECT mat_uuid, matnr, meins FROM ztb07mara
      FOR ALL ENTRIES IN @lt_db_eina
      WHERE mat_uuid = @lt_db_eina-mat_uuid
      INTO TABLE @DATA(lt_db_mara).

    LOOP AT lt_ekpo INTO DATA(ls_ekpo).
      READ TABLE lt_db_eina INTO DATA(ls_eina) WITH KEY infnr = ls_ekpo-Infnr.
      CHECK sy-subrc = 0.

      READ TABLE lt_db_mara INTO DATA(ls_mara) WITH KEY mat_uuid = ls_eina-mat_uuid.
      READ TABLE lt_db_eine INTO DATA(ls_eine) WITH KEY inf_uuid = ls_eina-inf_uuid
                                                         werks    = ls_ekpo-Werks.

      APPEND VALUE #( %tky    = ls_ekpo-%tky
                       MatUuid = ls_eina-mat_uuid
                       Matnr   = ls_mara-matnr
                       Meins   = ls_mara-meins
                       Netpr   = COND #( WHEN sy-subrc = 0 THEN ls_eine-netpr ELSE ls_ekpo-Netpr ) )
        TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_ekko IN LOCAL MODE
        ENTITY Ekpo
          UPDATE FIELDS ( MatUuid Matnr Meins Netpr )
          WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA: BEGIN OF ls_max,
            ebeln_uuid TYPE ztb07ekpo-ebeln_uuid,
            max_ebelp  TYPE ztb07ekpo-ebelp,
          END OF ls_max,
          lt_max LIKE TABLE OF ls_max.

    CHECK entities IS NOT INITIAL.

    SELECT ebeln_uuid, ebelp
      FROM ztb07ekpo
      FOR ALL ENTRIES IN @entities
      WHERE ebeln_uuid = @entities-EbelnUuid
      INTO TABLE @DATA(lt_db_ekpo).

    SORT lt_db_ekpo BY ebeln_uuid ASCENDING ebelp DESCENDING.

    LOOP AT lt_db_ekpo INTO DATA(ls_db_ekpo).
      AT NEW ebeln_uuid.
        INSERT VALUE #( ebeln_uuid = ls_db_ekpo-ebeln_uuid
                         max_ebelp  = ls_db_ekpo-ebelp ) INTO TABLE lt_max.
      ENDAT.
    ENDLOOP.

    LOOP AT entities INTO DATA(ls_entity).
      READ TABLE lt_max ASSIGNING FIELD-SYMBOL(<ls_max>)
        WITH KEY ebeln_uuid = ls_entity-EbelnUuid.
      IF sy-subrc <> 0.
        INSERT VALUE #( ebeln_uuid = ls_entity-EbelnUuid max_ebelp = 0 )
          INTO TABLE lt_max ASSIGNING <ls_max>.
      ENDIF.

      LOOP AT ls_entity-%target INTO DATA(ls_item).
        <ls_max>-max_ebelp += 10.

        " [수정 포인트] mapped 구조체 매핑
        " 1. %cid와 %is_draft 상태를 그대로 전달
        " 2. CDS View의 필드명(EbelnUuid, Ebelp)에 맞게 채번 결과 매핑
        INSERT VALUE #(
          %cid      = ls_item-%cid
          %is_draft = ls_item-%is_draft
          EbelnUuid = ls_entity-EbelnUuid
          Ebelp     = <ls_max>-max_ebelp
        ) INTO TABLE mapped-ekpo.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD SetMaterialUuid.
    DATA: lt_update TYPE TABLE FOR UPDATE zi_b07_ekpo.

    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY Ekpo
        FIELDS ( MatUuid Matnr Infnr )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekpo).

    SELECT mat_uuid, matnr FROM ztb07mara
      INTO TABLE @DATA(lt_db_mara).

    LOOP AT lt_ekpo INTO DATA(ls_ekpo)
         WHERE Infnr IS INITIAL AND MatUuid IS INITIAL AND Matnr IS NOT INITIAL.

      READ TABLE lt_db_mara INTO DATA(ls_mara) WITH KEY matnr = ls_ekpo-Matnr.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = ls_ekpo-%tky MatUuid = ls_mara-mat_uuid ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_ekko IN LOCAL MODE
        ENTITY Ekpo
          UPDATE FIELDS ( MatUuid )
          WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD CheckRequired.
    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY Ekpo
        FIELDS ( Werks )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekpo).

    LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE Werks IS INITIAL.
      APPEND VALUE #( %tky = ls_ekpo-%tky ) TO failed-ekpo.
      APPEND VALUE #( %tky = ls_ekpo-%tky
                       %element-Werks = if_abap_behv=>mk-on
                       %msg = new_message( id = 'ZMSGE_B07' number = '015'
                                            v1 = 'Plant' severity = if_abap_behv_message=>severity-error ) )
        TO reported-ekpo.
    ENDLOOP.
  ENDMETHOD.

  METHOD CheckDuplicateItem.
    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY Ekpo
        FIELDS ( EbelnUuid MatUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekpo).

    SELECT ebeln_uuid, ebelp, mat_uuid FROM ztb07ekpo
      FOR ALL ENTRIES IN @lt_ekpo
      WHERE ebeln_uuid = @lt_ekpo-EbelnUuid
      INTO TABLE @DATA(lt_db_ekpo).

    LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE MatUuid IS NOT INITIAL.
      DATA(lv_cnt) = REDUCE i( INIT n = 0
                                FOR ls_db IN lt_db_ekpo
                                WHERE ( ebeln_uuid = ls_ekpo-EbelnUuid
                                    AND mat_uuid    = ls_ekpo-MatUuid )
                                NEXT n = n + 1 ).

      IF lv_cnt > 1.
        APPEND VALUE #( %tky = ls_ekpo-%tky ) TO failed-ekpo.
        APPEND VALUE #( %tky = ls_ekpo-%tky
                         %msg = new_message( id = 'ZMSGE_B07' number = '017'
                                              v1 = 'Purchase Order Item' v2 = 'Material'
                                              severity = if_abap_behv_message=>severity-error ) )
          TO reported-ekpo.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD CheckPositiveQty.
    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY Ekpo
        FIELDS ( Menge )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekpo).

    LOOP AT lt_ekpo INTO DATA(ls_ekpo) WHERE Menge <= 0.
      APPEND VALUE #( %tky = ls_ekpo-%tky ) TO failed-ekpo.
      APPEND VALUE #( %tky = ls_ekpo-%tky
                       %element-Menge = if_abap_behv=>mk-on
                       %msg = new_message( id = 'ZMSGE_B07' number = '022'
                                            v1 = 'Quantity' severity = if_abap_behv_message=>severity-error ) )
        TO reported-ekpo.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZR_B07_EKKO DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_b07_ekko RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zr_b07_ekko RESULT result.

    METHODS SetHeaderDefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_ekko~SetHeaderDefaults.

    METHODS SetVendorUuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_ekko~SetVendorUuid.

    METHODS SetEbelnNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_b07_ekko~SetEbelnNumber.
    METHODS CheckRequired FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_ekko~CheckRequired.

    METHODS CheckVendorValid FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_ekko~CheckVendorValid.
    METHODS SetDeletionFlag FOR MODIFY
      IMPORTING keys FOR ACTION zr_b07_ekko~SetDeletionFlag RESULT result.
    METHODS CheckOrgData FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_ekko~CheckOrgData.

ENDCLASS.

CLASS lhc_ZR_B07_EKKO IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        FIELDS ( Ebeln )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekko).

    result = VALUE #( FOR ls_ekko IN lt_ekko
                        ( %tky            = ls_ekko-%tky
                          %delete         = COND #( WHEN ls_ekko-Ebeln IS NOT INITIAL
                                                     THEN if_abap_behv=>fc-o-disabled
                                                     ELSE if_abap_behv=>fc-o-enabled )
                          %action-SetDeletionFlag
                                          = COND #( WHEN ls_ekko-Ebeln IS NOT INITIAL
                                                     THEN if_abap_behv=>fc-o-enabled
                                                     ELSE if_abap_behv=>fc-o-disabled )
                          " 추가 구현: 통화(Waers)는 PO 채번(=최초 저장) 전까지만 편집 가능
                          %field-Waers    = COND #( WHEN ls_ekko-Ebeln IS NOT INITIAL
                                                     THEN if_abap_behv=>fc-f-read_only
                                                     ELSE if_abap_behv=>fc-f-unrestricted ) ) ).
  ENDMETHOD.

  METHOD SetHeaderDefaults.
    MODIFY ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        UPDATE FIELDS ( Bedat Waers )
        WITH VALUE #( FOR key IN keys
                        ( %tky  = key-%tky
                          Bedat = cl_abap_context_info=>get_system_date( )
                          Waers = 'KRW' ) ).
  ENDMETHOD.

  METHOD SetVendorUuid.
    DATA: lt_update TYPE TABLE FOR UPDATE zr_b07_ekko.

    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        FIELDS ( LifUuid Lifnr )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekko).

    SELECT lif_uuid, lifnr, name1 FROM ztb07lfa1
      INTO TABLE @DATA(lt_db_lfa1).

    LOOP AT lt_ekko INTO DATA(ls_ekko)
         WHERE LifUuid IS INITIAL AND Lifnr IS NOT INITIAL.

      READ TABLE lt_db_lfa1 INTO DATA(ls_db_lfa1) WITH KEY lifnr = ls_ekko-Lifnr.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky    = ls_ekko-%tky
                         LifUuid = ls_db_lfa1-lif_uuid
                         Name1   = ls_db_lfa1-name1 ) TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_ekko IN LOCAL MODE
        ENTITY zr_b07_ekko
          UPDATE FIELDS ( LifUuid Name1 )
          WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD SetEbelnNumber.
    DATA: lt_update TYPE TABLE FOR UPDATE zr_b07_ekko.

    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        FIELDS ( Ebeln )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekko).

    LOOP AT lt_ekko INTO DATA(ls_ekko) WHERE Ebeln IS INITIAL.
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '01'
              object      = 'ZNRB07_EBE'
            IMPORTING
              number      = DATA(lv_number) ).

          APPEND VALUE #( %tky  = ls_ekko-%tky
                           Ebeln = lv_number ) TO lt_update.

        CATCH cx_number_ranges INTO DATA(lx_nr).
          APPEND VALUE #( %tky = ls_ekko-%tky
                           %msg = new_message( id = 'ZMSGE_B07'
                                                number   = '009'
                                                v1       = 'Purchase Order Number Range'
                                                severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_ekko.
      ENDTRY.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_ekko IN LOCAL MODE
        ENTITY zr_b07_ekko
          UPDATE FIELDS ( Ebeln )
          WITH lt_update.
    ENDIF.
  ENDMETHOD.

  METHOD CheckRequired.
    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekko).

    LOOP AT lt_ekko INTO DATA(ls_ekko).
      IF ls_ekko-Bedat IS INITIAL.
        APPEND VALUE #( %tky = ls_ekko-%tky ) TO failed-zr_b07_ekko.
        APPEND VALUE #( %tky = ls_ekko-%tky
                         %element-Bedat = if_abap_behv=>mk-on
                         %msg = new_message( id = 'ZMSGE_B07'
                                              number = '015'
                                              v1 = 'Document Date'
                                              severity = if_abap_behv_message=>severity-error ) )
          TO reported-zr_b07_ekko.
      ENDIF.

      IF ls_ekko-LifUuid IS INITIAL.
        APPEND VALUE #( %tky = ls_ekko-%tky ) TO failed-zr_b07_ekko.
        APPEND VALUE #( %tky = ls_ekko-%tky
                         %element-LifUuid = if_abap_behv=>mk-on
                         %msg = new_message( id = 'ZMSGE_B07'
                                              number = '015'
                                              v1 = 'Vendor'
                                              severity = if_abap_behv_message=>severity-error ) )
          TO reported-zr_b07_ekko.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD CheckVendorValid.
    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        FIELDS ( LifUuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekko).

    SELECT lif_uuid, loevm FROM ztb07lfa1
      INTO TABLE @DATA(lt_db_lfa1).

    LOOP AT lt_ekko INTO DATA(ls_ekko) WHERE LifUuid IS NOT INITIAL.
      READ TABLE lt_db_lfa1 INTO DATA(ls_db_lfa1) WITH KEY lif_uuid = ls_ekko-LifUuid.

      IF sy-subrc <> 0 OR ls_db_lfa1-loevm = abap_true.
        APPEND VALUE #( %tky = ls_ekko-%tky ) TO failed-zr_b07_ekko.
        APPEND VALUE #( %tky = ls_ekko-%tky
                         %element-LifUuid = if_abap_behv=>mk-on
                         %msg = new_message( id = 'ZMSGE_B07'
                                              number   = '020'
                                              v1       = 'Vendor'
                                              v2       = 'blocked or not found'
                                              severity = if_abap_behv_message=>severity-error ) )
          TO reported-zr_b07_ekko.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD SetDeletionFlag.
    MODIFY ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        UPDATE FIELDS ( Loekz )
        WITH VALUE #( FOR key IN keys
                        ( %tky  = key-%tky
                          Loekz = abap_true ) ).

    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result
                        ( %tky   = ls_result-%tky
                          %param = ls_result ) ).
  ENDMETHOD.

  METHOD CheckOrgData.
    READ ENTITIES OF zr_b07_ekko IN LOCAL MODE
      ENTITY zr_b07_ekko
        FIELDS ( Bukrs Ekorg Ekgrp )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ekko).

    SELECT bukrs FROM t001 INTO TABLE @DATA(lt_t001).
    SELECT ekorg FROM t024e INTO TABLE @DATA(lt_t024e).
    SELECT ekgrp FROM t024 INTO TABLE @DATA(lt_t024).

    LOOP AT lt_ekko INTO DATA(ls_ekko).
      IF ls_ekko-Bukrs IS NOT INITIAL.
        READ TABLE lt_t001 TRANSPORTING NO FIELDS WITH KEY bukrs = ls_ekko-Bukrs.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = ls_ekko-%tky ) TO failed-zr_b07_ekko.
          APPEND VALUE #( %tky = ls_ekko-%tky
                           %element-Bukrs = if_abap_behv=>mk-on
                           %msg = new_message( id = 'ZMSGE_B07' number = '020'
                                                v1 = 'Company Code' v2 = ls_ekko-Bukrs
                                                severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_ekko.
        ENDIF.
      ENDIF.

      IF ls_ekko-Ekorg IS NOT INITIAL.
        READ TABLE lt_t024e TRANSPORTING NO FIELDS WITH KEY ekorg = ls_ekko-Ekorg.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = ls_ekko-%tky ) TO failed-zr_b07_ekko.
          APPEND VALUE #( %tky = ls_ekko-%tky
                           %element-Ekorg = if_abap_behv=>mk-on
                           %msg = new_message( id = 'ZMSGE_B07' number = '020'
                                                v1 = 'Purchasing Org' v2 = ls_ekko-Ekorg
                                                severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_ekko.
        ENDIF.
      ENDIF.

      IF ls_ekko-Ekgrp IS NOT INITIAL.
        READ TABLE lt_t024 TRANSPORTING NO FIELDS WITH KEY ekgrp = ls_ekko-Ekgrp.
        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = ls_ekko-%tky ) TO failed-zr_b07_ekko.
          APPEND VALUE #( %tky = ls_ekko-%tky
                           %element-Ekgrp = if_abap_behv=>mk-on
                           %msg = new_message( id = 'ZMSGE_B07' number = '020'
                                                v1 = 'Purchasing Group' v2 = ls_ekko-Ekgrp
                                                severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_ekko.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
