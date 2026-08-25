// ============================================================
// 변경이력
// 2026-08-12  최초 작성 (I_Prodvaluationclass 기반) — devlog: ../../../devlog/rap-dev/2026-08-12.md
// 2026-08-16  원본 테이블 T025T 기반으로 재작성 (I_MaterialValuation은 데이터 없어서 폐기) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '평가클래스 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity ZI_B07_BKLAS_F4
  as select from t025t
{
      @Search.defaultSearchElement: true
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['bkbez']
  key bklas,

      @Semantics.text: true
      @Search.defaultSearchElement: true
      @UI.hidden: true
      bkbez
}
where spras = $session.system_language
  and ( bklas = '3000'
     or bklas = '3300'
     or bklas = '7900'
     or bklas = '7920' )
