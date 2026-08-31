// ============================================================
// 변경이력
// 2026-08-27  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-30  txz01(구매정보내역) 필드를 Irtxt로 노출 — devlog: ../../../devlog/rap-dev/2026-08-30.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보레코드 헤더 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_b07_eina
  as select from ztb07eina
{
  key inf_uuid       as InfUuid,
      infnr          as Infnr,
      esokz          as Esokz,
      lif_uuid       as LifUuid,
      mat_uuid       as MatUuid,
      ekorg          as Ekorg,
      ekgrp          as Ekgrp,
      meins          as Meins,
      loekz          as Loekz,
      txz01          as Irtxt,
      created_by     as CreatedBy,
      creation_at    as CreationAt,
      changed_by     as ChangedBy,
      changed_at     as ChangedAt,
      loc_changed_at as LocChangedAt
}
