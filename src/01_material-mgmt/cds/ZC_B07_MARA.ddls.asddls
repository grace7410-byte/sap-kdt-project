// ============================================================
// 변경이력
// 2026-08-12  최초 작성 (필드 일부 미반영, 진행중) — devlog: ../../../devlog/rap-dev/2026-08-12.md
// 2026-08-13  정렬(Sort)/검색조건/Value Help/텍스트 배치/저장위치 Association 반영 — devlog: ../../../devlog/rap-dev/2026-08-13.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [
    { by: 'Werks', direction: #ASC },
    { by: 'Ersda', direction: #DESC }
 ]}]
define root view entity ZC_B07_MARA
  provider contract transactional_query
  as projection on ZR_B07_MARA
  association[0..1] to I_StorageLocation as _SlocText
    on $projection.Lgort = _SlocText.StorageLocation
    and $projection.Werks = _SlocText.Plant
{
  key MatUuid,

  // TODO: 전체 필드 목록 반영 예정

  /********* 자재타입 ************/
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.selectionField: [{  position: 10  }]
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_MTART_F4', element: 'MaterialType' } }]
  @ObjectModel.text.element: ['MtartText']
  @UI.textArrangement: #TEXT_FIRST
  Mtart,

  /********* 플랜트 ************/
  @ObjectModel.text.element: ['WerksText']
  @UI.textArrangement: #TEXT_FIRST
  Werks,
  WerksText,

  /********* 자재 ************/
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.selectionField: [{  position: 20  }]
  @EndUserText.label: 'Material'
  @ObjectModel.text.element: ['Maktx']
  @UI.textArrangement: #TEXT_FIRST
  Matnr,
  Ersda,

  @UI.hidden: true
  MtartText,

  /********* 저장위치 ************/
  @ObjectModel.text.element: ['LgortText']
  @UI.textArrangement: #TEXT_FIRST
  Lgort,
  _SlocText.StorageLocationName as LgortText,

  @Semantics.amount.currencyCode: 'Waers'
  Stprs,
  Waers,

  /* Associations */
  _MaraText[1: Spras = $session.system_language].Maktx as MatnrText,
  _MaraText : redirected to composition child ZC_B07_MARATEXT
}
