// ============================================================
// 변경이력
// 2026-08-27  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-30  loekz(구매정보아이템 취소) 필드 추가 — FS 필드 정의서에 있었으나 최초 작성 시 누락됐던 것을 확인 — devlog: ../../../devlog/rap-dev/2026-08-30.md
// ============================================================
@EndUserText.label : '구매정보레코드 아이템 테이블'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07eine {
  key client   : abap.clnt not null;
  key inf_uuid : abap.raw(16) not null;
  key werks    : ewerk;
  @Semantics.amount.currencyCode : 'ztb07eine.waers'
  netpr        : iprei;
  peinh        : peinh;
  bprme        : bstme;
  waers        : waers;
  @Semantics.quantity.unitOfMeasure : 'ztb07eine.bprme'
  bstma        : maxbm;
  prdat        : prgbi;
  aplfz        : plifz;
  loekz        : iloea;
  include zsb07timestamp;
}
