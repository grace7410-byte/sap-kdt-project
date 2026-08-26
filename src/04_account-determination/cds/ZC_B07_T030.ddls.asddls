// ============================================================
// 변경이력
// 2026-08-20  최초 작성, Root BO View(ZR_B07_T030) 신설에 맞춤 — devlog: ../../../devlog/rap-dev/2026-08-20.md
// 2026-08-25  전기키 valueHelpDefinition에 additionalBinding(usage: #RESULT) 추가해 F4 선택 시 Shkzg 자동 채움, Shkzg는 readOnly로 전환 — devlog: ../../../devlog/rap-dev/2026-08-25.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '회계계정결정 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
/* 문제 [3.4] 2) Sort */
@UI.presentationVariant: [{ sortOrder: [
    { by: 'Bwart', direction: #ASC },
    { by: 'Seqnr', direction: #ASC }
 ]}]
define root view entity ZC_B07_T030
  provider contract transactional_query
  as projection on ZR_B07_T030
{
  key MapUuid,

      /********* 이동유형 ************/
      // 서치바
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      // 검색조건(1) 이동유형
      @UI.selectionField: [{  position: 10  }]
      // 서치헬프
      @Consumption.filter: { multipleSelections: false, selectionType: #SINGLE }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_BWART_F4', element: 'Bwart' } }]
      // 텍스트
      @ObjectModel.text.element: ['Bwatx'] // 텍스트 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
      Bwart,
      Bwatx,
      Seqnr,

      /********* 트랜잭션키 ************/
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      // 검색조건(2) 회계결정코드
      @UI.selectionField: [{  position: 20  }]
      // 서치헬프
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_KTOSL_F4', element: 'Ktosl' } }]
      // 텍스트
      @ObjectModel.text.element: ['Ktotx'] // 계정코드 코드명 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
      Ktosl,
      Ktotx,

      /*********  평가클래스  ************/
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      // 검색조건(3) 자재계정
      @UI.selectionField: [{  position: 30  }]
      // 서치헬프
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_BKLAS_F4', element: 'Bklas' } }]
      // 텍스트
      @ObjectModel.text.element: ['Bkbez'] // 계정코드 코드명 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
      Bklas,
      Bkbez,

      /********* 회계계정 ************/
      // 서치헬프
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_SAKNR_F4', element: 'Saknr' } }]
      // 텍스트
      @ObjectModel.text.element: ['Saktx'] // FI계정 계정명 함께 띄우기
      @UI.textArrangement: #TEXT_LAST
      Saknr,
      Saktx,

      /********* 계정타입 ************/
      // 서치헬프
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_GLACT_F4', element: 'DomainValue' } }]
      // 텍스트
      @ObjectModel.text.element: ['Glatx'] // 계정타입 계정타입명 함께 띄우기
      @UI.textArrangement: #TEXT_FIRST
      Glact,
      Glatx,

      /*********  전기키  ************/
      // 서치헬프 (additionalBinding: F4에서 행 선택 시 Shkzg 자동 채움)
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZI_B07_BSCHL_F4', element: 'Bschl' },
        additionalBinding: [
          { element: 'ShkzgOut', localElement: 'Shkzg', usage: #RESULT }
        ]
      }]
      // 텍스트
      @ObjectModel.text.element: ['Bsctx'] //함께 띄우기
      @UI.textArrangement: #TEXT_FIRST
      Bschl,
      Bsctx,

      /********* 차/대변 (전기키 선택 시 자동 채워지므로 readOnly) ************/
      @UI.readOnly: true
      Shkzg,
      Shktx,

      CreatedBy,
      CreationAt,
      ChangedBy,
      ChangedAt
}
