// ============================================================
// 변경이력
// 2026-08-27  최초 작성 (zi_b07_eina 기반 + _Eine composition) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-27  공급업체(_Lfa1)/자재(_Mara) Association 및 텍스트 필드(Liftx/Maktx) 추가 — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-30  레코드유형명(_EsokzText, I_DomainFixedValueText 기반) Association 추가로 Esotx 완성,
//             구매정보내역(Irtxt) 필드 추가 — devlog: ../../../devlog/rap-dev/2026-08-30.md
// 2026-09-02  Ekgrp Value Help를 Root View로 이동(T024 필드 자체에 기본 서치헬프 H_T024가 걸려있어
//             Projection에서 재정의해도 안 먹혀서, 더 상위인 Root View에서 재정의) —
//             devlog: ../../../devlog/rap-dev/2026-09-02.md
// ============================================================
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

association[0..*] to I_DomainFixedValueText as _EsokzText
    on _EsokzText.SAPDataDictionaryDomain = 'ESOKZ'
    and $projection.Esokz = _EsokzText.DomainValue

{
  key InfUuid,
      Infnr,
      /* 레코드 유형명 */
      Esokz,
      _EsokzText[1: Language = $session.system_language].DomainText as Esotx,

      /* 공급업체 코드 및 공급업체명 */
      LifUuid,
      _Lfa1.Lifnr,
      _Lfa1.Name1 as Liftx,

      /* 자재코드 및 자재명 */
      MatUuid,
      _Mara.Matnr,
      _Mara._MaraText[1: Spras = $session.system_language].Maktx,

      Ekorg,
      // 서치헬프 -> 여기 있는 이유: Ekgrp에 기본 서치헬프가 적용되어 있어서, 미리 낚아채줘야 함
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_EKGRP_F4', element: 'Ekgrp' } }]
      Ekgrp,
      Meins,
      Loekz,
      Irtxt,

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
