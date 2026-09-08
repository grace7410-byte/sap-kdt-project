*&---------------------------------------------------------------------*
*& 변경이력
*& 2026-09-04  최초 작성. 100번 아이템 ALV 공통 유틸, 101번 벤더 리스트 조회, 102/130 공용 벤더 상세 조회(get_vendor_data/get_domain_text) 구현(104 BOM 차트는 미착수) —
*&             devlog: ../../../devlog/rap-dev/2026-09-04.md
*& 2026-09-05  display_alv PT_FCAT USING→CHANGING 이동(컴파일러 지적 해결), set_init_user_data 구현(bukrs/ekorg/ekgrp K200/1000/001 하드코딩 + CDS 서치헬프 뷰 3종 정적 SELECT로 텍스트 조회) —
*&             devlog: ../../../devlog/rap-dev/2026-09-05.md
*& 2026-09-06  set_layout pv_type 1/3/4 그리드 타이틀 주석 처리(디자인, 2/5는 유지), GLACT 도메인명 'ZDB07GLACT'→'GLACCOUNT_TYPE' 수정 —
*&             devlog: ../../../devlog/rap-dev/2026-09-06.md
*& 2026-09-07  get_header_data/refresh_ekorg_ekgrp_text/clear_header_data(102·130 헤더 텍스트 동기화) 신규,
*&             get_opti_data/set_fcat_opti/get_chart_data/display_chart/create_chart_object(103 옵션가·BOM차트) 신규 — devlog: ../../../devlog/rap-dev/2026-09-07.md
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
*    ps_layout-grid_title = '구매오더 아이템'.
    IF gv_mode <> 'D'.
      ps_layout-sel_mode = 'B'.
    ENDIF.
  ELSEIF pv_type = 2.                    " 103번 옵션가(EINA/EINE 단가)
    ps_layout-grid_title = '구매정보레코드 기준 단가'.
  ELSEIF pv_type = 3.                    " (200/300 결정 대기) PO 목록
*    ps_layout-grid_title = '구매오더 목록'.
    ps_layout-sel_mode   = 'B'.
    ps_layout-cwidth_opt = 'X'.
  ELSEIF pv_type = 4.                    " 101번 벤더 리스트
*    ps_layout-grid_title = '공급업체 목록'.
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
                 CHANGING po_alv     TYPE REF TO cl_gui_alv_grid
                          pt_outtab  TYPE ANY TABLE
                          pt_fcat    TYPE lvc_t_fcat.
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
*& Form set_init_user_data (하드코딩 기본값 + CDS 서치헬프 뷰로 텍스트 조회)
*&---------------------------------------------------------------------*
FORM set_init_user_data.
  gs_head-bukrs = 'K200'.
  gs_head-ekorg = '1000'.
  gs_head-ekgrp = '001'.

  SELECT SINGLE companycodename
    FROM zi_b07_bukrs_f4
    WHERE companycode = @gs_head-bukrs
    INTO @gv_bukrs.

  SELECT SINGLE ekotx
    FROM zi_b07_ekorg_f4
    WHERE ekorg = @gs_head-ekorg
    INTO @gv_ekorg.

  SELECT SINGLE eknam
    FROM zi_b07_ekgrp_f4
    WHERE ekgrp = @gs_head-ekgrp
    INTO @gv_ekgrp.
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
    PERFORM get_domain_text USING 'GLACCOUNT_TYPE' gs_vend-glact CHANGING gv_glact.
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

    " 구매조직/구매그룹 텍스트 — GV_EKORG/GV_EKGRP는 100번 헤더와 공용 변수라서,
    " 130 팝업/102 서브스크린을 표시할 때마다 지금 조회된 벤더 기준으로 다시 채움
    PERFORM refresh_ekorg_ekgrp_text USING gs_vend-ekorg gs_vend-ekgrp.

    IF pv_pop = 'X'.
      " 130번 팝업 전용 — 위에서 이미 EKORG/EKGRP 텍스트까지 채웠으니 추가처리 없음
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
*&---------------------------------------------------------------------*
*& Form get_header_data (130에서 벤더 선택 후 100번 헤더 구매조직/구매그룹 반영)
*&---------------------------------------------------------------------*
FORM get_header_data.
  " 130 팝업에서 SEL_VEND로 선택된 벤더(gs_vend)의 구매조직/구매그룹을
  " 헤더(gs_head)로 반영. 회사코드(BUKRS)는 ZTB07LFA1에 없는 필드라 그대로 유지.
  gs_head-ekorg = gs_vend-ekorg.
  gs_head-ekgrp = gs_vend-ekgrp.

  PERFORM refresh_ekorg_ekgrp_text USING gs_vend-ekorg gs_vend-ekgrp.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form refresh_ekorg_ekgrp_text (GV_EKORG/GV_EKGRP 공용 텍스트 갱신)
