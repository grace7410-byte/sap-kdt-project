// ============================================================
// 변경이력
// 2026-08-21  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-21.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '통화 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity zi_b07_waers_f4 as select from I_CurrencyStdVH
{
    @Search.defaultSearchElement: true
    key Currency,
    /* Associations */
    _Text[1: Language = $session.system_language].CurrencyName,
    _Text[1: Language = $session.system_language].CurrencyShortName
}
