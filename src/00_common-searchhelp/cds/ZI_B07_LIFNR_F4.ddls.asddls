// ============================================================
// 변경이력
// 2026-08-26  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-26.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '공급업체 코드 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_B07_LIFNR_F4
  as select from ZR_B07_LFA1
{
      @UI.hidden: true
  key LifUuid,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Supplier'
      Lifnr,
      @EndUserText.label: 'Name 1'
      Name1,
      @EndUserText.label: 'Planning Group'
      @Search.defaultSearchElement: true
      Fdgrv,
      @EndUserText.label: 'Short Description'
      Fdgxt
}
