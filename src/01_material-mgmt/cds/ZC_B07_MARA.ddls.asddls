// ============================================================
// 변경이력
// 2026-08-12  최초 작성 (필드 일부 미반영, 진행중) — devlog: ../../../devlog/rap-dev/2026-08-12.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_B07_MARA
  provider contract transactional_query
  as projection on ZR_B07_MARA
{
  key MatUuid,

  // TODO(2026-08-12): 전체 필드 목록 반영 예정

  @Semantics.amount.currencyCode: 'Waers'
  Stprs,
  Waers,

  /* Associations */
  _MaraText : redirected to composition child ZC_B07_MARATEXT
}
