# [03] 벤더관리

관련 오브젝트 카탈로그: [`03_vendor`](../reference/03_vendor.md)

**구현 진행 상황**
1. ListPage 화면 – 완성도 100%
2. Object Page 화면 – 완성도 100%

## 1) 최초 설계

Fiori "BP(Business Partner) 관리" 구조를 참고하여 BP 마스터(공통)-벤더 마스터-커스터머 마스터 3계층 구조로 설계를 채택함.

- **BP 통합 마스터:** 국가키, 도시, 주소, 사업자번호 등 순수 공통 기본정보 관리
- **공급업체 마스터:** BP 마스터 참조(FK), 공급업체 분류(A1: 국내지급 등), 구매조직(Ekorg), 구매그룹(Ekgrp), 조정계정(Akont) 반영
- **고객 마스터:** 영업조직(Vkorg), 유통채널(Vtweg), 제품군(Spart) 반영

## 2) FS 확인 및 비교/분석

FS(03.밴더관리_FS)는 공급업체(`ZTB07LFA1`) 단일 테이블 구성을 전제함.

- **테이블 구조 단순화:** BP-벤더-고객 3계층 구조 대신 FS 요건에 따라 공급업체·고객을 각각 독립된 단일 테이블로 단순화.
- **채번 로직 개선:** FS 4.2 분류별 넘버레인지 분리 요건 충족을 위해 `NUMBER_GET_NEXT` FM을 활용하되, 채번 결과 뒤 6자리를 추출하여 접두어 'V'를 코드 레벨에서 붙이는 방식(V+6자리)을 적용.
- **Association 확장:** Akont(조정계정) 필드에 `ZR_B07_SKA1` Association을 연결하여 계정명/계정타입까지 노출하도록 확장.

테이블: [`ZTB07LFA1`](../reference/03_vendor.md) · [코드 보기](../src/03_vendor/tables/ZTB07LFA1.tabl.asddls)

## 3) TS 수정·보완 내역

### 4.3.1. 테이블 필드 추가/수정

- **구매조직 (Ekorg) / 구매그룹 (Ekgrp):** 실무 필요성에 따라 유지
- **거래상태 (Loevm):** 단순 삭제 플래그가 아닌 실제 거래 종료(중지) 여부 관리 목적으로 반영

### 4.3.2. RAP 공급업체 코드(Lifnr) Determination 로직 추가

- **Method:** [`SetVendorNumber(Lifnr)`](../reference/03_vendor.md) · [코드 보기](../src/03_vendor/bimp/zbp_r_b07_lfa1.clas.abap)
- **사유:** 분류(Fdgrv)별로 V + 6자리 숫자(예: A1 분류 → V100001) 형태의 공급업체 번호를 채번. 예외 케이스(WHEN OTHERS)는 기본 레인지(01)로 폴백 처리.

### 4.3.3. RAP 조정계정(Akont) Validation 체크 로직 추가

- **Method:** [`CheckAccountExist(Akont)`](../reference/03_vendor.md) · [코드 보기](../src/03_vendor/bimp/zbp_r_b07_lfa1.clas.abap)
- **사유:** 입력된 Akont가 실제 `ZTB07SKA1`에 존재하는 계정인지 검증.

### 4.3.4. Association 구성

Root BO: [`ZR_B07_LFA1`](../reference/03_vendor.md) · [코드 보기](../src/03_vendor/cds/ZR_B07_LFA1.ddls.asddls)

- **조정계정 (Akont) & 계정 타입 (Glact) - `ZR_B07_SKA1`:** 조정계정 코드에 계정명(`Akontxt`)과 계정타입(`Glact`/`Glactxt`)까지 함께 끌어와 Object Page "계정 정보" Facet에서 노출하도록 MDE 확장.

> 공급업체 자체 서치헬프(`ZI_B07_LFA1_F4`)는 아직 src에 반영되지 않은 상태다(잔여 이슈 — [`07_remaining-issues.md`](./07_remaining-issues.md) 참고).
