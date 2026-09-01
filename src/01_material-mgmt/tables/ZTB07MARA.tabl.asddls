// ============================================================
// 변경이력
// 2026-08-12  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// ============================================================
@EndUserText.label : '자재 마스터'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07mara {

  key client   : abap.clnt not null;
  key mat_uuid : abap.raw(16) not null;
  matnr        : zeb07matnr not null;
  mtart        : mtart;
  bklas        : bklas;
  meins        : meins;
  @Semantics.amount.currencyCode : 'ztb07mara.waers'
  stprs        : stprs;
  peinh        : peinh;
  waers        : waers;
  lgort        : lgort_d;
  werks        : werks_d;
  spart        : zeb07spart;
  ersda        : ersda;
  matfi        : matfi;
  include zsb07timestamp;

}
