// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (Redirect + 필드순서/Sort/검색조건 반영, MARA 패턴 참고) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI 계정 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'Saknr' ]
@UI.presentationVariant: [{ sortOrder: [
    { by: 'Glact', direction: #ASC },
    { by: 'Saknr', direction: #ASC }
 ]}]
define root view entity ZC_B07_SKA1
  // provider contract transactional_query // 이거 필요없음 (V2, No Draft)
  as projection on ZR_B07_SKA1
{
  key SakUuid,

      /********* 계정타입 ************/
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @UI.selectionField: [{  position: 10  }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_GLACT_F4', element: 'DomainText' } }]
      @ObjectModel.text.element: ['GlactText']
      @UI.textArrangement: #TEXT_LAST
      Glact,
      GlactText,

      /********* FI 계정 ************/
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @UI.selectionField: [{  position: 20  }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_SAKNR_F4', element: 'Saknr' } }]
      @ObjectModel.text.element: ['Saktx']
      @UI.textArrangement: #TEXT_LAST
      Saknr,

      Bukrs,
      Waers,
      Mitkz,
      Xloev,
      CreatedBy,
      CreationAt,
      ChangedBy,
      ChangedAt,
      LocChangedAt,

      /* Associations */
      _Ska1Text[1: Spras = $session.system_language].Saktx as Saktx,
      _Ska1Text : redirected to composition child ZC_B07_SKA1TEXT
}
