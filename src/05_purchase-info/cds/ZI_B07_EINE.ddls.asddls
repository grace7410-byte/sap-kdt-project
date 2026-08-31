// ============================================================
// 변경이력
// 2026-08-27  최초 작성 (association to parent 연결) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-27  생성자/생성시간/수정자/수정시간 Semantics Annotation 추가 — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-30  플랜트 텍스트 Association(_Werks) 추가, loekz(구매정보아이템 취소) 필드 노출,
//             LocChangedAt 제거(부모 etag를 dependent로 상속받는 구조라 자식이 별도로 가지면 안 됨) — devlog: ../../../devlog/rap-dev/2026-08-30.md
// ============================================================
// NOTE: 8/30 devlog에 나온 코드에는 loekz 필드가 select 목록에서 빠져 있었는데, 같은 날 Projection(ZC_B07_EINE)과
//       MDE는 이미 Loekz를 참조하고 있어서(테이블에도 필드가 존재) 여기서는 누락으로 보고 추가해뒀습니다.
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보레코드 아이템 Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_b07_eine
  as select from ztb07eine
  association to parent zr_b07_eina as _Eina on $projection.InfUuid = _Eina.InfUuid
    association[0..1] to ZI_B07_WERKS_F4 as _Werks on $projection.Werks = _Werks.Plant
{
  key inf_uuid       as InfUuid,
  key werks          as Werks,
      @Semantics.amount.currencyCode : 'Waers'
      netpr          as Netpr,
      peinh          as Peinh,
      bprme          as Bprme,
      waers          as Waers,
      @Semantics.quantity.unitOfMeasure : 'Bprme'
      bstma          as Bstma,
      prdat          as Prdat,
      aplfz          as Aplfz,
      loekz          as Loekz,
      @Semantics.user.createdBy: true
      created_by     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      creation_at    as CreationAt,
      @Semantics.user.lastChangedBy: true
      changed_by     as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at     as ChangedAt,
      _Eina,
      _Werks
}
