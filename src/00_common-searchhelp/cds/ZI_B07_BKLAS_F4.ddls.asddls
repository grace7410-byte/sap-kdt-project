// ============================================================
// 변경이력
// 2026-08-12  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '평가클래스 Search Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_B07_BKLAS_F4
  as select from I_Prodvaluationclass
{
  key ValuationClass,
      /* Associations */
       _ValuationClassText[ 1: Language = $session.system_language ].ValuationClassDescription
}
where ValuationClass = '3000'
   or ValuationClass = '3300'
   or ValuationClass = '7900'
   or ValuationClass = '7920'
