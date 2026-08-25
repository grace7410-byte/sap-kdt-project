// ============================================================
// 변경이력
// 2026-08-18  최초 작성 + SKA1 연결(계정타입/조정계정 텍스트) 반영 — devlog: ../../../devlog/rap-dev/2026-08-18.md
// ============================================================
// NOTE: 원문 그대로 옮김. 공급업체 분류 텍스트(_FdgrvText)와 조정계정 연결(_Account)은
//       같은 날 안에서 순차적으로 추가된 내용을 하나로 합친 최종본입니다.
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '공급업체 Root Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_B07_LFA1
  as select from ztb07lfa1

  association[0..*] to I_DomainFixedValueText as _FdgrvText
    on _FdgrvText.SAPDataDictionaryDomain = 'ZDB07FDGRV'
    and $projection.Fdgrv = _FdgrvText.DomainValue

  association[0..1] to ZR_B07_SKA1 as _Account
    on $projection.Akont = _Account.Saknr
{
  key lif_uuid       as LifUuid,
      lifnr          as Lifnr,
      name1          as Name1,
      ekorg          as Ekorg,
      ekgrp          as Ekgrp,
      waers          as Waers,
      @Semantics.amount.currencyCode: 'Waers'
      minbw          as Minbw,

      fdgrv          as Fdgrv,
      _FdgrvText[1: Language = $session.system_language ].DomainText as Fdgxt,

      /*********   조정계정 Text   ************/
      akont          as Akont,
      _Account._Ska1Text[1: Spras = $session.system_language ].Saktx as Akontxt,
      _Account.Glact as Glact,
      _Account.GlactText as Glactxt,

      loevm          as Loevm,
      @Semantics.user.createdBy: true
      created_by     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      creation_at    as CreationAt,
      @Semantics.user.lastChangedBy: true
      changed_by     as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at     as ChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      loc_changed_at as LocChangedAt
}
