*&---------------------------------------------------------------------*
*& 변경이력
*& 2026-09-04  최초 작성. USER_COMMAND_0100/EXIT 골격 생성. 실제 처리 로직(PERFORM)은
*&             대부분 F01 작성 전까지 주석 처리 상태 — devlog: ../../../devlog/rap-dev/2026-09-04.md
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZB07EKKO_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA(lv_ok_code) = ok_code.
  CLEAR ok_code.
  DATA: lv_subrc TYPE sy-subrc.
  CASE lv_ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
      " WHEN 'INFO'. 제거 — 120(안내팝업) 스킵 확정에 따라 관련 분기 전체 삭제
      " WHEN 'ITEM_OVERVIEW'. 삭제 — gv_visible 토글 자체가 없음
    WHEN 'TAB1' OR 'TAB2'.
      tabstrip-activetab = lv_ok_code.
    when 'SEL_VEND'.               " 옛 103(팝업) → 신규 130에서 호출됨
      gs_head-lifnr = gs_vend-lifnr.
      LEAVE TO SCREEN 0.
    WHEN 'CHECK'.
*      PERFORM check_data_before_save CHANGING lv_subrc.
      CLEAR lv_subrc.
    WHEN 'SAVE'.
*      PERFORM check_data_before_save CHANGING lv_subrc.
      CHECK lv_subrc = 0.
      CLEAR gv_answer.
*      PERFORM confirm_save CHANGING gv_answer.
      CHECK gv_answer = 'J'.
      IF gv_mode = 'U'.
*        PERFORM update_po_data.
      ELSE.
*        PERFORM save_po_data.
      ENDIF.
      IF gv_save_check = 'X'.
        IF gv_mode = 'U'.
*          PERFORM get_edit_data.
          go_alv->refresh_table_display( ).
        ELSE.
          MESSAGE s100(zmsge_b07) WITH gv_po_ebeln.   " 저장완료
        ENDIF.
      ENDIF.
    WHEN 'DELETE_ALL'.
      DATA: lv_text   TYPE string,
            lv_answer TYPE c.
      lv_text = |구매오더 { gv_ebeln }을(를) 취소 처리합니다. 계속하시겠습니까?|.
*      PERFORM confirm_delete USING lv_text CHANGING lv_answer.
      IF lv_answer = '1'.
*        PERFORM delete_po_all.
      ENDIF.
    WHEN 'DELETE_ITEM'.
*      PERFORM delete_selected_items.
      " WHEN 'BSART'.
      " WHEN 'PURC'.
    WHEN 'GO_DELETE'.
      gv_mode = 'D'.
      CLEAR: gs_head, gt_item.
      CALL SCREEN 300.            " ※200/300 유지 여부 결정 대기 중
    WHEN 'GO_ERASE'.
      gv_mode = 'U'.
      CLEAR: gs_head, gt_item.
      CALL SCREEN 200.
    WHEN OTHERS.
      IF gs_head-lifnr IS NOT INITIAL.
        IF gs_head-lifnr <> gv_before_lifnr.
*          PERFORM get_header_data.
*          PERFORM get_vendor_data USING '' gs_head-lifnr.
          IF gv_visible = 'X'.
*            PERFORM get_opti_data.
          ENDIF.
          gv_before_lifnr = gs_head-lifnr.
        ENDIF.
      ELSE.
*        PERFORM get_vendor_all_data.
        IF gv_visible = 'X'.
*          PERFORM get_opti_data.
        ENDIF.
*        PERFORM clear_header_data.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module EXIT INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  CASE ok_code.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
