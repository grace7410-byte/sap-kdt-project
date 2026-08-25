// ============================================================
// 변경이력
// 2026-08-21  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-21.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '공급업체 분류 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity zi_b07_fdgrv_f4
  as select from I_DomainFixedValueText
{
      @UI.hidden: true
  key SAPDataDictionaryDomain,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Planning Group'
      @ObjectModel.text.element: ['FdgrvText'] // text 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
  key DomainValue as Fdgrv,
      @UI.hidden: true
  key Language,
      @UI.hidden: true
  key DomainActivationState,
      @UI.hidden: true
  key DomainValuePosition,
      @UI.hidden: true
  key DomainVersion,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.3
      @EndUserText.label: 'Planning Group Description'
      DomainText as FdgrvText
}
where
      SAPDataDictionaryDomain = 'ZDB07FDGRV'
  and Language                = $session.system_language
