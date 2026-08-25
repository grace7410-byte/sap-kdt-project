// ============================================================
// 변경이력
// 2026-08-12  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// 2026-08-15  각 필드별 검색조건(selectionField)/라벨 추가, Search.searchable 적용 — devlog: ../../../devlog/rap-dev/2026-08-15.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '저장위치 Search Help'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZI_B07_LGORT_F4
  as select from I_StorageLocation
{
      @EndUserText.label: 'Plant'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
  key Plant,
      @EndUserText.label: 'Storage Location'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 20 }]
  key StorageLocation,
      @EndUserText.label: 'Plant Name'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 30 }]
      _Plant.PlantName,
      @EndUserText.label: 'Description'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 40 }]
      StorageLocationName
}
where
  _Plant._ValuationArea.CompanyCode = 'K200'
