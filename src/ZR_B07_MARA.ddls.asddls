// ============================================================
// 변경이력
// 2026-08-12  최초 작성 (필드 일부 미반영, 진행중) — devlog: ../../../devlog/rap-dev/2026-08-12.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 Root BO View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_B07_MARA
  as select from ztb07mara
  composition [0..*] of ZI_B07_MARATEXT as _MaraText
{
  key mat_uuid    as MatUuid,

  // TODO(2026-08-12): 전체 필드 목록 반영 예정
  // (matnr, mtart, bklas, meins, peinh, lgort, werks, ersda, matfi 등)

  @Semantics.amount.currencyCode: 'Waers'
  stprs           as Stprs,
  waers           as Waers,

  /* Associations */
  _MaraText // Make association public
}
