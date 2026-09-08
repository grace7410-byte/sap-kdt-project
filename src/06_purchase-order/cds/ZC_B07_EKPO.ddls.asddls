// ============================================================
// 변경이력
// 2026-09-08  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-08.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 아이템 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_B07_EKPO
  as projection on ZI_B07_EKPO
{
  key EbelnUuid,
  key Ebelp,

      // Value Help 필터링 전용(헤더 공급업체) — 화면 비노출은 MDE에서 처리 예정
      _Ekko.LifUuid               as HeaderLifUuid,

      @ObjectModel.text.element: ['WerksText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_WERKS_F4', element: 'Plant' } }]
      Werks,
      WerksText,

      @ObjectModel.text.element: ['LgortText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_B07_LGORT_F4', element: 'StorageLocation' },
        additionalBinding: [{ localElement: 'Werks', element: 'Plant', usage: #FILTER }]
      }]
      Lgort,
      LgortText,

      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_B07_INFNR_F4', element: 'Infnr' },
        additionalBinding: [
          { localElement: 'Werks',         element: 'Werks',   usage: #FILTER },
          { localElement: 'HeaderLifUuid', element: 'LifUuid', usage: #FILTER }
        ]
      }]
      InfUuid,
      Infnr,

      @ObjectModel.text.element: ['Maktx']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_MATNR_F4', element: 'Matnr' } }]
      MatUuid,
      Matnr,
      Maktx,
      Txz01,

      @ObjectModel.text.element: ['MtartText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_MTART_F4', element: 'MaterialType' } }]
      Mtart,
      _MtartText.MaterialTypeName as MtartText,

      @Semantics.quantity.unitOfMeasure: 'Meins'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_MEINS_F4', element: 'Msehi' } }]
      Menge,
      Meins,
      @Semantics.amount.currencyCode: 'Waers'
      Netpr,

      @Semantics.amount.currencyCode: 'Waers'
      Wrbtr,
      @ObjectModel.text.element: ['WaersText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_WAERS_F4', element: 'Currency' } }]
      Waers,
      _WaersText.CurrencyName     as WaersText,

      @Semantics.amount.currencyCode: 'Waersk'
      Dmbtr,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_WAERS_F4', element: 'Currency' } }]
      Waersk,

      @ObjectModel.text.element: ['Mwskztx']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_B07_MWSKZ_F4', element: 'Mwskz' },
        additionalBinding: [{ localElement: 'HeaderBukrs', element: 'Bukrs', usage: #FILTER }]
      }]
      Mwskz,
      _MwskzText.Mwskztx as Mwskztx,
      HeaderBukrs,

      Eindt,
      Slfdt,

      @ObjectModel.text.element: ['Insmktx']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_INSMK_F4', element: 'Insmk' } }]
      Insmk,
      _InsmkText.Insmktx as Insmktx,

      Packno,

      @ObjectModel.text.element: ['Knttptx']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_KNTTP_F4', element: 'Knttp' } }]
      Knttp,
      _KnttpText.Knttptx as Knttptx,

      @ObjectModel.text.element: ['SaktoText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_SAKNR_F4', element: 'Saknr' } }]
      Sakto,
      _SaknrText.Description      as SaktoText,

      @ObjectModel.text.element: ['Epstptx']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_EPSTP_F4', element: 'Epstp' } }]
      Epstp,
      _EpstpText.Epstptx as Epstptx,

      @ObjectModel.text.element: ['Postattx']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_POSTAT_F4', element: 'Postat' } }]
      Postat,
      _PostatText.Postattx as Postattx,

      Loekz,
      Elikz,
      Erekz,
      CreatedBy,
      CreationAt,
      ChangedBy,
      ChangedAt,

      /* Associations */
      _Eine,
      _Ekko : redirected to parent ZC_B07_EKKO,
      _Lgort,
      _Mara,
      _Werks,
      _MtartText,
      _SaknrText,
      _WaersText
}