*&---------------------------------------------------------------------*
FORM refresh_ekorg_ekgrp_text USING pv_ekorg pv_ekgrp.
  " 매칭 실패 시 이전 값이 남지 않도록 반드시 CLEAR 후 조회
  CLEAR: gv_ekorg, gv_ekgrp.

  SELECT SINGLE ekotx FROM zi_b07_ekorg_f4
    WHERE ekorg = @pv_ekorg
    INTO @gv_ekorg.

  SELECT SINGLE eknam FROM zi_b07_ekgrp_f4
    WHERE ekgrp = @pv_ekgrp
    INTO @gv_ekgrp.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form clear_header_data (헤더 표시용 텍스트/부가정보 초기화 — 1기 이식, gs_vend/gt_opti는 미포함)
*&---------------------------------------------------------------------*
FORM clear_header_data.
  CLEAR: gv_name1, gv_ekorg, gv_ekgrp, gv_bukrs, gv_postat, gv_zterm, gv_inco1.
  CLEAR: gs_head-ekorg, gs_head-ekgrp, gs_head-bukrs, gs_head-zterm, gs_head-inco1,
         gs_head-zebeln, gs_head-knumh, gs_head-loekz,
         gs_head-created_by, gs_head-creation_at, gs_head-changed_by, gs_head-changed_at.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_opti_data (103번 옵션가 ALV — 벤더 필터 옵셔널, 전체조회 시 공급업체 구분 표시)
