// ============================================================
// 변경이력
// 2026-08-16  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@EndUserText.label : 'FI 계정 마스터 Text'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07ska1_t {

  key client   : abap.clnt not null;
  key sak_uuid : abap.raw(16) not null;
  key spras    : spras not null;
  txt20        : txt20_skat;

}
