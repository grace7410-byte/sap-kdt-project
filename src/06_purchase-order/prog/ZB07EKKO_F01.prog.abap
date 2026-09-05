*&---------------------------------------------------------------------*
*& 변경이력
*& 2026-09-04  최초 작성. 100번 아이템 ALV 공통 유틸(set_item_number ~ control_header_screen)
*&             + 101번 벤더 리스트 조회(set_fcat_vend/get_vendor_all_data)
*&             + 102/130번 공용 벤더 상세 조회(get_vendor_data/get_domain_text)까지 구현.
*&             104번(BOM 차트) 관련 Form은 아직 미착수 — devlog: ../../../devlog/rap-dev/2026-09-04.md
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZB07EKKO_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_item_number (아이템 순번 10/20/30... 재계산 + ALV refresh)
*&---------------------------------------------------------------------*
FORM set_item_number.
  LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
    <fs_item>-ebelp = sy-tabix * 10.
  ENDLOOP.
  CHECK go_alv IS BOUND.
  go_alv->refresh_table_display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_item_rows (아이템 ALV 최초 빈 줄 10개 채우기)
*&---------------------------------------------------------------------*
FORM set_init_item_rows.
  IF gt_item IS INITIAL.
    DO 10 TIMES.
      APPEND INITIAL LINE TO gt_item.
    ENDDO.
    PERFORM set_item_number.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_object (커스텀 컨테이너 + ALV Grid 생성)
