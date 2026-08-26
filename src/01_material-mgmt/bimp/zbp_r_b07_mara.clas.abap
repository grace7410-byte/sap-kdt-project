// ============================================================
// 변경이력
// 2026-08-14  최초 작성 (SetInitialDefault, SetReadOnly) — devlog: ../../../devlog/rap-dev/2026-08-14.md
// 2026-08-17  Validation 메서드 구현 (CheckInit/CheckMaterial/CheckSLoc/CheckCreated/CheckBklas) — devlog: ../../../devlog/rap-dev/2026-08-17.md
//             Determination 메서드 구현 (SetMeinsDefalut) — devlog: ../../../devlog/rap-dev/2026-08-17.md
// 2026-08-20  get_instance_features 추가 (WAERS 동적 제어, 항상 read-only 버전) — devlog: ../../../devlog/rap-dev/2026-08-20.md
// 2026-08-21  get_instance_features 조건부 버전으로 개선(신규=편집가능/수정=readonly), SetReadOnly 무한루프 수정,
//             CheckSpart 신규 추가 — devlog: ../../../devlog/rap-dev/2026-08-21.md
// 2026-08-24  MaraText(child) behavior를 별도 핸들러 클래스(lhc_maratext)로 분리, SetLanguageDefault 제거,
//             CheckMaraTextExist validation으로 전환 확정 — devlog: ../../../devlog/rap-dev/2026-08-24.md
// 2026-08-25  강사 피드백 반영: CheckBklas에 자재타입-평가클래스 조합 검증(message 022) 추가,
//             CheckPositive 신규 추가(Stprs/Peinh 0 방지, message 023) — devlog: ../../../devlog/rap-dev/2026-08-25.md
// ============================================================
CLASS lhc_maratext DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CheckMaraTextExist FOR VALIDATE ON SAVE
      IMPORTING keys FOR MaraText~CheckMaraTextExist.

ENDCLASS.

CLASS lhc_maratext IMPLEMENTATION.

  METHOD CheckMaraTextExist.
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
      ENTITY zr_b07_mara
      BY \_MaraText
      FIELDS ( Spras )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_text)
      FAILED DATA(lt_failed_read).

    LOOP AT keys INTO DATA(ls_key).
      READ TABLE lt_text WITH KEY %tky-MatUuid = ls_key-%tky-MatUuid
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = ls_key-%tky ) TO failed-zr_b07_mara.
        APPEND VALUE #( %tky = ls_key-%tky
                         %msg = new_message( id = 'ZMSGE_B07'
                                              number = '015'
                                              v1 = 'Material Name'
                                              severity = if_abap_behv_message=>severity-error ) )
          TO reported-zr_b07_mara.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.




CLASS lhc_zr_b07_mara DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_b07_mara RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zr_b07_mara RESULT result.

    METHODS setinitialdefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_mara~setinitialdefault.

    METHODS setreadonly FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_b07_mara~setreadonly.
    METHODS checkcreated FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~checkcreated.

    METHODS checkinit FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~checkinit.

    METHODS checkmaterial FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~checkmaterial.

    METHODS checksloc FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~checksloc.
    METHODS setmeinsdefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_mara~setmeinsdefault.
    METHODS checkbklas FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~checkbklas.
    METHODS checkspart FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~checkspart.
    METHODS checkpositive FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~checkpositive.

ENDCLASS.

CLASS lhc_zr_b07_mara IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.


  METHOD get_instance_features.
    " 항상 조회 전용으로 하려면 아래 코드만 작성하면 끝
