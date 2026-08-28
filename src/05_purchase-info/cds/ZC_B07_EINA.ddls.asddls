// ============================================================
// 변경이력
// 2026-08-27  최초 작성 (Redirect + 필드순서/Sort/검색조건 반영) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// ============================================================
// NOTE: 서치헬프(Value Help) 연결은 아직 보류 상태입니다(구매단위/공급업체/자재 - Object Page 작업 시 반영 예정).
//       Esotx(레코드유형명)는 Root(ZR_B07_EINA)에 아직 association이 없어, 활성화 시 오류가 날 수 있습니다.
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보레코드 헤더 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'Infnr' ]
@UI.presentationVariant: [{ sortOrder: [
    { by: 'Infnr', direction: #ASC },
    { by: 'Matnr', direction: #ASC },
    { by: 'Lifnr', direction: #ASC }
 ]}]
define root view entity ZC_B07_EINA
  provider contract transactional_query
  as projection on zr_b07_eina
{
      @UI.hidden: true
  key InfUuid,
      /********* 구매정보번호 ************/
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Infnr,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      // 텍스트
      @ObjectModel.text.element: ['Esotx']
      @UI.textArrangement: #TEXT_FIRST
      Esokz,
      Esotx,
      LifUuid,
      // 검색조건(1) 공급업체
      @UI.selectionField: [{  position: 10  }]
      // 텍스트
      @ObjectModel.text.element: ['Liftx']
      @UI.textArrangement: #TEXT_FIRST
      Lifnr,
      Liftx,
      MatUuid,
      // 검색조건(2) 자재코드
      @UI.selectionField: [{  position: 20  }]
      // 텍스트
      @ObjectModel.text.element: ['Maktx']
      @UI.textArrangement: #TEXT_FIRST
      Matnr,
      Maktx,
      Ekorg,
      Ekgrp,
      Meins,
      Loekz,
      CreatedBy,
      CreationAt,
      ChangedBy,
      ChangedAt,
      LocChangedAt,
      /* Associations */
      _Eine : redirected to composition child ZC_B07_EINE
}
