// ============================================================
// 변경이력
// 2026-09-07  최초 작성 — devlog: ../../../devlog/rap-dev/2026-09-07.md
// 2026-09-08  Loekz를 abap_boolean으로 캐스팅(Fiori Elements 체크박스 렌더링을 위해 Edm.Boolean
//             노출 필요, 원본 도메인은 Edm.String) — devlog: ../../../devlog/rap-dev/2026-09-08.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매오더 헤더 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_B07_EKKO
  as select from ztb07ekko
  association [0..1] to ZR_B07_LFA1 as _Lfa1 on $projection.LifUuid = _Lfa1.LifUuid
{
  key ebeln_uuid     as EbelnUuid,
      ebeln          as Ebeln,
      lif_uuid       as LifUuid,
      _Lfa1.Lifnr    as Lifnr,
      _Lfa1.Name1    as Name1,
      bukrs          as Bukrs,
      ekorg          as Ekorg,
      ekgrp          as Ekgrp,
      bsart          as Bsart,
      bedat          as Bedat,
      waers          as Waers,
      zterm          as Zterm,
      inco1          as Inco1,
      knumh          as Knumh,
      zebeln         as Zebeln,
      zebelnsv       as Zebelnsv,
      pdesc          as Pdesc,
      cast( loekz as abap_boolean preserving type ) as Loekz,
      @Semantics.user.createdBy: true
      created_by     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      creation_at    as CreationAt,
      @Semantics.user.lastChangedBy: true
      changed_by     as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at     as ChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      loc_changed_at as LocChangedAt,


      /* Associations */
      _Lfa1 // Make association public
}
