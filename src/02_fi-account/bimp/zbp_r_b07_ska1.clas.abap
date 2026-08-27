// ============================================================
// 변경이력
// 2026-08-17  최초 작성 (클래스 지정만, 커스텀 로직 없음 — 완전 Managed) — devlog: ../../../devlog/rap-dev/2026-08-17.md
// 2026-08-26  CheckDuplicate(계정번호 중복 체크), CheckExist(회사코드/통화/조정계정유형 존재 여부 체크) 신규 추가 — devlog: ../../../devlog/rap-dev/2026-08-26.md
// ============================================================
CLASS lhc_ZR_B07_SKA1 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS CheckDuplicate FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_ska1~CheckDuplicate.

    METHODS CheckExist FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_ska1~CheckExist.

ENDCLASS.

CLASS lhc_ZR_B07_SKA1 IMPLEMENTATION.

  METHOD CheckDuplicate.
    READ ENTITIES OF zr_b07_ska1 IN LOCAL MODE
      ENTITY zr_b07_ska1
      FIELDS ( Saknr ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ska1).
    SELECT saknr FROM ztb07ska1
        INTO TABLE @DATA(lt_db_saknr). " 중복 확인할 테이블을 미리 담아두기
    LOOP AT lt_ska1 INTO DATA(ls_ska1).
      READ TABLE lt_db_saknr INTO DATA(lv_db_saknr) WITH KEY saknr = ls_ska1-Saknr.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = ls_ska1-%tky ) TO failed-zr_b07_ska1.
        APPEND VALUE #(   %tky = ls_ska1-%tky
                          %element-Saknr = if_abap_behv=>mk-on
                          %msg = new_message(
                                    id       = 'ZMSGE_B07'
                                    number   = '017'
                                    v1       = 'Account'
                                    v2 = ls_ska1-Saknr
                                    severity = if_abap_behv_message=>severity-error )
                        ) TO reported-zr_b07_ska1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD CheckExist.
    READ ENTITIES OF zr_b07_ska1 IN LOCAL MODE
      ENTITY zr_b07_ska1
      FIELDS ( Bukrs Waers Mitkz ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_ska1).

    SELECT bukrs FROM t001
        INTO TABLE @DATA(lt_db_bukrs). " T001에 담긴 회사코드인지 확인할 용도로 미리 조회 (K200)

    SELECT waers FROM tcurc
        INTO TABLE @DATA(lt_db_waers). " 마찬가지로 원본 테이블 tcurc 데이터 확인용으로 미리 조회

    SELECT mitkz FROM zi_b07_mitkz_f4
        INTO TABLE @DATA(lt_db_mitkz). " 직접 만든 서치헬프용으로 5개 값만 미리 담기

    LOOP AT lt_ska1 INTO DATA(ls_ska1).
      READ TABLE lt_db_bukrs TRANSPORTING NO FIELDS WITH KEY bukrs = ls_ska1-Bukrs.
      IF sy-subrc <> 0 AND ls_ska1-Bukrs IS NOT INITIAL. " 회사코드를 입력한 경우에만 값 검증!
        APPEND VALUE #( %tky = ls_ska1-%tky ) TO failed-zr_b07_ska1.
        APPEND VALUE #(   %tky = ls_ska1-%tky
                          %element-Bukrs = if_abap_behv=>mk-on
                          %msg = new_message(
                                    id       = 'ZMSGE_B07'
                                    number   = '019'
                                    v1       = 'Company Code'
                                    v2 = ls_ska1-Bukrs
                                    severity = if_abap_behv_message=>severity-error )
                        ) TO reported-zr_b07_ska1.
      ENDIF.

      READ TABLE lt_db_waers TRANSPORTING NO FIELDS WITH KEY waers = ls_ska1-Waers.
      IF sy-subrc <> 0 AND ls_ska1-Waers IS NOT INITIAL. " 통화키를 입력한 경우에만 값 검증!
        APPEND VALUE #( %tky = ls_ska1-%tky ) TO failed-zr_b07_ska1.
        APPEND VALUE #(   %tky = ls_ska1-%tky
                          %element-Waers = if_abap_behv=>mk-on
                          %msg = new_message(
                                    id       = 'ZMSGE_B07'
                                    number   = '019'
                                    v1       = 'Currency'
                                    v2 = ls_ska1-Waers
                                    severity = if_abap_behv_message=>severity-error )
                        ) TO reported-zr_b07_ska1.
      ENDIF.

      READ TABLE lt_db_mitkz TRANSPORTING NO FIELDS WITH KEY mitkz = ls_ska1-Mitkz.
      IF sy-subrc <> 0 AND ls_ska1-Mitkz IS NOT INITIAL. " 값을 입력한 경우에만 검증할 수 있도록 하기!
        APPEND VALUE #(   %tky = ls_ska1-%tky ) TO failed-zr_b07_ska1.
        APPEND VALUE #(   %tky = ls_ska1-%tky
                          %element-Mitkz = if_abap_behv=>mk-on
                          %msg = new_message(
                                    id       = 'ZMSGE_B07'
                                    number   = '019'
                                    v1       = 'Reconciliation Account Type'
                                    v2 = ls_ska1-Mitkz
                                    severity = if_abap_behv_message=>severity-error )
                        ) TO reported-zr_b07_ska1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
