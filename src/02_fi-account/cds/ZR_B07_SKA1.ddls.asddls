// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (composition + GLAccountType 텍스트 association) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI 계정 Root Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_B07_SKA1 as select from ztb07ska1
composition[0..*] of ZI_B07_SKA1TEXT as _Ska1Text

association[0..1] to I_GLAccountTypeText as _TypeText
  on $projection.Glact = _TypeText.GLAccountType
  and _TypeText.Language = $session.system_language
{
    key sak_uuid as SakUuid,
    saknr as Saknr,
    glact as Glact,
    _TypeText.GLAccountTypeName as GlactText,
    bukrs as Bukrs,
    waers as Waers,
    mitkz as Mitkz,
    xloev as Xloev,
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
    _Ska1Text // Make association public
}
