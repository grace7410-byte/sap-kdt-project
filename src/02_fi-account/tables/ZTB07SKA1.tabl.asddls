// ============================================================
// 변경이력
// 2026-08-16  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@EndUserText.label : 'FI 계정 마스터'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07ska1 {

  key client   : abap.clnt not null;
  key sak_uuid : abap.raw(16) not null;
  saknr        : zeb07saknr not null;
  glact        : glaccount_type;
  bukrs        : bukrs;
  waers        : waers;
  mitkz        : mitkz;
  xloev        : xloev;
  include zsb07timestamp;

}
