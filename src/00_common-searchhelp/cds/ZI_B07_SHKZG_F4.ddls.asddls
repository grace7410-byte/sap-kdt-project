// ============================================================
// 변경이력
// 2026-08-24  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-24.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '차변/대변 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity zi_b07_shkzg_f4
  as select from I_DomainFixedValueText
{
      @UI.hidden: true
  key SAPDataDictionaryDomain,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 10}]
      @EndUserText.label: 'Debit/Credit'
      @ObjectModel.text.element: ['ShkzgText'] // text = 함께 띄우기
      @UI.textArrangement: #TEXT_FIRST
  key DomainValue as Shkzg,
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
      @EndUserText.label: 'Debit/Credit Description'
      DomainText  as ShkzgText
}
where
      SAPDataDictionaryDomain = 'ZDB07SHKZG'
  and Language                = $session.system_language
  and DomainActivationState   = 'A'
