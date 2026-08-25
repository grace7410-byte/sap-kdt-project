// ============================================================
// 변경이력
// 2026-08-21  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-21.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '회사코드 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
// @ObjectModel.resultSet.sizeCategory: #XS
define view entity zi_b07_bukrs_f4
  as select from I_CompanyCode
{
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Company'
      @UI.lineItem: [{position: 10}]
      @ObjectModel.text.element: ['CompanyCodeName'] // 회사코드와 코드명 함께 띄우기
      @UI.textArrangement: #TEXT_FIRST
  key CompanyCode,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Company Description'
      @UI.lineItem: [{position: 20}]
      CompanyCodeName,
      @UI.lineItem: [{position: 30}]
      CityName,
      @UI.lineItem: [{position: 40}]
      Language,
      @UI.lineItem: [{position: 50}]
      ChartOfAccounts,
      @UI.lineItem: [{position: 60}]
      ControllingArea
}
where
  (
        Country     =  'KR'
    and CompanyCode <> 'KA28'
  )
  or    CompanyCode =  '0001'
