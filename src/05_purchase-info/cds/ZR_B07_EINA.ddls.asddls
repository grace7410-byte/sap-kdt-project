// ============================================================
// 변경이력
// 2026-08-27  최초 작성 (zi_b07_eina 기반 + _Eine composition) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-27  공급업체(_Lfa1)/자재(_Mara) Association 및 텍스트 필드(Liftx/Maktx) 추가 — devlog: ../../../devlog/rap-dev/2026-08-27.md
// ============================================================
// NOTE: 8/27 devlog에 나온 여러 스니펫(기본 필드 → _Lfa1/_Mara 추가)을 하나로 합친 상태입니다.
//       레코드유형명(Esotx) association은 devlog에서 "I_Domain*으로 끌어올 예정"이라고만 언급되고
//       실제 코드는 아직 제시되지 않아 TODO로만 남겨둡니다. ZC_B07_EINA(Projection)는 이미 Esotx를
//       참조하고 있어, Esotx가 채워지기 전까지는 Projection 쪽 활성화 시 오류가 날 수 있습니다.
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보레코드 헤더 Root BO View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zr_b07_eina
  as select from zi_b07_eina
  composition[0..*]  of zi_b07_eine as _Eine

  association[0..1] to ZR_B07_LFA1 as _Lfa1
      on  $projection.LifUuid = _Lfa1.LifUuid

  association[0..1] to zr_b07_mara as _Mara
      on  $projection.MatUuid = _Mara.MatUuid
{
  key InfUuid,
      Infnr,
      Esokz,
      // TODO: Esotx(레코드유형명) association 미완성 — I_Domain* 기반 예정, 코드 미확정 (2026-08-27 시점)

      /* 공급업체 코드 및 공급업체명 */
      LifUuid,
      _Lfa1.Lifnr,
      _Lfa1.Name1 as Liftx,

      /* 자재코드 및 자재명 */
      MatUuid,
      _Mara.Matnr,
      _Mara._MaraText[1: Spras = $session.system_language].Maktx,

      Ekorg,
      Ekgrp,
      Meins,
      Loekz,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreationAt,
      @Semantics.user.lastChangedBy: true
      ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      ChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocChangedAt,
      _Eine // Make association public
}
