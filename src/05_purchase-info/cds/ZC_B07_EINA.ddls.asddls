// ============================================================
// 변경이력
// 2026-08-27  최초 작성 (Redirect + 필드순서/Sort/검색조건 반영) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-30  구매정보내역(Irtxt) 필드 추가 — devlog: ../../../devlog/rap-dev/2026-08-30.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보레코드 헤더 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'Infnr' ]
/* 문제 [3.4] 2) Sort */
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
      // 서치바
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      Infnr,

      // 서치바
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
      Irtxt,

      CreatedBy,
      CreationAt,
      ChangedBy,
      ChangedAt,
      LocChangedAt,
      /* Associations */
      _Eine : redirected to composition child ZC_B07_EINE
}
