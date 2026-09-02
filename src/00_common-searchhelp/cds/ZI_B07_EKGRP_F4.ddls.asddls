// ============================================================
// 변경이력
// 2026-09-01  최초 작성 (T024 기반, 전체 필드 노출) — devlog: ../../../devlog/rap-dev/2026-09-01.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매그룹 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_B07_EKGRP_F4
  as select from t024
{
  key ekgrp      as Ekgrp,
      eknam      as Eknam,
      ektel      as Ektel,
      ldest      as Ldest,
      telfx      as Telfx,
      tel_number as TelNumber,
      tel_extens as TelExtens,
      smtp_addr  as SmtpAddr
}
