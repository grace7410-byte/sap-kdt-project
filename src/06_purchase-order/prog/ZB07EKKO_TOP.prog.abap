*&---------------------------------------------------------------------*
*& 변경이력
*& 2026-09-03  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-03.md
*& 2026-09-04  gs_vend에 glact(계정타입, ZTB07SKA1 조회로 채움) 필드 추가.
*&             gv_fdgrv/gv_akont/gv_glact(102/130번 화면 텍스트 표시용) 추가.
*&             gv_base_prod(103/104번 기준 완제품 모델코드, 기본값 'SM-FOLD') 추가 —
*&             devlog: ../../../devlog/rap-dev/2026-09-04.md
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include ZB07EKKO_TOP                             - Module Pool      SAPMZB07EKKO
*&---------------------------------------------------------------------*
PROGRAM SAPMZB07EKKO.
CONTROLS: tabstrip TYPE TABSTRIP.
DATA: ok_code         TYPE sy-ucomm,
      gv_before_dynnr TYPE sy-dynnr,          " 이전 서브스크린 번호(컨테이너 재생성 판단용)
      gv_mode         TYPE c,                 " 처리모드: ' '=생성 / 'U'=수정 / 'D'=삭제조회
      gv_ebeln        TYPE zeb07ebeln,        " 조회/수정 대상 구매오더번호(Unique키, 화면 진입시 세팅)
      gv_name1        TYPE name1,             " 공급업체명 표시용(ZTB07LFA1-NAME1)
      gv_bukrs        TYPE char20 VALUE '1000', " 회사코드 도메인 텍스트(기본 회사코드 '1000')
      gv_ekorg        TYPE char20,            " 구매조직 도메인 텍스트
      gv_ekgrp        TYPE char20,            " 구매그룹 도메인 텍스트
      gv_zterm        TYPE char20,            " 결제조건 도메인 텍스트
      gv_inco1        TYPE char20,            " 인코텀즈 도메인 텍스트
      gv_postat       TYPE zeb07postat,       " 아이템 중 최소 승인/진행상태(추후 F01에서 산출 로직 확정)
      gv_postatxt     TYPE char20,            " 진행상태 도메인 텍스트
      gv_vend_org     TYPE char20,            " 130번 팝업 - 벤더측 구매조직 텍스트
      gv_vend_grp     TYPE char20,            " 130번 팝업 - 벤더측 구매그룹 텍스트
      gv_fdgrv        TYPE char40,            " FDGRV(공급업체 분류) 텍스트(도메인 Fixed Value)
      gv_akont        TYPE char20,            " AKONT(조정계정) 텍스트
      gv_glact        TYPE char40.            " GLACT(계정타입) 텍스트
*&---------------------------------------------------------------------*
*& 옵션가(구매정보레코드 기준 단가) 조회용 (ZTB07EINA + ZTB07EINE)
*&---------------------------------------------------------------------*
" 1기는 CDS(zcds_b1_mm_0001)로 실시간 계산했으나, 이번엔 구매정보레코드
" (ZTB07EINA/EINE) JOIN 결과를 TAB1(0110) ALV에 뿌리는 구조로 재설계함
" *** 이 방향이 맞는지 확인 필요 ***
DATA: BEGIN OF gs_opti,
        inf_uuid TYPE ztb07eina-inf_uuid,
        infnr    TYPE ztb07eina-infnr,      " 구매정보번호
        mat_uuid TYPE ztb07eina-mat_uuid,
        matnr    TYPE zeb07matnr,           " 자재번호(ZTB07MARA 조인 결과, 화면표시용)
        maktx    TYPE char40,               " 자재명(ZTB07MARA_T 조인 결과, 화면표시용)
        werks    TYPE ztb07eine-werks,      " 플랜트(정보레코드 아이템 키)
        netpr    TYPE ztb07eine-netpr,      " 정보레코드 단가
        peinh    TYPE ztb07eine-peinh,      " 가격단위
        waers    TYPE ztb07eine-waers,      " 통화
        bprme    TYPE ztb07eine-bprme,      " 주문단위
        select   TYPE icon_d,               " 선택 아이콘(화면 표시용)
      END OF gs_opti,
      gt_opti LIKE TABLE OF gs_opti.
