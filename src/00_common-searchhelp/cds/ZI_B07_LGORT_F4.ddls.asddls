// ============================================================
// 변경이력
// 2026-08-12  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '저장위치 Search Help'
@Metadata.ignorePropagatedAnnotations: true
// @ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_B07_LGORT_F4
  as select from I_StorageLocation
{
  key Plant,
  key StorageLocation,
      StorageLocationName,
      /* Associations */
      _Plant.PlantName
}
where _Plant._ValuationArea.CompanyCode = 'K200'
