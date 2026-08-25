@EndUserText.label : '회계계정결정 테이블'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07t030 {

  key client   : abap.clnt not null;
  key map_uuid : abap.raw(16) not null;
  bwart        : zeb07bwart not null;
  seqnr        : abap.numc(3) not null;
  bklas        : bklas;
  bschl        : zeb07bschl;
  shkzg        : zeb07shkzg;
  ktosl        : zeb07ktosl;
  saknr        : zeb07saknr;
  include zsb07timestamp_v2;

}
