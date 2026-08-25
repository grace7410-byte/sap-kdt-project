// ============================================================
// 변경이력
// 2026-08-12  최초 작성, Redirect 미처리 상태 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// 2026-08-13  _Mara association Redirect 처리 완료 — devlog: ../../../devlog/rap-dev/2026-08-13.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재명 Projection View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_B07_MARATEXT
  provider contract transactional_query
  as projection on ZI_B07_MARATEXT
{
  key MatUuid,
  key Spras,
      Maktx,

  /* Associations */
  _Mara : redirected to parent ZC_B07_MARA
}
