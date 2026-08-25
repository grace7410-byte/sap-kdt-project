// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (표준 테이블 T030A 대신 ZTB07T030A 커스텀 테이블 사용) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '회계결정코드 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity zi_b07_ktosl_f4
  as select from ztb07t030a
{
      @UI.hidden: true
  key map_uuid as MapUuid,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Ltext']
      ktosl    as Ktosl,
      ltext    as Ltext
}
