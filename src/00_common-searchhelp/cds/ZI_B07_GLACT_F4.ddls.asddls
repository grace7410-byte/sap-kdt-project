// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (도메인 GLACCOUNT_TYPE 고정값 텍스트 사용) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '계정(회계) 타입 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity zi_b07_glact_f4 as select from I_DomainFixedValueText
{
    @UI.hidden: true
    DomainValue,
    @Search.defaultSearchElement: true
    @EndUserText.label: 'G/L Account Type'
    DomainText

} where SAPDataDictionaryDomain = 'GLACCOUNT_TYPE'
    and Language = $session.system_language
