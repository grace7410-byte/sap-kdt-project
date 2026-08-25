// ============================================================
// 변경이력
// 2026-08-16  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
// NOTE: 필드명 Txt20 → Saktx로 변경 (ZC 쪽과 통일)
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI 계정 Text Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_B07_SKA1TEXT as select from ztb07ska1_t
association to parent ZR_B07_SKA1 as _Ska1
    on $projection.SakUuid = _Ska1.SakUuid
{
    key sak_uuid as SakUuid,
    key spras as Spras,
    txt20 as Saktx,
    _Ska1 // Make association public
}
