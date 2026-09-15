@EndUserText.label : 'BOM (부품구성) 마스터'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table ztb07bom {
  key client   : abap.clnt not null;
  key bom_uuid : abap.raw(16) not null;
  stlnr        : zeb07matnr not null;      " 그룹ID (완제품 모델코드로 사용, 예: 'SM-FOLD')
  stlkn        : abap.numc(4) not null;    " 그룹 내 일련번호 10/20/30...
  comp_uuid    : abap.raw(16) not null;    " 자재 UUID → ZTB07MARA (완제품 자신도 여기 들어감)
  fmeng        : abap.dec(13,3);           " 수량 — 완제품 행만 음수, 부품 행은 양수 (1기 트릭 유지)
  meins        : meins;
  loekz        : zeb07del;
  include zsb07timestamp_v2;
}