*&---------------------------------------------------------------------*
*& 구매오더 헤더 (ZTB07EKKO)
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_head,
         ebeln_uuid TYPE ztb07ekko-ebeln_uuid, " PK, 신규생성시 UUID 자동채번
         ebeln      TYPE ztb07ekko-ebeln,      " 구매오더번호(Unique, 채번 결과)
         lif_uuid   TYPE ztb07ekko-lif_uuid,   " 공급업체 UUID(내부 저장용)
         lifnr      TYPE zeb07lifnr,           " 공급업체번호 *** DB엔 없음, 화면입력/검색용 보조필드 ***
         bukrs      TYPE ztb07ekko-bukrs,      " 회사코드
         ekorg      TYPE ztb07ekko-ekorg,      " 구매조직
         ekgrp      TYPE ztb07ekko-ekgrp,      " 구매그룹
         bsart      TYPE ztb07ekko-bsart,      " 문서유형('NB' 고정, 1기 계승)
         bedat      TYPE ztb07ekko-bedat,      " PO 생성일
         waers      TYPE ztb07ekko-waers,      " 구매오더통화(생성시 'KRW' 기본값)
         zterm      TYPE ztb07ekko-zterm,      " 결제조건(벤더 자동반영 불가 - 직접입력)
         inco1      TYPE ztb07ekko-inco1,      " 인코텀즈(벤더 자동반영 불가 - 직접입력)
         knumh      TYPE ztb07ekko-knumh,      " 조건레코드 번호
         zebeln     TYPE ztb07ekko-zebeln,     " 참조 구매오더번호(SV타입용)
         zebelnsv   TYPE ztb07ekko-zebelnsv,   " 참조 구매오더번호 사본
         pdesc      TYPE ztb07ekko-pdesc,      " 구매문서 내역
         loekz      TYPE ztb07ekko-loekz,      " 삭제 플래그
         created_by TYPE syuname,
         creation_at TYPE timestampl,
         changed_by TYPE syuname,
         changed_at TYPE timestampl,
       END OF ty_head.
DATA: gs_head TYPE ty_head.
*&---------------------------------------------------------------------*
*& 구매오더 아이템 (ZTB07EKPO)
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_item,
         ebeln_uuid TYPE ztb07ekpo-ebeln_uuid, " PK(FK)
         ebelp      TYPE ztb07ekpo-ebelp,      " 아이템 순번(10,20,30...)
         mat_uuid   TYPE ztb07ekpo-mat_uuid,   " 자재 UUID(내부 저장용)
         matnr      TYPE zeb07matnr,           " 자재번호 *** DB엔 없음, 화면입력/검색용 보조필드 ***
         txz01      TYPE ztb07ekpo-txz01,      " 자재명(정보레코드/자재마스터 반영)
         mtart      TYPE ztb07ekpo-mtart,      " 자재유형
         inf_uuid   TYPE ztb07ekpo-inf_uuid,   " 구매정보레코드 UUID(내부 저장용)
         infnr      TYPE zeb07infnr,           " 구매정보번호 *** DB엔 없음, 화면입력/검색용 보조필드 ***
         werks      TYPE ztb07ekpo-werks,      " 플랜트
         lgort      TYPE ztb07ekpo-lgort,      " 저장위치
         menge      TYPE ztb07ekpo-menge,      " 구매수량
         meins      TYPE ztb07ekpo-meins,      " 구매단위
         netpr      TYPE ztb07ekpo-netpr,      " 순가격(헤더 통화 기준)
         wrbtr      TYPE ztb07ekpo-wrbtr,      " 총금액(아이템 통화 기준)
         waers      TYPE ztb07ekpo-waers,      " 아이템 통화
         dmbtr      TYPE ztb07ekpo-dmbtr,      " 총금액(원화 등 waersk 기준)
         waersk     TYPE ztb07ekpo-waersk,     " dmbtr 통화
         mwskz      TYPE ztb07ekpo-mwskz,      " 세금코드
         eindt      TYPE ztb07ekpo-eindt,      " 납품요청일
         slfdt      TYPE ztb07ekpo-slfdt,      " 최종납품일
         insmk      TYPE ztb07ekpo-insmk,      " 재고유형
         packno     TYPE ztb07ekpo-packno,     " 패키지번호
         knttp      TYPE ztb07ekpo-knttp,      " 계정지정범주
         sakto      TYPE ztb07ekpo-sakto,      " 계정번호
         epstp      TYPE ztb07ekpo-epstp,      " 품목범주
         postat     TYPE ztb07ekpo-postat,     " 진행상태
         loekz      TYPE ztb07ekpo-loekz,      " 아이템 삭제
         elikz      TYPE ztb07ekpo-elikz,      " GR 완료 플래그
         erekz      TYPE ztb07ekpo-erekz,      " IV 완료 플래그
         created_by TYPE syuname,
         creation_at TYPE timestampl,
         changed_by TYPE syuname,
         changed_at TYPE timestampl,
       END OF ty_item.
