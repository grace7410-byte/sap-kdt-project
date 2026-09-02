// ============================================================
// 변경이력
// 2026-09-01  최초 작성 (ZI_B07_BSCHL_F4 패턴을 Duplicate하여 작성, 도메인 ESOKZ FV 기준) — devlog: ../../../devlog/rap-dev/2026-09-01.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '레코드 유형 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZI_B07_ESOKZ_F4
  as select from I_DomainFixedValueText
{
      @UI.hidden: true
  key SAPDataDictionaryDomain,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 10}]
      @EndUserText.label: 'Info Record Type'
      @ObjectModel.text.element: ['EsokzText'] // text = 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
  key DomainValue as Esokz,
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
      @EndUserText.label: 'Info Record Type Desc.'
      DomainText as EsokzText
}
where
      SAPDataDictionaryDomain = 'ESOKZ'
  and Language                = $session.system_language
