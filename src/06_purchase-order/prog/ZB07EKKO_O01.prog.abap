*&---------------------------------------------------------------------*
*& 변경이력
*& 2026-09-04  최초 작성. 100/101/103/104/130번 화면 관련 PBO 모듈 골격 생성.
*&             INIT_ALV_0101은 101번 벤더 리스트 ALV 실데이터 조회까지 구현 완료.
*&             INIT_ALV_0103/INIT_CHART_0103/INIT_CHART_0104는 F01 작성 전까지
*&             빈 스텁 상태 — devlog: ../../../devlog/rap-dev/2026-09-04.md
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZB07EKKO_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_CHECK OUTPUT
*&---------------------------------------------------------------------*
MODULE status_check OUTPUT.
  IMPORT gv_mode = gv_mode FROM MEMORY ID 'MODE_CHECK'.
  IMPORT gv_ebeln = gv_ebeln FROM MEMORY ID 'ZAPPR_DATA'.
  FREE MEMORY ID 'ZAPPR_DATA'. " 한번 쓰고 나면 메모리 해제
  " 외부에서 넘어온 모드값에 따라, '조회/수정'일 경우엔 다른 화면으로 즉시 전환
  IF gv_mode IS NOT INITIAL.
    CASE gv_mode.
      WHEN 'U'.
        SET SCREEN '0200'.   " ※200/300 유지 여부 결정 대기 중 — 잠정 그대로 둠
        LEAVE SCREEN.
      WHEN 'D'.
        SET SCREEN '0300'.
        LEAVE SCREEN.
    ENDCASE.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  " 최초 진입(신규 생성) 시 초기값 세팅
  IF gs_head-bsart IS INITIAL.
    PERFORM set_init_user_data.
    gs_head-bsart = 'NB'.
    gs_head-bedat = sy-datum.
    gs_head-waers = 'KRW'.        " 신규 — 06 FS §4.1 "생성시 기본값 KRW"
    gv_visible = 'X'.
    SET CURSOR FIELD 'GS_HEAD-LIFNR'.   " 옛 GS_HEAD-BPID
  ENDIF.
  SET PF-STATUS 'S100'.
  SET TITLEBAR 'T100'.
  PERFORM control_header_screen.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV OUTPUT (100번 아이템 ALV 초기화 — 항상 표시)
*&---------------------------------------------------------------------*
MODULE init_alv OUTPUT.
  PERFORM set_init_item_rows.
  IF go_cont IS INITIAL.
    PERFORM create_object USING 'AREA' 'X' CHANGING go_cont go_alv.
    PERFORM set_layout USING 1 CHANGING gs_layout.
    PERFORM set_uifunc USING 1 CHANGING gt_uifunc.
    PERFORM set_fcat_item CHANGING gt_fcat_item.
*    SET HANDLER lcl_event_handler=>on_toolbar FOR go_alv.
*    SET HANDLER lcl_event_handler=>on_user_command FOR go_alv.
*    SET HANDLER lcl_event_handler=>on_data_changed FOR go_alv.
    PERFORM display_alv USING gs_layout gt_uifunc gt_fcat_item
                        CHANGING go_alv gt_item.
  ELSE.
    PERFORM set_item_number.
    PERFORM set_fcat_item CHANGING gt_fcat_item.
    go_alv->set_frontend_fieldcatalog( it_fieldcatalog = gt_fcat_item ).
    go_alv->refresh_table_display( ).
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_DYNNR_TAB OUTPUT (TABSTRIP 하위 서브스크린 결정 — 항상 활성)
*&---------------------------------------------------------------------*
MODULE set_dynnr_tab OUTPUT.
  CASE tabstrip-activetab.
    WHEN 'TAB1'.
      gv_dynnr_tab = '0103'.
    WHEN 'TAB2'.
      gv_dynnr_tab = '0104'.
    WHEN OTHERS.
      gv_dynnr_tab = '0103'.
      tabstrip-activetab = 'TAB1'.
  ENDCASE.
  " 오류/데이터없음 폴백 — 둘 중 하나라도 해당되면 9000(빈 화면)으로
  IF gs_head-lifnr IS INITIAL OR gv_chart_show IS INITIAL.
    gv_dynnr_tab = '9000'.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN_0100 OUTPUT (필드 잠금만 — 화면표시 토글 없음)
*&---------------------------------------------------------------------*
MODULE modify_screen_0100 OUTPUT.
  PERFORM control_header_screen.
  LOOP AT SCREEN.
    IF screen-group1 = 'G3'.
      IF gv_chart_show = 'X'.
        screen-active = '1'.
      ELSE.
        screen-active = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0101 OUTPUT (101번 벤더 리스트 ALV 초기화)
*&---------------------------------------------------------------------*
MODULE init_alv_0101 OUTPUT.
  PERFORM get_vendor_all_data.
  IF go_cont_vend IS INITIAL.
    PERFORM create_object USING 'VENDOR' '' CHANGING go_cont_vend go_alv_vend.
    PERFORM set_layout USING 4 CHANGING gs_layo_vend.
    PERFORM set_uifunc USING 2 CHANGING gt_uifunc_vend.
    PERFORM set_fcat_vend CHANGING gt_fcat_vend.
    SET HANDLER lcl_event_handler=>on_hotspot_click FOR go_alv_vend.
    PERFORM display_alv USING gs_layo_vend gt_uifunc_vend gt_fcat_vend
                        CHANGING go_alv_vend gt_vend.
  ELSE.
    go_alv_vend->refresh_table_display( ).
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0140 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0130 OUTPUT.
 SET PF-STATUS 'S130'.
 SET TITLEBAR 'T130' WITH gs_vend-lifnr.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_ALV_0103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_0103 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_CHART_0103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_chart_0103 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_CHART_0104 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_chart_0104 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