DATA: gs_item TYPE ty_item,
      gt_item TYPE TABLE OF ty_item.          " 아이템 ALV용
*&---------------------------------------------------------------------*
*& 공급업체 마스터 (ZTB07LFA1)
*&---------------------------------------------------------------------*
DATA: BEGIN OF gs_vend,
        lif_uuid TYPE ztb07lfa1-lif_uuid,
        lifnr    TYPE ztb07lfa1-lifnr,        " 공급업체번호
        name1    TYPE ztb07lfa1-name1,        " 공급업체명
        ekorg    TYPE ztb07lfa1-ekorg,        " 구매조직
        ekgrp    TYPE ztb07lfa1-ekgrp,        " 구매그룹
        waers    TYPE ztb07lfa1-waers,        " 거래통화
        minbw    TYPE ztb07lfa1-minbw,        " 최소주문금액
        fdgrv    TYPE ztb07lfa1-fdgrv,        " 현금관리그룹
        akont    TYPE ztb07lfa1-akont,        " 조정계정
        glact    TYPE ztb07ska1-glact,        " LFA1엔 없는 필드. AKONT로 ZTB07SKA1 조회해서 채움
        loevm    TYPE ztb07lfa1-loevm,        " 삭제 플래그
      END OF gs_vend,
      gt_vend LIKE TABLE OF gs_vend.
*&---------------------------------------------------------------------*
*& BOM(조성비) 조회 (ZTB07BOM, 2026-09-04 DDL 확정)
*&---------------------------------------------------------------------*
DATA: BEGIN OF gs_bom,
        matnr        TYPE zeb07matnr,
        maktx        TYPE char40,
        display_text TYPE char40,
      END OF gs_bom,
      gt_bom        LIKE TABLE OF gs_bom,
      gv_month      TYPE n LENGTH 2,
      gv_season     TYPE char4,
      gv_chart_show TYPE c.
DATA: BEGIN OF gs_bom_all,
        matnr        TYPE zeb07matnr,
        maktx        TYPE char40,
        display_text TYPE char40,
      END OF gs_bom_all,
      gt_bom_all        LIKE TABLE OF gs_bom_all,
      gv_chart_show_all TYPE c.
DATA: gv_base_prod TYPE zeb07matnr VALUE 'SM-FOLD'.   " 옛 gv_crude 대응(103/104번 기준 완제품), 기본값 SM-FOLD
*&---------------------------------------------------------------------*
*& 100번 아이템 ALV 관련 (커스텀 컨테이너)
*&---------------------------------------------------------------------*
DATA: go_cont TYPE REF TO cl_gui_custom_container,
      go_alv  TYPE REF TO cl_gui_alv_grid.
