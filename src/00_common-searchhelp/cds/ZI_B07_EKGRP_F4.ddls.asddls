// ============================================================
// 변경이력
// 2026-09-01  최초 작성 (T024 기반, 전체 필드 노출) — devlog: ../../../devlog/rap-dev/2026-09-01.md
// 2026-09-02  Ldest(출력장치) 필드 제거 — 도메인에 걸린 Conversion Exit SPDEV를 RAP V4 OData가
//             지원하지 않아 서비스 내부 에러 발생. sizeCategory(#XS) 드롭다운 제한도 제거,
//             Ekgrp/Eknam에 검색조건 어노테이션 추가 — devlog: ../../../devlog/rap-dev/2026-09-02.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매그룹 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
// @ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_B07_EKGRP_F4
  as select from t024
{
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 10 }]
  key ekgrp      as Ekgrp,
      @Search.defaultSearchElement: true
      @UI.selectionField: [{ position: 20 }]
      eknam      as Eknam,
      ektel      as Ektel,
      telfx      as Telfx,
      tel_number as TelNumber,
      tel_extens as TelExtens,
      smtp_addr  as SmtpAddr
}
