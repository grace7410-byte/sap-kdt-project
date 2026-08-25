// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (Redirect, 필드명 Txt20 → Saktx) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI 계정 Text Projection View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_B07_SKA1TEXT
  as projection on ZI_B07_SKA1TEXT
{
  key SakUuid,
  key Spras,
      Saktx,
      /* Associations */
      _Ska1 : redirected to parent ZC_B07_SKA1
}
