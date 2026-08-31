// ============================================================
// 변경이력
// 2026-08-30  최초 작성 (ZC_B07_EINA만 expose) — devlog: ../../../devlog/rap-dev/2026-08-30.md
// 2026-08-30  ZC_B07_EINE expose 추가 — 아이템 MDE까지 만든 뒤에도 Object Page에 아이템이 안 떠서 확인해보니
//             Definition에 EINE이 노출되지 않아 Facet이 참조하는 어노테이션을 못 찾고 있었음 — devlog: ../../../devlog/rap-dev/2026-08-30.md
// ============================================================
@EndUserText.label: '구매정보레코드 Service Definition'
define service ZUI_B07_EINA {
  expose ZC_B07_EINA;
  expose ZC_B07_EINE;
}
