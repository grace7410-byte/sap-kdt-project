// ============================================================
// 변경이력
// 2026-08-21  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-21.md
// ============================================================
// NOTE: I_Reconciliationaccttypetext(표준 CDS) 사용. mitkz용 i_domain* 대신 i_recon*으로 검색해서 찾음.
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '조정계정 유형 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity zi_b07_mitkz_f4
  as select from I_Reconciliationaccttypetext
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['ReconciliationAccountTypeName'] // 조정계정 유형과 유형명 함께 띄우기
      @UI.textArrangement: #TEXT_FIRST
  key ReconciliationAccountType,
      @UI.hidden: true
  key Language,
      ReconciliationAccountTypeName
}
where
  Language = $session.system_language
