// ============================================================
// 변경이력
// 2026-08-12  최초 작성, Redirect 미처리 상태 — devlog: ../../../devlog/rap-dev/2026-08-12.md
//             TODO: _Mara association Redirect 처리 (2026-08-13 반영 예정)
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
  // TODO(2026-08-12): _Mara association이 현재 Interface(ZR_B07_MARA)를 그대로 가리키는 상태.
  // Projection ↔ Projection 연결을 위한 Redirect 처리 필요 (2026-08-13 반영 예정)
  _Mara
}