*&---------------------------------------------------------------------*
FORM create_object USING pv_area TYPE c
                         pv_basic TYPE c
                  CHANGING po_cont TYPE REF TO cl_gui_custom_container
                           po_alv TYPE REF TO cl_gui_alv_grid.
  CREATE OBJECT po_cont
    EXPORTING
      container_name              = pv_area
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  CREATE OBJECT po_alv
    EXPORTING
      i_parent          = po_cont
    EXCEPTIONS
      error_cntl_create = 1
      error_cntl_init   = 2
      error_cntl_link   = 3
      error_dp_create   = 4
      OTHERS            = 5.
  IF pv_basic = 'X'.
    po_alv->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_enter ).
    po_alv->register_edit_event( i_event_id = cl_gui_alv_grid=>mc_evt_modified ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout (ALV 레이아웃 — pv_type별 분기)
*&---------------------------------------------------------------------*
FORM set_layout USING pv_type TYPE i
                CHANGING ps_layout TYPE lvc_s_layo.
  CLEAR ps_layout.
  ps_layout-zebra    = 'X'.
  ps_layout-sel_mode = 'A'.
  IF pv_type = 1.                        " 100번 아이템 ALV
    ps_layout-grid_title = '구매오더 아이템'.
    IF gv_mode <> 'D'.
      ps_layout-sel_mode = 'B'.
    ENDIF.
  ELSEIF pv_type = 2.                    " 103번 옵션가(EINA/EINE 단가)
    ps_layout-grid_title = '구매정보레코드 기준 단가'.
  ELSEIF pv_type = 3.                    " (200/300 결정 대기) PO 목록
    ps_layout-grid_title = '구매오더 목록'.
    ps_layout-sel_mode   = 'B'.
    ps_layout-cwidth_opt = 'X'.
  ELSEIF pv_type = 4.                    " 101번 벤더 리스트
    ps_layout-grid_title = '공급업체 목록'.
    ps_layout-cwidth_opt = 'X'.
  ELSEIF pv_type = 5.                    " 104번 BOM 비교
    ps_layout-grid_title = '전사 BOM 구성 비교'.
    ps_layout-cwidth_opt = 'X'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_uifunc (ALV 툴바 제외 기능 설정)
*&---------------------------------------------------------------------*
FORM set_uifunc USING pv_type TYPE i
                      pt_uifunc  TYPE ui_functions.
  REFRESH pt_uifunc.
  IF pv_type = 100.
    " 100번 아이템 ALV — 현재 전부 노출(제외 없음), 필요시 추후 조정
  ELSE.                                  " 옵티/벤더/전체 등 조회전용 ALV
    APPEND cl_gui_alv_grid=>mc_fc_excl_all TO pt_uifunc.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_item (100번 아이템 ALV 필드카탈로그)
*&---------------------------------------------------------------------*
FORM set_fcat_item CHANGING ct_fcat_item TYPE lvc_t_fcat.
  REFRESH ct_fcat_item.
  PERFORM set_fcat TABLES ct_fcat_item USING:
        'S' 'FIELDNAME' 'EBELP',
        ' ' 'COLTEXT'   '순번',
        ' ' 'JUST' 'C',
        ' ' 'KEY' 'X', ' ' 'EMPHASIZE' 'C110',
        ' ' 'LZERO'     'X',
        ' ' 'OUTPUTLEN' '4',
        'E' ''          '',
        'S' 'FIELDNAME' 'EPSTP',  ' ' 'COLTEXT' '품목범주', ' ' 'JUST' 'C', ' ' 'NO_OUT' 'X', ' ' 'REF_TABLE' 'ZTB07EKPO', ' ' 'REF_FIELD' 'EPSTP', ' ' 'OUTPUTLEN' '10', ' ' 'EDIT' 'X', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'MATNR',  ' ' 'COLTEXT' '자재',     ' ' 'OUTPUTLEN' '10', ' ' 'JUST' 'C',  ' ' 'REF_TABLE' 'ZTB07EKPO', ' ' 'REF_FIELD' 'MATNR', ' ' 'EDIT' 'X',  ' ' 'F4AVAILABL' 'X', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'WERKS',  ' ' 'COLTEXT' '플랜트',   ' ' 'OUTPUTLEN' '6', ' ' 'JUST' 'C', ' ' 'REF_TABLE' 'ZTB07EKPO', ' ' 'REF_FIELD' 'WERKS', ' ' 'F4AVAILABL' 'X', ' ' 'EDIT' 'X',  'E' ' ' ' ',
        'S' 'FIELDNAME' 'LGORT',  ' ' 'COLTEXT' '저장위치', ' ' 'OUTPUTLEN' '6', ' ' 'JUST' 'C', ' ' 'REF_TABLE' 'ZTB07EKPO', ' ' 'REF_FIELD' 'LGORT', ' ' 'F4AVAILABL' 'X', ' ' 'EDIT' 'X', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'MENGE',  ' ' 'COLTEXT' '구매수량', ' ' 'OUTPUTLEN' '20', ' ' 'EDIT' 'X', ' ' 'NO_ZERO' 'X',   'E' ' ' ' ',
        'S' 'FIELDNAME' 'MEINS',  ' ' 'COLTEXT' '단위',     ' ' 'OUTPUTLEN' '6', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'NETPR',  ' ' 'COLTEXT' '단가',     ' ' 'OUTPUTLEN' '30',  ' ' 'NO_ZERO' 'X',  'E' ' ' ' ',
        'S' 'FIELDNAME' 'DMBTR',  ' ' 'COLTEXT' '총액(원화)', ' ' 'OUTPUTLEN' '30', ' ' 'NO_ZERO' 'X',  'E' ' ' ' ',
        'S' 'FIELDNAME' 'WAERSK', ' ' 'COLTEXT' '통화',     ' ' 'OUTPUTLEN' '6',  ' ' 'JUST' 'C', ' ' 'REF_TABLE' 'ZTB07EKPO', ' ' 'REF_FIELD' 'WAERSK', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'WRBTR',  ' ' 'NO_OUT' 'X',             'E' '' '',
        'S' 'FIELDNAME' 'WAERS',  ' ' 'NO_OUT' 'X',             'E' '' '',
        'S' 'FIELDNAME' 'MWSKZ',  ' ' 'COLTEXT' '세금코드', ' ' 'OUTPUTLEN' '6', ' ' 'JUST' 'C', ' ' 'REF_TABLE' 'ZTB07EKPO', ' ' 'REF_FIELD' 'MWSKZ', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'EINDT',  ' ' 'COLTEXT' '납품요청일', ' ' 'OUTPUTLEN' '12', ' ' 'JUST' 'C',' ' 'REF_TABLE' 'ZTB07EKPO', ' ' 'REF_FIELD' 'EINDT', ' ' 'EDIT' 'X', ' ' 'F4AVAILABL' 'X',  'E' ' ' ' ',
        'S' 'FIELDNAME' 'SLFDT',  ' ' 'COLTEXT' '최종납품일', ' ' 'OUTPUTLEN' '12', ' ' 'JUST' 'C', ' ' 'REF_TABLE' 'ZTB07EKPO', ' ' 'REF_FIELD' 'SLFDT', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'INSMK',  ' ' 'NO_OUT' 'X',  'E' '' '',
        'S' 'FIELDNAME' 'PACKNO', ' ' 'NO_OUT' 'X',  'E' '' '',
        'S' 'FIELDNAME' 'KNTTP',  ' ' 'NO_OUT' 'X',  'E' '' '',
        'S' 'FIELDNAME' 'SAKTO',  ' ' 'NO_OUT' 'X',  'E' '' '',
        'S' 'FIELDNAME' 'ELIKZ',  ' ' 'NO_OUT' 'X',  'E' '' '',   " 신규 — GR완료, 추후 노출 검토
        'S' 'FIELDNAME' 'EREKZ',  ' ' 'NO_OUT' 'X',  'E' '' '',   " 신규 — IV완료, 추후 노출 검토
        'S' 'FIELDNAME' 'POSTAT', ' ' 'NO_OUT' 'X',  'E' '' ''.
  FIELD-SYMBOLS: <fs_item> TYPE lvc_s_fcat.
  LOOP AT ct_fcat_item ASSIGNING <fs_item>.
    IF gv_mode = 'D'.
      <fs_item>-edit = ' '.
    ENDIF.
    IF gv_mode = 'U' OR gv_mode = 'D'.
      IF <fs_item>-fieldname = 'NETPR' OR <fs_item>-fieldname = 'DMBTR'.
        CLEAR <fs_item>-decimals_o.
        <fs_item>-ref_table  = 'ZTB07EKPO'.
        <fs_item>-ref_field  = <fs_item>-fieldname.
        <fs_item>-cfieldname = 'WAERSK'.
      ENDIF.
    ELSE.
      IF <fs_item>-fieldname = 'NETPR' OR <fs_item>-fieldname = 'DMBTR'.
        <fs_item>-decimals_o = '0'.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat (필드카탈로그 한 컬럼씩 채우는 공통 유틸)
*&---------------------------------------------------------------------*
FORM set_fcat TABLES tt_fcat TYPE lvc_t_fcat
              USING  pv_stat
                     pv_fnam
                     pv_fval.
  FIELD-SYMBOLS: <fld> TYPE any.
  STATICS: ls_fcat TYPE lvc_s_fcat.
  IF pv_stat = 'S'.
    CLEAR ls_fcat.
  ENDIF.
  ASSIGN COMPONENT pv_fnam OF STRUCTURE ls_fcat TO <fld>.
  IF sy-subrc = 0 AND <fld> IS ASSIGNED.
    <fld> = pv_fval.
  ENDIF.
  IF pv_stat = 'E'.
    APPEND ls_fcat TO tt_fcat.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv (ALV 최초 표시)
*&---------------------------------------------------------------------*
FORM display_alv USING    ps_layout  TYPE lvc_s_layo
                          pt_uifunc  TYPE ui_functions
                          pt_fcat    TYPE lvc_t_fcat
                 CHANGING po_alv     TYPE REF TO cl_gui_alv_grid
                          pt_outtab  TYPE ANY TABLE.
  CALL METHOD po_alv->set_table_for_first_display
    EXPORTING
      is_layout                     = ps_layout
      it_toolbar_excluding          = pt_uifunc
    CHANGING
      it_outtab                     = pt_outtab
      it_fieldcatalog               = pt_fcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form control_header_screen (아이템 존재 시 헤더 필드 잠금)
*&---------------------------------------------------------------------*
FORM control_header_screen.
  DATA(lv_editable) = abap_true.
  LOOP AT gt_item TRANSPORTING NO FIELDS WHERE matnr IS NOT INITIAL.
    lv_editable = abap_false.
    EXIT.
  ENDLOOP.
  LOOP AT SCREEN.
    IF screen-name = 'GS_HEAD-BEDAT' OR
       screen-name = 'GS_HEAD-BSART' OR
       screen-name = 'GS_HEAD-EKORG' OR
       screen-name = 'GS_HEAD-EKGRP' OR
       screen-name = 'GS_HEAD-ZTERM' OR
       screen-name = 'GS_HEAD-INCO1'.
      screen-input = COND #( WHEN lv_editable = abap_true THEN 1 ELSE 0 ).
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_user_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_init_user_data .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_vend (101번 벤더 리스트 필드카탈로그)
*&---------------------------------------------------------------------*
FORM set_fcat_vend CHANGING ct_fcat_vend TYPE lvc_t_fcat.
  PERFORM set_fcat TABLES ct_fcat_vend USING:
        'S' 'FIELDNAME' 'LIFNR', ' ' 'COLTEXT' '공급업체',   ' ' 'EMPHASIZE' 'C110', ' ' 'HOTSPOT' 'X', ' ' 'REF_TABLE' 'ZTB07LFA1', ' ' 'REF_FIELD' 'LIFNR', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'NAME1', ' ' 'COLTEXT' '공급업체명', ' ' 'HOTSPOT' 'X', ' ' 'REF_TABLE' 'ZTB07LFA1', ' ' 'REF_FIELD' 'NAME1', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'EKORG', ' ' 'COLTEXT' '구매조직',   ' ' 'REF_TABLE' 'ZTB07LFA1', ' ' 'REF_FIELD' 'EKORG', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'EKGRP', ' ' 'COLTEXT' '구매그룹',   ' ' 'REF_TABLE' 'ZTB07LFA1', ' ' 'REF_FIELD' 'EKGRP', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'FDGRV', ' ' 'COLTEXT' '공급업체분류', ' ' 'REF_TABLE' 'ZTB07LFA1', ' ' 'REF_FIELD' 'FDGRV', 'E' ' ' ' '.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_vendor_all_data (101번 벤더 전체 조회)
*&---------------------------------------------------------------------*
FORM get_vendor_all_data.
  REFRESH gt_vend.
  " 1단계: ZTB07LFA1 단건 조회 (1기와 달리 조인 없이 단일 테이블)
  SELECT lif_uuid, lifnr, name1, ekorg, ekgrp, waers,
         minbw, fdgrv, akont, loevm
    FROM ztb07lfa1
   WHERE loevm <> 'X'
    INTO CORRESPONDING FIELDS OF TABLE @gt_vend.
  IF sy-subrc <> 0.
    gv_dynnr = '0101'.   " 데이터 없어도 리스트 화면 유지(빈 리스트로 표시)
  ELSE.
    " 2단계: AKONT 기준으로 ZTB07SKA1을 조회해서 GLACT를 채워넣음 (SELECT+LOOP+READ)
    DATA: lt_ska1 TYPE TABLE OF ztb07ska1.
    SELECT saknr, glact FROM ztb07ska1
      INTO CORRESPONDING FIELDS OF TABLE @lt_ska1.
    LOOP AT gt_vend ASSIGNING FIELD-SYMBOL(<fs_vend>).
      READ TABLE lt_ska1 INTO DATA(ls_ska1) WITH KEY saknr = <fs_vend>-akont.
      IF sy-subrc = 0.
        <fs_vend>-glact = ls_ska1-glact.
      ENDIF.
    ENDLOOP.
    gv_dynnr = '0101'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_vendor_data (102번 서브스크린 전환 / 130번 팝업 공용)
*&---------------------------------------------------------------------*
FORM get_vendor_data USING pv_pop pv_lifnr.
  CLEAR gs_vend.
  SELECT SINGLE lif_uuid, lifnr, name1, ekorg, ekgrp, waers,
                minbw, fdgrv, akont, loevm
    FROM ztb07lfa1
   WHERE lifnr = @pv_lifnr
     AND loevm <> 'X'
    INTO CORRESPONDING FIELDS OF @gs_vend.
  IF sy-subrc <> 0.
    IF pv_pop = 'X'.
      MESSAGE s101(zmsge_b07) DISPLAY LIKE 'W' WITH pv_lifnr.  " &1 공급업체를 찾을 수 없습니다
      EXIT.
    ELSE.
      PERFORM get_vendor_all_data.
      gv_dynnr = '0101'.
    ENDIF.
  ELSE.
    " GLACT(계정타입) — AKONT로 ZTB07SKA1 조회해서 채움
    SELECT SINGLE glact FROM ztb07ska1
      INTO @gs_vend-glact
     WHERE saknr = @gs_vend-akont.
    " 텍스트(설명) 필드 채우기 — 도메인 Fixed Value 텍스트 조회 유틸 재사용
    PERFORM get_domain_text USING 'ZDB07FDGRV' gs_vend-fdgrv CHANGING gv_fdgrv.
    PERFORM get_domain_text USING 'ZDB07GLACT' gs_vend-glact CHANGING gv_glact.  " ★GLACT 도메인명 확인 필요(표준 GLACCOUNT_TYPE 도메인일 수도)
    " AKONT(조정계정) 이름 — ZTB07SKA1_T에서 SAK_UUID+SY-LANGU로 TXT20 조회
    DATA(lv_sak_uuid) = VALUE ztb07ska1-sak_uuid( ).
    SELECT SINGLE sak_uuid FROM ztb07ska1
      INTO @lv_sak_uuid
     WHERE saknr = @gs_vend-akont.
    IF sy-subrc = 0.
      SELECT SINGLE txt20 FROM ztb07ska1_t
        INTO @gv_akont
       WHERE sak_uuid = @lv_sak_uuid
         AND spras    = @sy-langu.
    ENDIF.
    IF pv_pop = 'X'.
      " 130번 팝업 전용 — 별도 추가처리 없음(gs_vend에 다 채워짐)
    ELSE.
      gv_dynnr = '0102'.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_domain_text (도메인 Fixed Value → 설명 텍스트 조회)
*&---------------------------------------------------------------------*
FORM get_domain_text USING    p_gv_domname TYPE any   " ZDB07### 도메인명
                              p_gv_value   TYPE any   " Fixed Value 코드값
                     CHANGING c_gv_text    TYPE any.  " 조회된 설명 텍스트
  DATA: lt_domain_value TYPE TABLE OF dd07v,
        ls_domain_value LIKE LINE OF lt_domain_value.
  CLEAR c_gv_text.
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = p_gv_domname
    TABLES
      values_tab      = lt_domain_value
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.
  IF sy-subrc = 0.
    READ TABLE lt_domain_value INTO ls_domain_value
      WITH KEY domvalue_l = p_gv_value.
    IF sy-subrc = 0.
      c_gv_text = ls_domain_value-ddtext.
    ENDIF.
  ENDIF.
ENDFORM.
