// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (ZTB07SKA1 + Text association) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '회계 계정 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity zi_b07_saknr_f4
  as select from ztb07ska1
  association [0..1] to ztb07ska1_t as _Text on  $projection.SakUuid = _Text.sak_uuid
                                             and _Text.spras         = $session.system_language
{
      @UI.hidden: true
  key sak_uuid    as SakUuid,

      @EndUserText.label: 'G/L Account'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
      saknr       as Saknr,

      @EndUserText.label: 'Criterion'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 20 }]
      _Text.txt20 as Description
}