DATA: gs_variant TYPE disvariant,
      gs_stable  TYPE lvc_s_stbl,
      gs_layout  TYPE lvc_s_layo,
      gt_uifunc  TYPE ui_functions.
DATA: gt_fcat_item TYPE lvc_t_fcat.
DATA: gv_col_pos      TYPE int4,
      gv_visible      TYPE char1,             " 아이템 오버뷰(하단 ALV) 노출 여부
      gv_before_lifnr LIKE gs_head-lifnr.     " Enter시 벤더 재조회 판단용(AS-IS gv_before_bpid 대응)
*&---------------------------------------------------------------------*
*& 101번 벤더 리스트 ALV 관련
*&---------------------------------------------------------------------*
DATA: go_cont_vend   TYPE REF TO cl_gui_custom_container,
      go_alv_vend    TYPE REF TO cl_gui_alv_grid,
      gs_layo_vend   TYPE lvc_s_layo,
      gt_uifunc_vend TYPE ui_functions,
      gt_fcat_vend   TYPE lvc_t_fcat.
*&---------------------------------------------------------------------*
*& 110번 옵션가 ALV, 차트 관련 (구매정보레코드 기준 단가 & BOM 차트)
*&---------------------------------------------------------------------*
DATA: go_dialog  TYPE REF TO cl_gui_custom_container,
      go_alv_pop TYPE REF TO cl_gui_alv_grid.
DATA: gs_layo_pop   TYPE lvc_s_layo,
      gt_uifunc_pop TYPE ui_functions,
      gt_fcat_opti  TYPE lvc_t_fcat.
DATA: go_cont_chart TYPE REF TO cl_gui_custom_container,
      go_chart      TYPE REF TO cl_gui_chart_engine.
*&---------------------------------------------------------------------*
*& 130번 전사 BOM 차트, ALV 관련
*&---------------------------------------------------------------------*
DATA: go_cont_chartall TYPE REF TO cl_gui_custom_container,
      go_chartall      TYPE REF TO cl_gui_chart_engine.
DATA: go_splitter   TYPE REF TO cl_gui_splitter_container,
      go_cont_l     TYPE REF TO cl_gui_container,
      go_cont_r     TYPE REF TO cl_gui_container,
      go_alv_all    TYPE REF TO cl_gui_alv_grid,
      gs_layo_all   TYPE lvc_s_layo,
      gt_uifunc_all TYPE ui_functions,
      gt_fcat_all   TYPE lvc_t_fcat.
*&---------------------------------------------------------------------*
*& 300번 구매오더 헤더 목록 ALV 관련
*&---------------------------------------------------------------------*
DATA: go_cont_pohd   TYPE REF TO cl_gui_custom_container,
      go_alv_pohd    TYPE REF TO cl_gui_alv_grid,
      gt_fcat_pohd   TYPE lvc_t_fcat,
      gs_layout_pohd TYPE lvc_s_layo,
      gt_pohd        TYPE TABLE OF ztb07ekko.     " 헤더 목록 조회용
*&---------------------------------------------------------------------*
*& 기타 공통 변수
*&---------------------------------------------------------------------*
DATA: gv_msg_matnr TYPE zeb07matnr,
      gv_show_msg  TYPE abap_bool,
      gv_answer    TYPE char1.
DATA: gv_dynnr      TYPE sy-dynnr VALUE '0101',   " SUBSCREEN 진입 화면
      gv_dynnr_tab  TYPE sy-dynnr VALUE '0110',   " TABSTRIP SUBSCREEN
      gv_save_check TYPE c LENGTH 1,              " PO 최초 저장 여부(신규→목록전환 판단)
      gv_po_ebeln   TYPE zeb07ebeln,               " 저장 직후 구매오더번호(메시지/메모리용)
      gv_check      TYPE char1,                    " 120번 팝업 '오늘 하루 보지않기' 체크
      gv_firsttime  TYPE char1,
      go_timer      TYPE REF TO cl_gui_timer,
      gv_manual     TYPE c.                        " INFO버튼 수동 팝업 여부
