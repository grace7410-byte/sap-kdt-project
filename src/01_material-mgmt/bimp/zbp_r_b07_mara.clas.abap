// ============================================================
// 변경이력
// 2026-08-14  최초 작성 (SetInitialDefault, SetReadOnly) — devlog: ../../../devlog/rap-dev/2026-08-14.md
// 2026-08-17  Validation 메서드 실제 이름 확인 후 반영 (CheckInit/CheckMaterial/CheckSLoc/CheckCreated), get_instance_authorizations 덤프 이슈 확인 — devlog: ../../../devlog/rap-dev/2026-08-17.md
// 2026-08-20  get_instance_features 추가 (WAERS 동적 제어, 항상 read-only 버전) — devlog: ../../../devlog/rap-dev/2026-08-20.md
// 2026-08-21  get_instance_features 조건부 버전으로 개선(신규=편집가능/수정=readonly), SetReadOnly 무한루프 수정,
//             SetLanguageDefault 신규 추가(+무한루프 방지), CheckSpart 신규 추가 — devlog: ../../../devlog/rap-dev/2026-08-21.md
// 2026-08-24  SetLanguageDefault determination 제거, CheckMaraTextExist validation으로 전환 확정 — devlog: ../../../devlog/rap-dev/2026-08-24.md
// ============================================================
// NOTE: CheckInit/CheckCreated는 구현 완료 상태이나 코드 본문은 미확보라 선언만 추가.
//       CheckMaterial/CheckSLoc은 2026-08-17 기준 실제로 본문이 비어있는 상태.
CLASS lhc_ZR_B07_MARA DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_b07_mara RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zr_b07_mara RESULT result.

    METHODS SetInitialDefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_mara~SetInitialDefault.

    METHODS SetReadOnly FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_b07_mara~SetReadOnly.

    METHODS SetLanguageDefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaraText~SetLanguageDefault.

    " 아래 4개는 실제 Validation 메서드명 (2026-08-17 확인)
    METHODS CheckInit FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckInit.
    METHODS CheckMaterial FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckMaterial.
    METHODS CheckSLoc FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckSLoc.
    METHODS CheckCreated FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckCreated.
    METHODS CheckSpart FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckSpart.

ENDCLASS.

CLASS lhc_ZR_B07_MARA IMPLEMENTATION.

  " 2026-08-17: 아무것도 채우지 않고 그냥 리턴하면 프레임워크가
  " "요청한 키에 대한 권한 결과가 없다"고 판단해 BEHAVIOR_CONTRACT_VIOLATION 덤프를 던짐.
  " 결국 4번(Determination/Validation) 쪽 문제로 되돌아옴 — 해결 못한 이슈로 남음.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  " 2026-08-20: WAERS 정적 readonly가 Stprs(편집가능 금액필드)와 모순되어 활성화 에러 발생
  " ("A static read-only field 'WAERS' is not allowed for an editable amount field")
  " → 동적 제어(features)로 전환.
  " 2026-08-21: 항상 read-only였던 걸, "신규 생성 중"이면 편집 가능하고
  " "기존 데이터 수정 중"이면 read-only가 되도록 조건부로 개선.
  METHOD get_instance_features.
    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
      ENTITY zr_b07_mara
      FIELDS ( MatUuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_mara).

    DATA lt_result TYPE TABLE FOR FEATURES RESULT zr_b07_mara.

    " 루프를 돌면서, 찐 DB(ZTB07MARA)에 데이터가 있는지 파악
    LOOP AT lt_mara INTO DATA(ls_mara).

      " DB 조회 성공 = 기존 데이터를 '수정 중' / 조회 실패 = 새로 '생성 중'
      SELECT SINGLE mat_uuid
        FROM ztb07mara
        WHERE mat_uuid = @ls_mara-MatUuid
        INTO @DATA(lv_dummy).

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

  " 2026-08-21: 무한루프(ENDLESS_ON_SAVE_DUMP) 수정.
  " 이미 Matfi = 'X'인 레코드까지 계속 MODIFY하면 on-save determination이 매번 재트리거됨.
  " → 값이 실제로 바뀌어야 하는 경우에만 MODIFY하도록 필터링.
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

  " 2026-08-21: 신규 작성. 자재명(MaraText) 생성 시 시스템 로그온 언어로 Spras 기본값 세팅.
  " 마찬가지로 이미 Spras가 채워진 레코드는 제외해서 무한루프 방지.
  METHOD SetLanguageDefault.
    DATA lv_langu TYPE spras.
    TRY.
        lv_langu = cl_abap_context_info=>get_user_language_abap_format( ).
      CATCH cx_abap_context_info_error.
        lv_langu = sy-langu.
    ENDTRY.

    READ ENTITIES OF zr_b07_mara IN LOCAL MODE
      ENTITY MaraText
      FIELDS ( Spras )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_text).

    DATA lt_update TYPE TABLE FOR UPDATE zi_b07_maratext.

    LOOP AT lt_text INTO DATA(ls_text) WHERE Spras IS INITIAL.
      APPEND VALUE #( %tky  = ls_text-%tky
                       Spras = lv_langu ) TO lt_update.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_b07_mara IN LOCAL MODE
        ENTITY MaraText
          UPDATE FIELDS ( Spras )
          WITH lt_update
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).
    ENDIF.
  ENDMETHOD.

  " CheckInit: 구현 완료 (필수값 누락 체크) — 코드 본문 미확보, 추후 반영
  " CheckCreated: 구현 완료 (등록일 한 달 이내 체크) — 코드 본문 미확보, 추후 반영

  METHOD CheckMaterial.
    " TODO: 자재코드(Matnr) 중복 체크 — 2026-08-17 기준 미구현 (본문 비어있음)
  ENDMETHOD.

  METHOD CheckSLoc.
    " TODO: 플랜트-저장위치 정합성 체크 — 2026-08-17 기준 미구현 (본문 비어있음)
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

ENDCLASS.