*&---------------------------------------------------------------------*
FORM get_opti_data.
  REFRESH gt_opti.

  SELECT a~inf_uuid, a~infnr, a~mat_uuid, a~lif_uuid, c~lifnr, c~name1,
         b~werks, b~netpr, b~peinh, b~waers, b~bprme
    FROM ztb07eina AS a
    INNER JOIN ztb07eine AS b ON a~inf_uuid = b~inf_uuid
    INNER JOIN ztb07lfa1 AS c ON a~lif_uuid = c~lif_uuid
   WHERE ( @gs_vend-lif_uuid IS INITIAL OR a~lif_uuid = @gs_vend-lif_uuid )
     AND a~loekz <> 'X'
     AND b~loekz <> 'X'
     AND c~loevm <> 'X'
    ORDER BY c~lifnr, a~infnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_opti
    UP TO 100 ROWS.

  IF sy-subrc = 0.
    LOOP AT gt_opti ASSIGNING FIELD-SYMBOL(<fs_opti>).
      SELECT SINGLE matnr FROM ztb07mara
        INTO @<fs_opti>-matnr
       WHERE mat_uuid = @<fs_opti>-mat_uuid.

      SELECT SINGLE maktx FROM ztb07mara_t
        INTO @<fs_opti>-maktx
       WHERE mat_uuid = @<fs_opti>-mat_uuid
         AND spras    = @sy-langu.
    ENDLOOP.
  ENDIF.

  IF go_alv_pop IS BOUND.
    go_alv_pop->refresh_table_display( ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_opti (103번 옵션가 ALV 필드카탈로그)
*&---------------------------------------------------------------------*
FORM set_fcat_opti CHANGING ct_fcat_opti TYPE lvc_t_fcat.
  PERFORM set_fcat TABLES ct_fcat_opti USING:
        'S' 'FIELDNAME' 'SELECT',  ' ' 'COLTEXT' '선택',        ' ' 'ICON' 'X', ' ' 'JUST' 'C', ' ' 'OUTPUTLEN' '4', ' ' 'EMPHASIZE' 'C110', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'LIFNR',   ' ' 'COLTEXT' '공급업체',     ' ' 'OUTPUTLEN' '10', ' ' 'REF_TABLE' 'ZTB07LFA1', ' ' 'REF_FIELD' 'LIFNR', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'NAME1',   ' ' 'COLTEXT' '공급업체명',   ' ' 'OUTPUTLEN' '16', ' ' 'REF_TABLE' 'ZTB07LFA1', ' ' 'REF_FIELD' 'NAME1', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'INFNR',   ' ' 'COLTEXT' '구매정보번호', ' ' 'OUTPUTLEN' '10', ' ' 'JUST' 'C', ' ' 'EMPHASIZE' 'C110', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'MATNR',   ' ' 'COLTEXT' '자재',         ' ' 'OUTPUTLEN' '10', ' ' 'JUST' 'C', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'MAKTX',   ' ' 'COLTEXT' '자재명',       ' ' 'OUTPUTLEN' '20', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'WERKS',   ' ' 'COLTEXT' '플랜트',       ' ' 'OUTPUTLEN' '6',  ' ' 'JUST' 'C', ' ' 'REF_TABLE' 'ZTB07EINE', ' ' 'REF_FIELD' 'WERKS', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'NETPR',   ' ' 'COLTEXT' '단가',         ' ' 'OUTPUTLEN' '15', ' ' 'NO_ZERO' 'X', ' ' 'REF_TABLE' 'ZTB07EINE', ' ' 'REF_FIELD' 'NETPR', ' ' 'CFIELDNAME' 'WAERS', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'PEINH',   ' ' 'COLTEXT' '가격단위',     ' ' 'OUTPUTLEN' '6',  ' ' 'NO_ZERO' 'X', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'WAERS',   ' ' 'COLTEXT' '통화',         ' ' 'OUTPUTLEN' '6',  ' ' 'JUST' 'C', ' ' 'REF_TABLE' 'ZTB07EINE', ' ' 'REF_FIELD' 'WAERS', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'BPRME',   ' ' 'COLTEXT' '주문단위',     ' ' 'OUTPUTLEN' '6',  ' ' 'JUST' 'C', ' ' 'REF_TABLE' 'ZTB07EINE', ' ' 'REF_FIELD' 'BPRME', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'INF_UUID', ' ' 'NO_OUT' 'X', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'MAT_UUID', ' ' 'NO_OUT' 'X', 'E' ' ' ' ',
        'S' 'FIELDNAME' 'LIF_UUID', ' ' 'NO_OUT' 'X', 'E' ' ' ' '.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_chart_data (103번 자체 BOM 차트 — 기준 완제품 1개 부품 소요량)
*&---------------------------------------------------------------------*
FORM get_chart_data.
  REFRESH gt_bom.
  CLEAR gv_chart_show.

  " STLNR 자체가 완제품 MATNR(예: 'SM-FOLD')이라 1기처럼 서브쿼리로 그룹 찾을 필요 없음
  SELECT b~matnr, c~maktx, a~fmeng, a~meins
    FROM ztb07bom AS a
    INNER JOIN ztb07mara AS b ON a~comp_uuid = b~mat_uuid
    LEFT OUTER JOIN ztb07mara_t AS c ON a~comp_uuid = c~mat_uuid AND c~spras = @sy-langu
   WHERE a~stlnr = @gv_base_prod
     AND a~fmeng > 0
     AND a~loekz <> 'X'
     ORDER BY a~stlkn
    INTO CORRESPONDING FIELDS OF TABLE @gt_bom.

  IF sy-subrc = 0 AND gt_bom IS NOT INITIAL.
    gv_chart_show = 'X'.
    LOOP AT gt_bom ASSIGNING FIELD-SYMBOL(<fs_bom>).
      <fs_bom>-display_text = |{ <fs_bom>-maktx } ({ <fs_bom>-matnr })|.
    ENDLOOP.
  ELSE.
    CLEAR gv_chart_show.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_chart (103번 자체 BOM 차트 렌더링)
*&---------------------------------------------------------------------*
FORM display_chart.
  DATA: lo_ixml         TYPE REF TO if_ixml,
        lo_ixml_doc     TYPE REF TO if_ixml_document,
        lo_ixml_sf      TYPE REF TO if_ixml_stream_factory,
        lo_ixml_ostream TYPE REF TO if_ixml_ostream,
        lo_encoding     TYPE REF TO if_ixml_encoding,
        lo_chartdata    TYPE REF TO if_ixml_element,
        lo_categories   TYPE REF TO if_ixml_element,
        lo_category     TYPE REF TO if_ixml_element,
        lo_series       TYPE REF TO if_ixml_element,
        lo_point        TYPE REF TO if_ixml_element,
        lo_value        TYPE REF TO if_ixml_element,
        lo_title        TYPE REF TO if_ixml_element,
        lo_title_txt    TYPE REF TO if_ixml_element,
        lv_xstring      TYPE xstring,
        lv_val_str      TYPE string.

  lo_ixml     = cl_ixml=>create( ).
  lo_ixml_doc = lo_ixml->create_document( ).
  lo_encoding = lo_ixml->create_encoding( character_set = 'utf-8' byte_order = 0 ).
  lo_ixml_doc->set_encoding( lo_encoding ).

  lo_chartdata = lo_ixml_doc->create_simple_element( name = 'ChartData' parent = lo_ixml_doc ).

  lo_title     = lo_ixml_doc->create_simple_element( name = 'Title' parent = lo_chartdata ).
  lo_title_txt = lo_ixml_doc->create_simple_element( name = 'Text' parent = lo_title ).
  lo_title_txt->if_ixml_node~set_value( |{ gv_base_prod } 부품 소요량| ).

  lo_categories = lo_ixml_doc->create_simple_element( name = 'Categories' parent = lo_chartdata ).
  LOOP AT gt_bom INTO gs_bom.
    lo_category = lo_ixml_doc->create_simple_element( name = 'Category' parent = lo_categories ).
    lo_category->if_ixml_node~set_value( |{ gs_bom-display_text }| ).
  ENDLOOP.

  lo_series = lo_ixml_doc->create_simple_element( name = 'Series' parent = lo_chartdata ).
  lo_series->set_attribute( name = 'label' value = '소요 수량' ).

  LOOP AT gt_bom INTO gs_bom.
    lo_point = lo_ixml_doc->create_simple_element( name = 'Point' parent = lo_series ).
    lo_value = lo_ixml_doc->create_simple_element( name = 'Value' parent = lo_point ).
    lv_val_str = |{ gs_bom-fmeng }|.
    lo_value->if_ixml_node~set_value( lv_val_str ).
  ENDLOOP.

  lo_ixml_sf      = lo_ixml->create_stream_factory( ).
  lo_ixml_ostream = lo_ixml_sf->create_ostream_xstring( lv_xstring ).
  lo_ixml_doc->render( lo_ixml_ostream ).

  IF go_chart IS BOUND.
    go_chart->set_data( xdata = lv_xstring ).
    go_chart->render( ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_chart_object (커스텀 컨테이너 + 차트 엔진 오브젝트 생성 - 공용)
*&---------------------------------------------------------------------*
FORM create_chart_object USING pv_area TYPE c
                      CHANGING po_cont  TYPE REF TO cl_gui_custom_container
                               po_chart TYPE REF TO cl_gui_chart_engine.
  CREATE OBJECT po_cont
    EXPORTING container_name = pv_area.
  CREATE OBJECT po_chart
    EXPORTING parent = po_cont.
ENDFORM.
