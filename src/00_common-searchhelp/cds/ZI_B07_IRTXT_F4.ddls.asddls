// ============================================================
// 변경이력
// 2026-09-01  최초 작성 (ZI_B07_ESOKZ_F4를 Duplicate하여 작성. 신규 도메인 ZDB07IRTXT의 FV 11건을 노출.
//             자유 텍스트 필드(Irtxt) 대상 사용자 편의용 서치헬프이며, 값 범위를 강제하는 Validation은
//             의도적으로 만들지 않음 — devlog: ../../../devlog/rap-dev/2026-09-01.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보내역 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZI_B07_IRTXT_F4
  as select from I_DomainFixedValueText
{
      @UI.hidden: true
  key SAPDataDictionaryDomain,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{position: 10}]
      @EndUserText.label: 'Info Record Text'
  key DomainValue as Irtxt,
      @UI.hidden: true
  key Language,
      @UI.hidden: true
  key DomainActivationState,
      @UI.hidden: true
  key DomainValuePosition,
      @UI.hidden: true
  key DomainVersion,
      @UI.hidden: true
      DomainText
}
where
      SAPDataDictionaryDomain = 'ZDB07IRTXT'
  and Language                = $session.system_language
