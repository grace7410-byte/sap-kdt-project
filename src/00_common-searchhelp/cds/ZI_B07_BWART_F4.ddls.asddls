// ============================================================
// 변경이력
// 2026-08-24  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-24.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '이동유형 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_B07_BWART_F4
  as select from I_DomainFixedValueText
{
      @UI.hidden: true
  key SAPDataDictionaryDomain,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 10}]
      @EndUserText.label: 'Movement Type'
      @ObjectModel.text.element: ['BwartText'] // text = 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
  key DomainValue as Bwart,
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
      @EndUserText.label: 'Movement Type Description'
      DomainText  as BwartText
}
where
      SAPDataDictionaryDomain = 'ZDB07BWART'
  and Language                = $session.system_language
  and DomainActivationState   = 'A'
