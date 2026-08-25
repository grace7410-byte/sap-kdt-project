// ============================================================
// 변경이력
// 2026-08-18  최초 작성 + 계정타입(Glact/Glactx) 필드 추가 반영 — devlog: ../../../devlog/rap-dev/2026-08-18.md
// ============================================================
// NOTE: 원문 그대로 옮김 — text.element가 'Glactxt'를 참조하는데 실제 필드명은 'Glactx'로 보임
//       (원본 노트의 표기 불일치 가능성, MDE 파일도 동일하게 'Glactxt'로 되어 있어 그대로 둠. 추후 확인 필요)
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '공급업체 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'Lifnr' ]
@UI.presentationVariant: [{ sortOrder: [
    { by: 'Fdgrv', direction: #ASC },
    { by: 'Lifnr', direction: #ASC }
 ]}]
define root view entity ZC_B07_LFA1
  provider contract transactional_query
  as projection on ZR_B07_LFA1
{
  key LifUuid,
      /********* 공급업체 분류 ************/
      // 검색조건(1) 공급업체 분류
      @UI.selectionField: [{  position: 10  }]
      // 텍스트
      @ObjectModel.text.element: ['Fdgxt'] // 공급업체분류 분류명 함께 띄우기
      @UI.textArrangement: #TEXT_FIRST
      Fdgrv,
      Fdgxt,
      /********* 공급업체 번호 ************/
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      // 검색조건(2) 공급업체 번호
      @UI.selectionField: [{  position: 20  }]
      // 텍스트
      @ObjectModel.text.element: ['Name1'] // 공급업체번호 번호명 함께 띄우기
      @UI.textArrangement: #TEXT_FIRST
      Lifnr,
      Name1,
      /*********   조정계정   ************/
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      // 텍스트
      @ObjectModel.text.element: ['Akontxt'] // 조정계정 계정명 함께 띄우기
      @UI.textArrangement: #TEXT_FIRST
      Akont,
      Akontxt,
      /*********   계정타입   ************/
      @ObjectModel.text.element: ['Glactxt']
      @UI.textArrangement: #TEXT_FIRST
      Glact,
      Glactx,
      /*********   거래종료   ************/
      Loevm,

      Ekorg,
      Ekgrp,

      Waers,
      @Semantics.amount.currencyCode: 'Waers'
      Minbw,

      CreatedBy,
      CreationAt,
      ChangedBy,
      ChangedAt,
      LocChangedAt
}
