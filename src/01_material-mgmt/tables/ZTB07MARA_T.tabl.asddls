// ============================================================
// 변경이력
// 2026-08-12  최초 작성 — devlog: ../../../devlog/rap-dev/2026-08-12.md
// ============================================================
@EndUserText.label : '자재 마스터 Text'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07mara_t {

  key client   : abap.clnt not null;
  key mat_uuid : abap.raw(16) not null;
  @AbapCatalog.foreignKey.keyType : #KEY
  @AbapCatalog.foreignKey.screenCheck : true
  key spras    : spras not null
    with foreign key [0..*,1] t002
      where spras = ztb07mara_t.spras;
  maktx        : maktx;

}
