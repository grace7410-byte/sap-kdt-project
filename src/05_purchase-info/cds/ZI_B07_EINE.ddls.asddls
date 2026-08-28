// ============================================================
// 변경이력
// 2026-08-27  최초 작성 (association to parent 연결) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-27  생성자/생성시간/수정자/수정시간 Semantics Annotation 추가 (처음엔 빠뜨렸던 것을 뒤늦게 확인) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보레코드 아이템 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_b07_eine as select from ztb07eine
association to parent zr_b07_eina as _Eina
    on $projection.InfUuid = _Eina.InfUuid
{
    key inf_uuid as InfUuid,
    key werks as Werks,
    @Semantics.amount.currencyCode : 'Waers'
    netpr as Netpr,
    peinh as Peinh,
    bprme as Bprme,
    waers as Waers,
    @Semantics.quantity.unitOfMeasure : 'Bprme'
    bstma as Bstma,
    prdat as Prdat,
    aplfz as Aplfz,
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
    _Eina
}
