// ============================================================
// 변경이력
// 2026-08-24  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-24.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '전기키 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZI_B07_BSCHL_F4 
  as select from I_DomainFixedValueText {
  
      @UI.hidden: true
  key SAPDataDictionaryDomain,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 10}]
      @EndUserText.label: 'Posting Key'
      @ObjectModel.text.element: ['BschlText'] // text = 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
  key DomainValue as Bschl,
      @UI.hidden: true
  key Language,
      @UI.hidden: true
  key DomainActivationState,
      @UI.hidden: true
  key DomainValuePosition,
      @UI.hidden: true
  key DomainVersion,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 20}]
      @EndUserText.label: 'Posting Key Description'
      DomainText as BschlText
}
where
      SAPDataDictionaryDomain = 'ZDB07BSCHL'
  and Language                = $session.system_language
