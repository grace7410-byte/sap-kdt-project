// ============================================================
// 변경이력
// 2026-09-07  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-07.md
// 2026-09-08  자재유형(_MtartText)/G·L계정(_SaknrText)/통화(_WaersText)/세금코드(_MwskzText)/품목범주
//             (_EpstpText)/재고유형(_InsmkText)/계정지정범주(_KnttpText)/진행상태(_PostatText) 텍스트
//             Association 추가, 헤더 회사코드(HeaderBukrs) 필드 추가 — devlog: ../../../devlog/rap-dev/2026-09-08.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 아이템 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_B07_EKPO
  as select from ztb07ekpo
  association to parent ZR_B07_EKKO as _Ekko
      on $projection.EbelnUuid = _Ekko.EbelnUuid
  association [0..1] to zr_b07_mara     as _Mara  on  $projection.MatUuid = _Mara.MatUuid
  association [0..1] to zi_b07_eine     as _Eine  on  $projection.InfUuid = _Eine.InfUuid
                                                  and $projection.Werks   = _Eine.Werks
  association [0..1] to ZI_B07_WERKS_F4 as _Werks on  $projection.Werks = _Werks.Plant
  association [0..1] to ZI_B07_LGORT_F4 as _Lgort on  $projection.Werks = _Lgort.Plant
                                                  and $projection.Lgort = _Lgort.StorageLocation
  association [0..1] to ZI_B07_MTART_F4 as _MtartText on $projection.Mtart = _MtartText.MaterialType
  association [0..1] to zi_b07_saknr_f4 as _SaknrText on $projection.Sakto = _SaknrText.Saknr
  association [0..1] to zi_b07_waers_f4 as _WaersText on $projection.Waers = _WaersText.Currency

  association[0..1] to ZI_B07_MWSKZ_F4 as _MwskzText
    on  $projection.HeaderBukrs = _MwskzText.Bukrs
    and $projection.Mwskz       = _MwskzText.Mwskz
  association[0..1] to ZI_B07_EPSTP_F4 as _EpstpText on $projection.Epstp = _EpstpText.Epstp
  association[0..1] to ZI_B07_INSMK_F4 as _InsmkText on $projection.Insmk = _InsmkText.Insmk
  association[0..1] to ZI_B07_KNTTP_F4 as _KnttpText on $projection.Knttp = _KnttpText.Knttp
  association[0..1] to ZI_B07_POSTAT_F4 as _PostatText on $projection.Postat = _PostatText.Postat
{
  key ebeln_uuid  as EbelnUuid,
  key ebelp       as Ebelp,

      _Ekko.Bukrs   as HeaderBukrs,

      mat_uuid    as MatUuid,
      _Mara.Matnr,
      _Mara._MaraText[1: Spras = $session.system_language ].Maktx,
      txz01       as Txz01,
      mtart       as Mtart,
      inf_uuid    as InfUuid,
      _Eine._Eina.Infnr,
      werks       as Werks,
      _Werks.PlantName as WerksText,
      lgort       as Lgort,
      _Lgort.StorageLocationName as LgortText,
      @Semantics.quantity.unitOfMeasure: 'Meins'
      menge       as Menge,
      meins       as Meins,
      @Semantics.amount.currencyCode: 'Waers'
      netpr       as Netpr,
      @Semantics.amount.currencyCode: 'Waers'
      wrbtr       as Wrbtr,
      waers       as Waers,
      @Semantics.amount.currencyCode: 'Waersk'
      dmbtr       as Dmbtr,
      waersk      as Waersk,
      mwskz       as Mwskz,
      eindt       as Eindt,
      slfdt       as Slfdt,
      insmk       as Insmk,
      packno      as Packno,
      knttp       as Knttp,
      sakto       as Sakto,
      epstp       as Epstp,
      postat      as Postat,
      loekz       as Loekz,
      elikz       as Elikz,
      erekz       as Erekz,
      @Semantics.user.createdBy: true
      created_by  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      creation_at as CreationAt,
      @Semantics.user.lastChangedBy: true
      changed_by  as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at  as ChangedAt,

      /* Associations */
      _Ekko, // Make association public
      _Mara,
      _Eine,
      _Werks,
      _Lgort,
      _MtartText,
      _SaknrText,
      _WaersText,
      _EpstpText,
      _InsmkText,
      _KnttpText,
      _MwskzText,
      _PostatText
}
