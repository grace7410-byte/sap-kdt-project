// ============================================================
// 변경이력
// 2026-08-20  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-20.md
// ============================================================
// NOTE: 제품군(Spart) 필드는 이 시점에 자재관리(01) 테이블/뷰에 신규 추가된 필드.
//       ZR_B07_MARA/ZC_B07_MARA에는 아직 필드 자체를 반영하지 않음 (devlog 8/20 참고).
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '제품군 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity zi_b07_spart_f4
  as select from I_DomainFixedValueText
{
      @UI.hidden: true
  key SAPDataDictionaryDomain,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 10}]
      @EndUserText.label: 'Division'
  key DomainValue as Spart,
      @UI.hidden: true
  key Language,
      @UI.hidden: true
  key DomainActivationState,
      @UI.hidden: true
  key DomainValuePosition,
      @UI.hidden: true
  key DomainVersion,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 20}]
      @EndUserText.label: 'Division Description'
      DomainText as SpartText
}
where
      SAPDataDictionaryDomain = 'ZDB07SPART'
  and Language                = $session.system_language
  and DomainActivationState   = 'A'
