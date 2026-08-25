// ============================================================
// 변경이력
// 2026-08-12  최초 작성 (필드 일부 미반영, 진행중) — devlog: ../../../devlog/rap-dev/2026-08-12.md
// 2026-08-13  자재타입/플랜트 텍스트 Association 추가 (_TypeText, _PlantText) — devlog: ../../../devlog/rap-dev/2026-08-13.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '자재 Root BO View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_B07_MARA
  as select from ztb07mara
  composition [0..*] of ZI_B07_MARATEXT as _MaraText
  association[0..*] to I_MaterialTypeText as _TypeText
    on $projection.Mtart = _TypeText.MaterialType
  association[0..1] to I_Plant as _PlantText
    on $projection.Waers = _PlantText.Plant
{
  key mat_uuid    as MatUuid,

  // TODO: 전체 필드 목록 반영 예정
  // (matnr, mtart, bklas, meins, peinh, lgort, werks, ersda, matfi 등)

  @Semantics.amount.currencyCode: 'Waers'
  stprs           as Stprs,
  waers           as Waers,

  /* 텍스트 Association 필드 (2026-08-13 추가) */
  _TypeText[1: Language = $session.system_language].MaterialTypeName as MtartText,
  _PlantText[1: Language = $session.system_language].PlantName as WerksText,

  /* Associations */
  _MaraText, // Make association public
  _TypeText,
  _PlantText
}