*    result = VALUE #( FOR key IN keys
*                         ( %tky          = key-%tky
*                           %field-Waers  = if_abap_behv=>fc-f-read_only ) ).

    " 통화 WAERS는 항상 READ ONLY로, 나머지는 수정 시에만 가능하도록 설정하기
    " 먼저 Uuid를 조회한 뒤
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
      ENTITY zr_b07_mara
      FIELDS ( MatUuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mara).

    DATA lt_result TYPE TABLE FOR FEATURES RESULT zr_b07_mara.

    " 루프를 돌면서, 찐 DB(ZTB07MARA)에 데이터가 있는지 파악 =>
    LOOP AT lt_mara INTO DATA(ls_mara).

      " dummy에 데이터 조회 성공했다면 => 새로 데이터를 생성하고 있는 게 아니라 기존 데이터를 '수정 중'
      SELECT SINGLE mat_uuid
        FROM ztb07mara
        WHERE mat_uuid = @ls_mara-MatUuid
        INTO @DATA(lv_dummy).

      " 조회 성공 = 수정 중 = read only 처리
      " 조회 실패 = 새로 생성 중 = 편집 가능 모드
      DATA(lv_readonly) = COND #( WHEN sy-subrc = 0
                                   THEN if_abap_behv=>fc-f-read_only
                                   ELSE if_abap_behv=>fc-f-unrestricted ).

      APPEND VALUE #( %tky        = ls_mara-%tky
                      %field-Werks = lv_readonly
                      %field-Lgort = lv_readonly
                      %field-Mtart = lv_readonly
                      %field-Bklas = lv_readonly
                      %field-Matnr = lv_readonly
                      %field-Ersda = lv_readonly
                      %field-Waers = if_abap_behv=>fc-f-read_only   " 통화는 항상 조회전용
                    ) TO lt_result.
    ENDLOOP.

    result = lt_result.
  ENDMETHOD.

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

    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
    ENTITY zr_b07_mara
    FIELDS ( Matfi )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mara).

    DATA lt_update TYPE TABLE FOR UPDATE zr_b07_mara.

    " 이미 'X'인 레코드는 업데이트하지 않기
    LOOP AT lt_mara INTO DATA(ls_mara) WHERE Matfi <> 'X'.
      APPEND VALUE #( %tky  = ls_mara-%tky
                       Matfi = 'X' ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_mara IN LOCAL MODE
        ENTITY zr_b07_mara
          UPDATE FIELDS ( Matfi )
          WITH lt_update
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).
    ENDIF.
  ENDMETHOD.

  METHOD SetMeinsDefault.
    DATA lt_update TYPE TABLE FOR UPDATE zr_b07_mara.

    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
      ENTITY zr_b07_mara
      FIELDS ( Meins )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mara).

    LOOP AT lt_mara INTO DATA(ls_mara) WHERE Meins IS INITIAL.
      APPEND VALUE #( %tky  = ls_mara-%tky
                       Meins = 'EA' ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_mara IN LOCAL MODE
        ENTITY zr_b07_mara
          UPDATE FIELDS ( Meins )
          WITH lt_update
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).
    ENDIF.
  ENDMETHOD.

  METHOD CheckCreated.
    " Read Data
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
    ENTITY zr_b07_mara
    FIELDS ( Ersda )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mara).

*    DATA(lv_datum) = sy-datum+0(4) + ( sy-datum+4(2)
    DATA(lv_datum) = cl_abap_context_info=>get_system_date( ) - 30.

    LOOP AT lt_mara INTO DATA(ls_mara).
      IF ls_mara-Ersda > sy-datum OR ls_mara-ersda < lv_datum.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Ersda = if_abap_behv=>mk-on
*                        %state_area = 'TODO'
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '016'
                                            v1 = lv_datum
                                            v2 = sy-datum
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD CheckInit.
    " Read Data
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
    ENTITY zr_b07_mara
    FIELDS ( Werks Lgort Mtart Bklas Matnr )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mara).

    LOOP AT lt_mara INTO DATA(ls_mara).
      IF ls_mara-Werks IS INITIAL.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Werks = if_abap_behv=>mk-on
