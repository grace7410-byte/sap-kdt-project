// ============================================================
// 변경이력
// 2026-09-08  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-08.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '계정지정범주 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_B07_KNTTP_F4
  as select from t163k as a
    inner join   t163i as b on  a.knttp = b.knttp
{
      @Search.defaultSearchElement: true
  key a.knttp as Knttp,

      @Semantics.text: true
      b.knttx as Knttptx   // 필드명 미확인
}
where
  b.spras = $session.system_language
