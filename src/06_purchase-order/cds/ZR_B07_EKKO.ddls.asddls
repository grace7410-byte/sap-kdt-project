// ============================================================
// 변경이력
// 2026-09-07  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-07.md
// ============================================================
// ※ 아래 필드/연관 목록은 devlog에 나뉘어 제시된 두 코드 조각(구매조직·구매그룹 텍스트
//   추가본 + 이후 회사코드·통화 텍스트를 Root로 옮긴 수정본)을 병합해 재구성한 것입니다.
//   실제 최종 코드와 다르면 알려주세요.
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 헤더 Root BO View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_B07_EKKO as select from ZI_B07_EKKO
  composition[0..*] of ZI_B07_EKPO as _Ekpo

  association[0..*] to I_DomainFixedValueText as _BsartText
    on  _BsartText.SAPDataDictionaryDomain = 'ZDB07BSART'
    and $projection.Bsart = _BsartText.DomainValue

  association[0..1] to Zi_B07_Ekorg_F4 as _EkorgText
    on $projection.Ekorg = _EkorgText.Ekorg
  association[0..1] to ZI_B07_EKGRP_F4 as _EkgrpText
    on $projection.Ekgrp = _EkgrpText.Ekgrp

  association [0..1] to zi_b07_bukrs_f4 as _BukrsText on $projection.Bukrs = _BukrsText.CompanyCode
  association [0..1] to zi_b07_waers_f4 as _WaersText on $projection.Waers = _WaersText.Currency
{
    key EbelnUuid,
    Ebeln,
    LifUuid,
    Lifnr,
    Name1,
    Bukrs,
    _BukrsText.CompanyCodeName as BukrsText,
    Ekorg,
    _EkorgText.Ekotx,
    // 서치헬프 -> 여기 있는 이유: Ekgrp에 기본 서치헬프(H_T024)가 걸려있어
    // Projection 단 재정의가 안 먹힘(05번과 동일 이슈/해법)
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_EKGRP_F4', element: 'Ekgrp' } }]
    Ekgrp,
    _EkgrpText.Eknam,
    Bsart,
    Bedat,
    Waers,
    _WaersText.CurrencyName as WaersText,
    Zterm,
    Inco1,
    Knumh,
    Zebeln,
    Zebelnsv,
    Pdesc,
    Loekz,
    CreatedBy,
    CreationAt,
    ChangedBy,
    ChangedAt,
    LocChangedAt,
    /* Associations */
    _Lfa1,
    _BukrsText,
    _WaersText,
    _BsartText,
    _EkorgText,
    _EkgrpText,
    _Ekpo // Make association public
}
