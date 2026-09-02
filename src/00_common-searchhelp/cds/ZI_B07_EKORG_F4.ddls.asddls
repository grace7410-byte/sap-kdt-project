// ============================================================
// 변경이력
// 2026-09-01  최초 작성 (T024E 기반, 회사코드 미배정 건 제외) — devlog: ../../../devlog/rap-dev/2026-09-01.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매조직 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_B07_EKORG_F4
  as select from t024e
{
      @ObjectModel.text.element: ['CombinedText']
      @UI.textArrangement: #TEXT_FIRST
  key ekorg as Ekorg,
      @UI.hidden: true
      ekotx as Ekotx,
      @UI.hidden: true
      bukrs as Bukrs,
      @Semantics.text: true
      concat_with_space( concat( bukrs, ','), ekotx, 1 ) as CombinedText
}
where
  bukrs <> ''
