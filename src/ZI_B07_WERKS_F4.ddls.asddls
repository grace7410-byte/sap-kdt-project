// ============================================================
// 변경이력
// 2026-08-12  최초 작성 (테이블 조인 버전) — devlog: ../../../devlog/rap-dev/2026-08-12.md
//             TODO: 표준 CDS I_Plant 기반으로 재작성 예정
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
// @ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_B07_WERKS_F4
  as select from t001w as w
    inner join   t001k as k on w.bwkey = k.bwkey
{
  key w.werks as Plant,
      w.name1 as PlantName,
      k.bukrs as CompanyCode
} where
  k.bukrs = 'K200'

// TODO(2026-08-12): 표준 CDS I_Plant 기반으로 재작성 예정 (당시엔 I_Plant 존재를 몰랐음)
