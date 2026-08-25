// ============================================================
// 변경이력
// 2026-08-12  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재타입'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_B07_MTART_F4 as select from I_MaterialType
{
    key MaterialType,
    /* Associations */
    _Text[1: Language = $session.system_language].MaterialTypeName
}
where MaterialType = 'FERT'  -- 완제품
   or MaterialType = 'HALB'  -- 반제품
   or MaterialType = 'ROH'   -- 원자재
   or MaterialType = 'HAWA'  -- 상품
   or MaterialType = 'HIBE'  -- 부자재
   or MaterialType = 'VERP'  -- 포장재
