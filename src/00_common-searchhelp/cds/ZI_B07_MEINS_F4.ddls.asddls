// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (T006A 기반, 4개 단위 하드코딩) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '단위 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity zi_b07_meins_f4
  as select from t006a
{
      @Search.defaultSearchElement: true
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['mseht']
  key msehi,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      mseht
}
where
       spras = $session.system_language
  and( msehi = 'BAG'
    or msehi = 'EA'
    or msehi = 'G'
    or msehi = 'KG'
  )
