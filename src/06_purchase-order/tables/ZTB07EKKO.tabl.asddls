// ============================================================
// 변경이력
// 2026-09-03  최초 작성 — FS 기준 1차 설계 후, 기존 Classic ABAP(1기 SAPMZB1MM0004)
//             단계에서 쓰던 필드(zebeln/zebelnsv, 참조 구매오더번호)를 추가 반영한
//             최종본으로 확정 — devlog: ../../../devlog/rap-dev/2026-09-03.md
// 2026-09-04  bsart 필드를 표준 도메인/DE(bsart, 설명 텍스트 없음)에서 신규
//             데이터엘리먼트 zeb07bsart(도메인 zdb07bsart, Fixed Value 'NB'=표준
//             구매오더 등록)로 교체 — devlog: ../../../devlog/rap-dev/2026-09-04.md
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
  bsart          : zeb07bsart;
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
