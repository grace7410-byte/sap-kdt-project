// ============================================================
// 변경이력
// 2026-09-07  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-07.md
// 2026-09-08  @Metadata.allowExtensions 추가(MDE에서 Facet/필드 추가하려면 필요), 구매오더일에
//             단일 날짜 선택(@Consumption.filter selectionType SINGLE), 공급업체 selectionField
//             position 추가, 구매오더번호 Value Help(ZI_B07_EBELN_F4) 추가, 구매조직 텍스트
//             동시 표기는 20자 제한 오류로 주석 처리(서치헬프 내 텍스트만 유지), 구매그룹/문서유형
//             Value Help 누락분 추가(ZI_B07_EKGRP_F4/ZI_B07_BSART_F4), Loekz 체크박스 렌더링을
//             위한 @UI.defaultValue 추가 — devlog: ../../../devlog/rap-dev/2026-09-08.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 헤더 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'Ebeln' ]
@UI.presentationVariant: [{ sortOrder: [
    { by: 'Bedat', direction: #DESC },
    { by: 'Lifnr', direction: #ASC },
    { by: 'Ebeln', direction: #ASC }
 ]}]
@Metadata.allowExtensions: true
define root view entity ZC_B07_EKKO
  provider contract transactional_query
  as projection on ZR_B07_EKKO

{
  key EbelnUuid,

      // 검색조건(1) 구매오더일
      @Consumption.filter: { selectionType: #SINGLE }
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
      Bedat,

      // 검색조건(2) 공급업체
      @UI.hidden: true
      LifUuid,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 20 }]
      // 텍스트
      @ObjectModel.text.element: ['Name1']
      @UI.textArrangement: #TEXT_FIRST
      // 서치헬프
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_LIFNR_F4', element: 'Lifnr' } }]
      Lifnr,
      Name1,

      // 검색조건(3) 구매오더번호
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @UI.selectionField: [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_EBELN_F4', element: 'Ebeln' } }]
      Ebeln,

      // 텍스트 및 서치헬프
      @ObjectModel.text.element: ['BukrsText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_BUKRS_F4', element: 'CompanyCode' } }]
      Bukrs,
      BukrsText,

      // 서치헬프 (텍스트 동시 표기는 Ekorg 필드 길이 20자 제한 오류로 주석 처리 — 서치헬프 내 텍스트만 유지)
      //      @ObjectModel.text.element: ['Ekotx']
      //      @UI.textArrangement: #TEXT_ONLY
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_EKORG_F4', element: 'Ekorg' } }]
      Ekorg,
      Ekotx,

      // 텍스트 (서치헬프는 Root에서 한 번, 여기서 한 번 더 선언)
      @ObjectModel.text.element: ['Eknam']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_EKGRP_F4', element: 'Ekgrp' } }]
      Ekgrp,
      Eknam,

      // Root가 이미 공개한 _BsartText를 그대로 navigate하면 여기서도 텍스트 필드 정의 가능
      // 텍스트
      @ObjectModel.text.element: ['BsartText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_BSART_F4', element: 'Bsart' } }]
      Bsart,
      _BsartText[1: Language = $session.system_language].DomainText as BsartText,

      // 텍스트 및 서치헬프
      @ObjectModel.text.element: ['WaersText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_WAERS_F4', element: 'Currency' } }]
      Waers,
      WaersText,

      Zterm,
      Inco1,
      Knumh,
      Zebeln,
      Zebelnsv,
      Pdesc,
      // 구매오더 취소(삭제)에 대해 체크박스 적용
      @UI.defaultValue: ' '
      Loekz,

      CreatedBy,
      CreationAt,
      ChangedBy,
      ChangedAt,
      LocChangedAt,

      /* Associations */
      _BsartText,
      _EkgrpText,
      _EkorgText,
      _BukrsText,
      _WaersText,
      _Lfa1,
      _Ekpo : redirected to composition child ZC_B07_EKPO
}
