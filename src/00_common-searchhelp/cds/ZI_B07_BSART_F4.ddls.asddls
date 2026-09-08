// ============================================================
// 변경이력
// 2026-09-08  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-08.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '문서유형 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZI_B07_BSART_F4
  as select from I_DomainFixedValueText
{
      @UI.hidden: true
  key SAPDataDictionaryDomain,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 10}]
      @EndUserText.label: 'PO Document Type'
      @ObjectModel.text.element: ['BsartText'] // text = 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
  key DomainValue as Bsart,
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
      @EndUserText.label: 'PO Document Type Desc.'
      DomainText  as BsartText
}
where
      SAPDataDictionaryDomain = 'ZDB07BSART'
  and Language                = $session.system_language
