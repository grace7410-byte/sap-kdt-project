// ============================================================
// 변경이력
// 2026-09-03  최초 작성 — FS 기준 1차 설계 후, 기존 Classic ABAP(1기 SAPMZB1MM0004)
//             단계에서 쓰던 필드(wrbtr/waers/dmbtr/waersk/slfdt/insmk/packno/knttp/
//             sakto/epstp/postat)를 추가 반영한 최종본으로 확정 —
//             devlog: ../../../devlog/rap-dev/2026-09-03.md
// ============================================================
@EndUserText.label : '구매오더 아이템'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07ekpo {
  key client     : abap.clnt not null;
  key ebeln_uuid : abap.raw(16) not null;
  key ebelp      : zeb07ebelp not null;
  mat_uuid       : abap.raw(16);
  txz01          : txz01;
  mtart          : mtart;
  inf_uuid       : abap.raw(16);
  werks          : ewerk;
  lgort          : lgort_d;
  @Semantics.quantity.unitOfMeasure : 'ztb07ekpo.meins'
  menge          : bstmg;
  meins          : bstme;
  @Semantics.amount.currencyCode : 'ztb07ekko.waers'
  netpr          : bprei;
  @Semantics.amount.currencyCode : 'ztb07ekpo.waers'
  wrbtr          : wrbtr;
  waers          : waers;
  @Semantics.amount.currencyCode : 'ztb07ekpo.waersk'
  dmbtr          : dmbtr;
  waersk         : waers;
  mwskz          : mwskz;
  eindt          : eindt;
  slfdt          : slfdt;
  insmk          : insmk;
  packno         : packno;
  knttp          : knttp;
  sakto          : zeb07saknr;
  epstp          : epstp;
  postat         : zeb07postat;
  loekz          : zeb07del;
  elikz          : elikz;
  erekz          : erekz;
  include zsb07timestamp_v2;
}
