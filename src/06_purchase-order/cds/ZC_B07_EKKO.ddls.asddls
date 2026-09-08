// ============================================================
// 변경이력
// 2026-09-07  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-07.md
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
define root view entity ZC_B07_EKKO
  provider contract transactional_query
  as projection on ZR_B07_EKKO

{
  key EbelnUuid,

      // 검색조건(1) 구매오더일
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
      Bedat,

      // 검색조건(2) 공급업체
      @UI.hidden: true
      LifUuid,
      @Search.defaultSearchElement: true
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
      Ebeln,

      // 텍스트 및 서치헬프
      @ObjectModel.text.element: ['BukrsText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_BUKRS_F4', element: 'CompanyCode' } }]
      Bukrs,
      BukrsText,

      // 텍스트 및 서치헬프
      @ObjectModel.text.element: ['Ekotx']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_EKORG_F4', element: 'Ekorg' } }]
      Ekorg,
      Ekotx,

      // 텍스트 (서치헬프는 Root)
      @ObjectModel.text.element: ['Eknam']
      @UI.textArrangement: #TEXT_FIRST
      Ekgrp,
      Eknam,

      // Root가 이미 공개한 _BsartText를 그대로 navigate하면 여기서도 텍스트 필드 정의 가능
      // 텍스트
      @ObjectModel.text.element: ['BsartText']
      @UI.textArrangement: #TEXT_FIRST
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
