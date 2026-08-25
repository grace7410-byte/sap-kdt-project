// ============================================================
// 변경이력
// 2026-08-21  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-21.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재코드 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity zi_b07_matnr_f4
  as select from zr_b07_mara
{
      @UI.hidden: true
  key MatUuid,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Material'
      Matnr,
      @EndUserText.label: 'Material Description'
      _MaraText[1: Spras = $session.system_language ].Maktx,
      @EndUserText.label: 'Material Type'
      @Search.defaultSearchElement: true
      Mtart,
      @EndUserText.label: 'Material Type Desc.'
      MtartText
}
