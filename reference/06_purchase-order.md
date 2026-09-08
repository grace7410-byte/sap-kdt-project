# 구매오더관리 오브젝트 카탈로그

FS 문서: `06. 구매오더_FS`. 동일 FS를 기준으로 **Classic ABAP 이관**과 **RAP 신규 구축**이 서로 완전히 분리된 프로그램/오브젝트로 병행 진행 중.

## Classic ABAP (SAPMZB07EKKO)

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Table | `ZTB07EKKO` | - | 구매오더 헤더 (UUID PK, 구매오더번호/공급업체/회사코드/구매조직/구매그룹/문서유형/생성일/통화/결제조건/인코텀즈/조건레코드/참조구매오더번호 등) | [`ZTB07EKKO.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/tables/ZTB07EKKO.tabl.asddls) |
| Table | `ZTB07EKPO` | - | 구매오더 아이템 (UUID+순번 PK, 자재/구매정보레코드/플랜트/저장위치/수량/가격/세금/납품일정/계정지정 등) | [`ZTB07EKPO.tabl.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/tables/ZTB07EKPO.tabl.asddls) |
| Program | `SAPMZB07EKKO` | - | Module Pool 메인 프로그램. AS-IS(1기 `SAPMZB1MM0004`) 화면 구조 계승, 신규 테이블 기준 재작성. RAP 전환이 아닌 Classic ABAP 이관이며 아래 RAP 오브젝트와 완전히 별개 | [`SAPMZB07EKKO.prog.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/prog/SAPMZB07EKKO.prog.abap) |
| Include (TOP) | `ZB07EKKO_TOP` | - | 전역 데이터 선언(헤더/아이템/벤더/옵션가/BOM차트/ALV·컨테이너 등) | [`ZB07EKKO_TOP.prog.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/prog/ZB07EKKO_TOP.prog.abap) |
| Include (PBO) | `ZB07EKKO_O01` | - | 화면 초기화 모듈(100/101/103/104번 ALV·차트, TABSTRIP 서브스크린 결정) | [`ZB07EKKO_O01.prog.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/prog/ZB07EKKO_O01.prog.abap) |
| Include (PAI) | `ZB07EKKO_I01` | - | 사용자 명령 처리(벤더 선택/저장/삭제 등 100번 메인 흐름) | [`ZB07EKKO_I01.prog.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/prog/ZB07EKKO_I01.prog.abap) |
| Include (FORM) | `ZB07EKKO_F01` | - | 공통 서브루틴(ALV 유틸, 벤더/옵션가/BOM 차트 조회, 도메인·CDS 텍스트 조회 등) | [`ZB07EKKO_F01.prog.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/prog/ZB07EKKO_F01.prog.abap) |
| Include (CLASS) | `ZB07EKKO_C01` | - | `lcl_event_handler` — 101번 벤더 ALV 핫스팟 클릭 시 130번 팝업 호출 및 취소 시 헤더 텍스트 원복 | [`ZB07EKKO_C01.prog.abap`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/prog/ZB07EKKO_C01.prog.abap) |

### 화면 구성
100(헤더+아이템) · 101(벤더 리스트, 핫스팟→130) · 102(벤더 상세, 100의 서브스크린) · 103(옵션가 ALV + 기준완제품 1개 BOM 차트, TAB1) · 104(3종 비교, TAB2, 미착수) · 130(벤더 상세 팝업) · 200/300(변경/조회, 유지 여부 결정 대기) · 9000(빈 화면 폴백). 120(안내 팝업)은 스킵 확정.

### 진행 상태 메모 (2026-09-07 기준)
- 100/101/102/130번 화면 및 벤더 조회·헤더 반영 로직 동작 확인. 130 취소 시에도 헤더 자신의 EKORG/EKGRP 텍스트로 정상 복원되도록 처리.
- 103번(옵션가 ALV + BOM 차트) 구현 완료 — 벤더 미선택 시에도 전체 옵션가 목록이 표시되도록 설계(벤더 필터 옵셔널).
- 104번(3종 비교)은 아직 미착수.
- 200/300(변경/조회) 화면 유지 여부 결정 대기 중.
- 저장/삭제(SAVE/DELETE_ALL/DELETE_ITEM 등) 로직은 대부분 주석 처리된 골격 상태 — 미착수.

## RAP (ZR_B07_EKKO 등)

| 구분 | 오브젝트명 | 베이스 | 설명 | 코드 |
| --- | --- | --- | --- | --- |
| Interface | `ZI_B07_EKKO` | ZTB07EKKO | 헤더 Interface View, 공급업체(`_Lfa1`) Association으로 Lifnr/Name1 노출 | [`ZI_B07_EKKO.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/cds/ZI_B07_EKKO.ddls.asddls) |
| Interface | `ZI_B07_EKPO` | ZTB07EKPO | 아이템 Interface View, `association to parent ZR_B07_EKKO` + 자재(`_Mara`)/구매정보레코드(`_Eine`)/플랜트(`_Werks`)/저장위치(`_Lgort`) Association | [`ZI_B07_EKPO.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/cds/ZI_B07_EKPO.ddls.asddls) |
| Root BO | `ZR_B07_EKKO` | ZI_B07_EKKO | RAP Root Entity, Composition(`_Ekpo`) + 문서유형명(`_BsartText`)/구매조직명(`_EkorgText`)/구매그룹명(`_EkgrpText`)/회사코드명(`_BukrsText`)/통화명(`_WaersText`) Association. 구매그룹(Ekgrp) Value Help는 표준 서치헬프 충돌로 Root에서 정의(05번과 동일 이슈) | [`ZR_B07_EKKO.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/cds/ZR_B07_EKKO.ddls.asddls) |
| Projection | `ZC_B07_EKKO` | ZR_B07_EKKO | OData V4 노출용 Root. 검색조건 3개(구매오더일/공급업체/구매오더번호), Sort(구매오더일desc→공급업체→구매오더번호), Value Help 4종(공급업체/회사코드/구매조직/통화) 연결, `_Ekpo`를 `ZC_B07_EKPO`로 redirect | [`ZC_B07_EKKO.ddls.asddls`](https://github.com/grace7410-byte/sap-kdt-project/blob/main/src/06_purchase-order/cds/ZC_B07_EKKO.ddls.asddls) |
| Projection | `ZC_B07_EKPO` | ZI_B07_EKPO | 아이템 Projection — **아직 미생성** (다음 작업 예정) | - |

### 진행 상태 메모 (2026-09-07 기준, WIP)
- Interface View 2종(헤더/아이템) + Root View(헤더) + Projection View(헤더)까지 완료.
- 아이템 Projection(`ZC_B07_EKPO`)은 아직 생성 전 — 이게 있어야 `ZC_B07_EKKO`의 `_Ekpo` redirect가 실제로 액티브됨.
- Behavior Definition/Implementation, Service Definition/Binding, Metadata Extension은 전부 미착수.
- `ZR_B07_EKKO`의 필드/연관 목록은 devlog에 나뉘어 제시된 두 코드 조각을 병합 재구성한 것 — 실제 코드와 다르면 확인 필요(위 표 코드 링크 참고).

관련 Search Help: [`ZI_B07_EKORG_F4`](./00_common-searchhelp.md), [`ZI_B07_EKGRP_F4`](./00_common-searchhelp.md), [`ZI_B07_BUKRS_F4`](./00_common-searchhelp.md), [`ZI_B07_WAERS_F4`](./00_common-searchhelp.md), [`ZI_B07_LIFNR_F4`](./00_common-searchhelp.md), [`ZI_B07_WERKS_F4`](./00_common-searchhelp.md), [`ZI_B07_LGORT_F4`](./00_common-searchhelp.md) · 공급업체는 [벤더관리](./03_vendor.md), 구매정보레코드는 [구매정보레코드관리](./05_purchase-info.md) 참조
