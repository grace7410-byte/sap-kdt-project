// ============================================================
// 변경이력
// 2026-08-12  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재명 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_B07_MARATEXT
  as select from ztb07mara_t
  association to parent ZR_B07_MARA as _Mara
    on $projection.MatUuid = _Mara.MatUuid
{
  key mat_uuid as MatUuid,
  key spras    as Spras,
      maktx    as Maktx,

  _Mara // Make association public
}
