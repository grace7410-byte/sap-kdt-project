*&---------------------------------------------------------------------*
*& 변경이력
*& 2026-09-06  최초 작성. 101번 벤더 ALV 핫스팟(LIFNR/NAME1) 클릭 시 130번 팝업을
*&             호출하는 이벤트 핸들러 클래스 신규 생성 — devlog: ../../../devlog/rap-dev/2026-09-06.md
*& 2026-09-07  ON_HOTSPOT_CLICK: 130 취소(미선택 종료) 시 GV_EKORG/GV_EKGRP를 헤더 자신의 값 기준으로
*&             원복하는 ELSE 분기 추가 — devlog: ../../../devlog/rap-dev/2026-09-07.md
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZB07EKKO_C01
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      "[101번] 벤더 ALV에서 핫스팟(LIFNR/NAME1) 클릭 시 130번 팝업 호출
      on_hotspot_click FOR EVENT hotspot_click
        OF cl_gui_alv_grid IMPORTING e_row_id e_column_id.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_hotspot_click.
    " 1. 핫스팟 대상 컬럼인지 확인 — 공급업체번호/공급업체명 컬럼만 반응
    CHECK e_column_id-fieldname = 'LIFNR' OR e_column_id-fieldname = 'NAME1'.

    " 2. 클릭된 행의 벤더(LIFNR)로 상세 조회
    READ TABLE gt_vend INTO DATA(ls_selected_vend) INDEX e_row_id-index.
    IF sy-subrc = 0.
      " 3. 팝업용 조회(pv_pop = 'X') — gs_vend에 벤더 상세 채움
      PERFORM get_vendor_data USING 'X' ls_selected_vend-lifnr.

      " 4. gs_vend가 정상적으로 채워졌으면 130번 팝업 호출
      IF gs_vend-lifnr IS NOT INITIAL.
        CALL SCREEN '0130' STARTING AT 50 5
                           ENDING   AT 135 25.
      ENDIF.

      " 5. 팝업에서 SEL_VEND로 선택한 벤더가 방금 클릭한 벤더와 같으면(=방금 선택됨)
      "    I01의 WHEN OTHERS는 gs_head-lifnr <> gv_before_lifnr일 때만 도니까,
      "    102번 서브스크린 전환이 즉시 반영되도록 PAI를 한 번 강제로 더 돌림
      IF gs_head-lifnr = gs_vend-lifnr.
        cl_gui_cfw=>set_new_ok_code( EXPORTING new_code = 'ENTER' ).
      ELSE.
        PERFORM refresh_ekorg_ekgrp_text USING gs_head-ekorg gs_head-ekgrp.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
