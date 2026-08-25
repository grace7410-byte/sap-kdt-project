# [00] 공통 – 자재타입 등 Search Help

관련 오브젝트 카탈로그: [`00_common-searchhelp`](../reference/00_common-searchhelp.md)

## 1) 최초 설계

FS 문서(00_공통_자재타입_SearchHelp_FS)를 정독하기 전, 서치헬프의 종류가 많다는 점만 인지한 상태에서 우선 자재타입(ZI_B07_MTART_F4)부터 SAP 표준 CDS `I_MaterialType`을 그대로 select하여 텍스트 없이 타입 코드만 노출하는 형태로 최초 구현하였다. 또한 플랜트 서치헬프는 표준 CDS `I_Plant`의 존재를 인지하지 못한 채, T001W와 T001K를 직접 조인하여 회사코드(K200)로 필터링하는 커스텀 뷰로 구현하였다.

- (DDL) [`ZI_B07_MTART_F4`](../reference/00_common-searchhelp.md) · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_MTART_F4.ddls.asddls)

```abap
define view entity ZI_B07_MTART_F4 as select from I_MaterialType
{
    key MaterialType,
    /* Associations */
    _Text[1: Language = $session.system_language].MaterialTypeName
}
```

## 2) FS 확인 및 비교/분석

- **자재타입:** FS 1.2 목적에는 "사용자가 회사에서 사용하는 자재타입만 선택할 수 있게 구현"하되 콤보박스(Combo Box) 형태로 사용성을 높이라는 요건이 있었다. 단순 코드값만 노출할 경우 사용자가 의미를 알기 어려워, 텍스트를 함께 노출하고 `@ObjectModel.resultSet.sizeCategory: #XS`로 드롭다운화하는 것이 FS 취지에 부합하다고 판단하였다.
- **플랜트:** FS 4.1은 "플랜트는 특정 Company Code(K200)에 관련된 정보만 검색"하도록 명시하고 있었는데, 커스텀 조인 방식은 회사코드 필터링은 가능했으나 표준 뷰 대비 유지보수성이 떨어지는 구조였다. 표준 CDS `I_Plant`를 활용하면 동일 요건을 더 안정적으로 만족할 수 있다고 판단하여 전환을 검토하였다.
- **언어:** FS 4.3(언어)은 단순 참고용 언어코드 목록을 요구하는 것으로 보였으나, 실제 구현 중 `ZTB07MARA_T`의 SPRAS(내부 언어키 '3','E' 등)와 T002T(ISO 코드 텍스트 테이블)를 잘못 조인하면 동일 내부 키에 여러 언어가 뒤섞여 나오는 문제를 발견하였다. 이는 FS가 요구하는 "전국 지점 및 해외 연계 시 다국어 자재명 제공"이라는 목적에 위배되는 오류였으므로, 언어 코드 자체를 관리하는 표준 테이블(T002)을 매개로 삼아 T002 → T002T로 2단 조인하도록 구조를 바꾸는 것이 타당하다고 분석하였다.

## 3) 추가된 서치헬프 내역

- **[`zi_b07_bukrs_f4`](../reference/00_common-searchhelp.md) (회사코드, 신규)** · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_BUKRS_F4.ddls.asddls) — FS에 명시되지 않았으나 FI/벤더 공통 요건으로 판단하여 추가. `I_CompanyCode` 기반, 한국(KR) 법인 + 예외 회사코드 필터
- **[`zi_b07_waers_f4`](../reference/00_common-searchhelp.md) (통화, 신규)** · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_WAERS_F4.ddls.asddls) — 자재 FS에서 "예) 통화 단위"로 명시된 예시를 실제 구현. `I_CurrencyStdVH` + `_Text` Association
- **[`zi_b07_mitkz_f4`](../reference/00_common-searchhelp.md) (조정계정 유형, 신규)** · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_MITKZ_F4.ddls.asddls) — FI FS 진행중 필요를 느껴 구현. 최초에는 `I_Domain*` 사용을 검토하였으나, FS가 요구하는 의미(조정계정 유형 텍스트)에 더 부합하는 표준 뷰 `I_Reconciliationaccttypetext`로 최종 결정
- **[`zi_b07_spart_f4`](../reference/00_common-searchhelp.md) (제품군, 신규)** · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_SPART_F4.ddls.asddls) — FS에 명시되지 않았으나, 자재타입별 제품군 관리 필요성을 판단하여 `zeb07spart`/`zdb07spart` 신규 생성 후 도입. `I_DomainFixedValueText`(도메인 `ZDB07SPART`) 기반, 값이 4개뿐이라 `#XS` 드롭다운화, `@UI.selectionField.position`·`@EndUserText.label`·alias 규칙 일괄 적용
- **기타:** 이 외 보고서 요구사항([00] 기준)에 맞는 서치헬프 11개 구성
  - MTART(자재타입) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_MTART_F4.ddls.asddls), WERKS(플랜트) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_WERKS_F4.ddls.asddls), LGORT(저장위치) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_LGORT_F4.ddls.asddls), BKLAS(평가클래스) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_BKLAS_F4.ddls.asddls), MEINS(단위) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_MEINS_F4.ddls.asddls), SPRAS(언어) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_SPRAS_F4.ddls.asddls), GLACT(계정타입) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_GLACT_F4.ddls.asddls), KTOSL(회계결정코드) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_KTOSL_F4.ddls.asddls), SAKNR(회계계정) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_SAKNR_F4.ddls.asddls), FDGRV(공급업체분류) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_FDGRV_F4.ddls.asddls), MATNR(자재) [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_MATNR_F4.ddls.asddls) 구현 완료 (`ZI_B07_<해당필드명>_F4`)

## 4) 로직(검증/제어) 추가 및 기타

### 4.1 로직(검증/제어)

저장위치 서치헬프에 additionalBinding을 적용하여, FS가 요구한 "플랜트에 포함된 저장위치만 검색"을 Value Help 레벨에서 강제하도록 구성하였다. (추후 2.3.2 자재 Behavior와 연동됨)

- (DDL) [`ZC_B07_MARA`](../reference/01_material-mgmt.md) · [코드 보기](../src/01_material-mgmt/cds/ZC_B07_MARA.ddls.asddls)

```abap
@Consumption.valueHelpDefinition: [{
    entity: { name: 'ZI_B07_LGORT_F4', element: 'StorageLocation' },
    additionalBinding: [
        { localElement: 'Werks', element: 'Plant', usage: #FILTER }
    ]
}]
Lgort,
LgortText,
```

### 4.2 기타 사항

CDS View 작성 시 `@UI.selectionField.position`, `@EndUserText.label`, `as <alias>`를 반드시 명시하는 것을 나만의 개발 규칙으로 정립하여, 이후 모든 `I_Domain*` 기반 서치헬프에 일관되게 적용하였다.
(표준 도메인·데이터엘리먼트를 그대로 쓰는 필드와 직접 만든 도메인을 쓰는 필드가 섞여 있다 보니 라벨 텍스트가 보고서 요구사항과 어긋나는 경우가 종종 있었는데, `@EndUserText.label`과 `as <alias>`를 기본 원칙으로 삼으면서 이 문제를 해결하였다.)

남은 서치헬프(공급업체 코드 4.9)는 05 개발과 병행 구현 → 이후 03에도 반영
