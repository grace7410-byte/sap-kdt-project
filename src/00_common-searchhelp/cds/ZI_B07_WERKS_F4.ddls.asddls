// ============================================================
// 변경이력
// 2026-08-12  최초 작성 (테이블 조인 버전) — devlog: ../../../devlog/rap-dev/2026-08-12.md
//             TODO: 표준 CDS I_Plant 기반으로 재작성 예정
// 2026-08-15  각 필드별 검색조건(selectionField)/라벨 추가, Search.searchable 적용 — devlog: ../../../devlog/rap-dev/2026-08-15.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '플랜트 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
//@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZI_B07_WERKS_F4
  as select from t001w as w
    inner join   t001k as k on w.bwkey = k.bwkey
{
      @EndUserText.label: 'Plant'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
  key w.werks as Plant,
      @EndUserText.label: 'Plant Name'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 20 }]
      w.name1 as PlantName,
      @EndUserText.label: 'Company Code'
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 30 }]
      k.bukrs as CompanyCode
}
where
  k.bukrs = 'K200'
