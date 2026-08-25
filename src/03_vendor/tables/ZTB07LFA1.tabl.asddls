// ============================================================
// 변경이력
// 2026-08-18  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-18.md
// ============================================================
@EndUserText.label : '공급업체 마스터'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07lfa1 {

  key client   : abap.clnt not null;
  key lif_uuid : abap.raw(16) not null;
  lifnr        : zeb07lifnr not null;
  name1        : name1;
  ekorg        : ekorg;
  ekgrp        : ekgrp;
  waers        : bstwa;
  @Semantics.amount.currencyCode : 'ztb07lfa1.waers'
  minbw        : minbw;
  fdgrv        : zeb07fdgrv;
  akont        : akont;
  loevm        : loevm_x;
  include zsb07timestamp;

}