*                        %state_area = 'TODO'
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '015'
                                            v1 = 'Plant'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
      IF ls_mara-Lgort IS INITIAL.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Lgort = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '015'
                                            v1 = 'Storage Location'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
      IF ls_mara-Matnr IS INITIAL.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Matnr = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '015'
                                            v1 = 'Material Number'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
      IF ls_mara-Mtart IS INITIAL.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Mtart = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '015'
                                            v1 = 'Material Type'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
      IF ls_mara-Bklas IS INITIAL.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Bklas = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '015'
                                            v1 = 'Valuation Class'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD CheckMaterial.
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
  ENTITY zr_b07_mara
  FIELDS ( Matnr )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_mara).

    LOOP AT lt_mara INTO DATA(ls_mara) WHERE Matnr IS NOT INITIAL.
      SELECT SINGLE mat_uuid
        FROM ztb07mara
        WHERE matnr = @ls_mara-Matnr
          AND mat_uuid <> @ls_mara-MatUuid
        INTO @DATA(lv_dummy).

      IF sy-subrc = 0.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Matnr = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '017'
                                            v1 = 'Material'
                                            v2 = ls_mara-Matnr
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD CheckSLoc.
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
    ENTITY zr_b07_mara
    FIELDS ( Werks Lgort )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_mara).

    LOOP AT lt_mara INTO DATA(ls_mara)
         WHERE Werks IS NOT INITIAL AND Lgort IS NOT INITIAL.

      SELECT SINGLE werks
        FROM t001l
        WHERE werks = @ls_mara-Werks
          AND lgort = @ls_mara-Lgort
        INTO @DATA(lv_werks).

      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Lgort = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '018'
                                            v1 = ls_mara-Lgort
                                            v2 = ls_mara-Werks
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  " 2026-08-17: 평가클래스(Bklas) 값이 FS 요구 범위(3000/3300/7900/7920)를 벗어나는지 체크.
  " 2026-08-25: 강사 피드백 반영 — 자재타입-평가클래스 조합이 FS 매핑에 맞는지 체크하는 두 번째 IF 추가.
  " FS 매핑: FERT->7920, HALB->7900, HAWA/ROH->3000, HIBE/VERP->3300(비평가자재).
  METHOD CheckBklas.
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
      ENTITY zr_b07_mara
      FIELDS ( Bklas Mtart )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mara).

    LOOP AT lt_mara INTO DATA(ls_mara) WHERE Bklas IS NOT INITIAL.
      IF ls_mara-Bklas <> '3000' AND
         ls_mara-Bklas <> '3300' AND
         ls_mara-Bklas <> '7900' AND
         ls_mara-Bklas <> '7920'.

        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Bklas = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '019'
                                            v1 = 'Valuation Class'
                                            v2 = ls_mara-Bklas
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.

      " 2026-08-25 신규: 강사 피드백 반영 — 자재타입과 평가클래스 조합이 FS 매핑에 맞는지 체크
      IF ( ls_mara-Bklas = '3000' AND ls_mara-Mtart <> 'ROH' AND ls_mara-Mtart <> 'HAWA' )
        OR ( ls_mara-Bklas = '3300' AND ls_mara-Mtart <> 'HIBE' AND ls_mara-Mtart <> 'VERP' )
        OR ( ls_mara-Bklas = '7900' AND ls_mara-Mtart <> 'HALB' )
        OR ( ls_mara-Bklas = '7920' AND ls_mara-Mtart <> 'FERT' ).

        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Bklas = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '022'
                                            v1 = ls_mara-Mtart
                                            v2 = ls_mara-Bklas
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  " 2026-08-21: 신규 작성. 제품군(Spart) 필수값 + 자재타입별 허용 범위 체크.
  METHOD CheckSpart.
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
      ENTITY zr_b07_mara
      FIELDS ( Mtart Spart )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mara).

    LOOP AT lt_mara INTO DATA(ls_mara).

      " 제품군은 필수값 - 비어있으면 안 됨
      IF ls_mara-Spart IS INITIAL.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Spart = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '015'
                                            v1 = 'Division'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
        CONTINUE.
      ENDIF.

      " 자재타입(Mtart)에 맞는 제품군(Spart) 범위인지 체크
      DATA(lv_valid) = abap_false.

      CASE ls_mara-Mtart.
        WHEN 'FERT' OR 'HALB'.
          IF ls_mara-Spart = '10'.
            lv_valid = abap_true.
          ENDIF.
        WHEN 'HAWA' OR 'VERP'.
          IF ls_mara-Spart = '20'.
            lv_valid = abap_true.
          ENDIF.
        WHEN 'ROH'.
          IF ls_mara-Spart = '20' OR ls_mara-Spart = '30'.
            lv_valid = abap_true.
          ENDIF.
        WHEN 'HIBE'.
          IF ls_mara-Spart = '30'.
            lv_valid = abap_true.
          ENDIF.
        WHEN OTHERS.
          " 정의된 6가지 자재타입 외에는 '00(공통)'만 허용
          IF ls_mara-Spart = '00'.
            lv_valid = abap_true.
          ENDIF.
      ENDCASE.

      IF lv_valid = abap_false.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Spart = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '021'
                                            v1 = ls_mara-Mtart
                                            v2 = ls_mara-Spart
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  " 2026-08-25: 신규 작성. 강사 피드백 반영 — 표준가격(Stprs)/가격단위(Peinh) 0 방지.
  " 강사 지시는 "가격"만 0이 아니게 하는 것이었으나, 가격단위도 최소 1은 되어야 한다고 판단해 함께 체크.
  METHOD CheckPositive.
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
      ENTITY zr_b07_mara
      FIELDS ( Stprs Peinh )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mara).

    LOOP AT lt_mara INTO DATA(ls_mara).
      IF ls_mara-Stprs <= 0. "표준 가격은 0보다 커야 한다.
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Stprs = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '023'
                                            v1 = 'Standard Price'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.

      IF ls_mara-Peinh <= 0. " 가격 단위 역시 1, 2, ... 등 양수가 되어야 한다. (다행히 Peinh가 정수 타입)
        APPEND VALUE #( %tky = ls_mara-%tky ) TO failed-zr_b07_mara.

        APPEND VALUE #( %tky = ls_mara-%tky
                        %element-Peinh = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZMSGE_B07'
                                            number = '023'
                                            v1 = 'Price Unit'
                                            severity = if_abap_behv_message=>severity-error ) )
            TO reported-zr_b07_mara.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
