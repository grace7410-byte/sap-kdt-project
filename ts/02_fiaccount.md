# [02] FI 계정 관리

관련 오브젝트 카탈로그: [`02_fi-account`](../reference/02_fi-account.md)

**구현 진행 상황**
1. ListPage 화면 – 완성도 100%
2. Object Page 화면 – 완성도 100%

## 1) 최초 설계

FI 계정 마스터는 설계 초기 단계부터 별도의 회사코드 마스터 테이블을 두지 않고, 회사코드(Bukrs)를 Fixed Value(FV)로 구성하여 단일 회사코드만 사용하는 방향으로 설계하였다. 계정 텍스트도 별도 테이블 없이 ZTB07SKA1 한 테이블에 계정코드(Saknr)와 계정명(Stext)을 함께 두는 구조였다. 또한 조정계정 구분(Mitkz) 필드를 두어, 공급업체 관련 조정계정 구분값이 입력된 계정은 해당 공급업체에 대한 대금 지급 시에만 사용하도록 관리하려는 목적을 가지고 설계에 반영하였다. 삭제 플래그(Xloev)는 "마스터성 테이블에는 모두 삭제 플래그를 둔다"는 원칙에 따라 포함하였으며, 관리 필드는 로컬 변경시각까지 포함한 5종으로 구성하였다.

## 2) FS 확인 및 비교/분석

FS(02.FI계정관리_FS) 2.1~2.2를 확인한 결과, 팀에서 설계한 내용과 FS가 요구하는 구조가 큰 틀에서는 비슷하였으나 두 가지 차이가 있었다.

- **Text Table 분리:** FS는 `ZTB07SKA1`(Root)과는 별도로 `ZTB07SKA1_T`(UUID + 언어키(Spras)를 PK로 하는 Composition Child) 구조를 요구하고 있었다. 텍스트 테이블을 분리하여 다국어 계정명을 관리하도록 변경하였다.
- **관리 필드 축소:** FI계정관리는 OData V2 기반이며 Draft를 지원하지 않는다(Draft 지원: No). 01.자재관리(V4, Draft O)와 달리 로컬 변경시각(loc_changed_at) 필드가 불필요하다고 판단하여 제외하였다.

- *타임스탬프 Structure (`zsb07timestamp_v2`)*

```abap
@EndUserText.label : 'Time Stamp'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
define structure zsb07timestamp_v2 {
  created_by  : syuname;
  creation_at : timestampl;
  changed_by  : syuname;
  changed_at  : timestampl;
}
```

- *FI 계정 Text Interface Entity* ([`ZI_B07_SKA1TEXT`](../reference/02_fi-account.md) · [코드 보기](../src/02_fi-account/cds/ZI_B07_SKA1TEXT.ddls.asddls))

```abap
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FI 계정 Text Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_B07_SKA1TEXT as select from ztb07ska1_t
association to parent ZR_B07_SKA1 as _Ska1
  on $projection.SakUuid = _Ska1.SakUuid
{
  key sak_uuid as SakUuid,
  key spras as Spras,
  txt20 as Saktx,
  _Ska1 // Make association public
}
```

## 3) TS 수정·보완 내역

### 3.3.1. 테이블 필드 구성 사유

테이블: [`ZTB07SKA1`](../reference/02_fi-account.md) · [코드 보기](../src/02_fi-account/tables/ZTB07SKA1.tabl.asddls), [`ZTB07SKA1_T`](../reference/02_fi-account.md) · [코드 보기](../src/02_fi-account/tables/ZTB07SKA1_T.tabl.asddls)

- **회사코드 (Bukrs):** FS 2.1 최소 필드에는 없으나 실무 필요성으로 1차 설계부터 유지
- **조정계정 구분 (Mitkz):** 표준 도메인 매핑 위해 `I_Reconciliationaccttypetext` 사용
- **계정통화 (Waers) / 삭제 플래그 (Xloev):** 마스터성 테이블 공통 원칙에 따라 유지

### 3.3.2. 텍스트 Association 구성

Root BO: [`ZR_B07_SKA1`](../reference/02_fi-account.md) · [코드 보기](../src/02_fi-account/cds/ZR_B07_SKA1.ddls.asddls)

- **회사코드 (Bukrs) - `I_CompanyCode`:** 계정타입(Glact)에 대한 `_TypeText`(`I_GLAccountTypeText`) Association 추가
- **계정통화 (Waers) - `ZI_B07_WAERS_F4`:** 통화 텍스트 연동 · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_WAERS_F4.ddls.asddls)
- **조정계정 구분 (Mitkz) - `I_Reconciliationaccttypetext`:** 조정계정 유형 텍스트 연동, 검색 시 `ZI_B07_MITKZ_F4` 활용 · [코드 보기](../src/00_common-searchhelp/cds/ZI_B07_MITKZ_F4.ddls.asddls)
