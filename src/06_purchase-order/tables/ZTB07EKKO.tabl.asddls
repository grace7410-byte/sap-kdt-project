// ============================================================
// 변경이력
// 2026-09-03  최초 작성 — FS 기준 1차 설계 후, 기존 Classic ABAP(1기 SAPMZB1MM0004)
//             단계에서 쓰던 필드(zebeln/zebelnsv, 참조 구매오더번호)를 추가 반영한
//             최종본으로 확정 — devlog: ../../../devlog/rap-dev/2026-09-03.md
// ============================================================
@EndUserText.label : '구매오더 헤더'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07ekko {
  key client     : abap.clnt not null;
  key ebeln_uuid : abap.raw(16) not null;
  ebeln          : zeb07ebeln not null;
  lif_uuid       : abap.raw(16);
  bukrs          : bukrs;
  ekorg          : ekorg;
  ekgrp          : ekgrp;
  bsart          : bsart;
  bedat          : ebdat;
  waers          : waers;
  zterm          : dzterm;
  inco1          : inco1;
  knumh          : knumh;
  zebeln         : zeb07ebeln;
  zebelnsv       : zeb07ebeln;
  pdesc          : abap.char(40);
  loekz          : zeb07del;
  include zsb07timestamp;
}
