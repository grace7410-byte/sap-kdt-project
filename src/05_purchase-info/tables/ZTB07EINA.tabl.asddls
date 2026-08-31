// ============================================================
// 변경이력
// 2026-08-27  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-30  txz01(구매정보내역) 필드 추가 — devlog: ../../../devlog/rap-dev/2026-08-30.md
// ============================================================
@EndUserText.label : '구매정보레코드 테이블'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07eina {
  key client   : abap.clnt not null;
  key inf_uuid : abap.raw(16) not null;
  infnr        : zeb07infnr not null;
  esokz        : esokz;
  lif_uuid     : abap.raw(16);
  mat_uuid     : abap.raw(16);
  ekorg        : ekorg;
  ekgrp        : ekgrp;
  meins        : meins;
  loekz        : iloea;
  txz01        : txz01;
  include zsb07timestamp;
}
