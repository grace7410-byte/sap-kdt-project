# MM 서티(C_TS452) 실습 가이드 — Fiori 기준 조직구조·자재·벤더·구매

## 목적 / 상황
서티 시험은 Fiori 기준으로 진행되므로, 모든 실습도 Fiori 기준으로 진행한다. 연습(Hands-on Practice) 서버는 실제 시험 서버와 달리 조직구조(컴퍼니코드/플랜트/구매조직) 생성이 시스템 단에서 막혀 있는 경우가 많다. 이 문서는 그 제약을 우회해 실습하는 방법과, 실제 시험에서 그대로 적용할 수 있는 절차를 함께 정리한다.

> ⚠️ 서티 시험 때는 컴퍼니코드/플랜트를 새로 생성할 수 있지만, 연습 서버에서는 시스템 단에서 막혀 있다.

## 절차

### 0) 사전 준비 — 권한 확인
- 실습 전에 관련 User Role이 모두 부여되어 있어야 함 (Fiori Launchpad)
- **[App] Maintain Business Users**
  - 다양한 MM 관련 탭이 존재한다면 해당 카테고리에 대한 권한이 부여된 것
  - Role을 추가했는데도 안 뜨면 새로고침
  - Hands-on Practice 서버에서는 이 앱 자체가 없음 (정해진 권한만 사용 가능)
- IMG 접근: **Implementation Activity** 앱으로 SPRO 티코드의 IMG 세팅에 접근 가능

### 1) 조직구조 생성 — GUI 병행이 가능한 경우 (권장 경로)
Fiori 서버와 SAP GUI를 함께 쓸 수 있다면, 조직구조(플랜트/구매조직 등)를 SAP GUI(SPRO)에서 생성할 수 있다.

- Tcode `spro` → **SAP Reference IMG**
- 기본 조직구조(컴퍼니코드/플랜트/구매조직)까지만 GUI로 진행
- 추가 내용이 필요하면 페이지에서 `Ctrl+F` → "플랜트 생성"으로 검색해서 따라가기

**(GUI) 플랜트 생성 + 저장위치 생성**
- 경로: `SPRO → Enterprise Structure → Definition → Logistics General → Define Plant`
- `CT00` 또는 `1010`을 **Copy As…** 하여 신규 플랜트 `Y0##` 생성
- 저장위치(Storage Location) `1010`의 `101A`, `101C`를 신규 플랜트에 할당
- 주소 정보: 국가 Germany / 이름 `CERT Y0##` / 우편번호 69226 / 도시 Nussloch / 건물번호 `Y0##` (Street명은 무관)

**저장위치 생성**
- 경로: `SPRO → Enterprise Structure → Definition → Logistics General → Materials Management → Maintain storage location`
- 진입 시 플랜트(`Y0##`)를 먼저 입력하는 팝업이 뜸
- **New Entries**로 추가:
  - `101A` - Std. storage
  - `101C` - Raw mat. stoloc.

**(GUI) 구매조직 생성 + 플랜트 매핑**
- 경로: `SPRO → Enterprise Structure → Definition → Logistics General → Materials Management → Maintain purchasing organization`
- **New Entries**로 신규 플랜트 `Y0##` 전용 Plant-specific Purchasing Organization `P0##` (Description: `CERT P0##`) 생성
- 이어서 `SPRO → Enterprise Structure → Assignment → Materials Management → Assign standard purchasing organization to plant` 에서 `Y0##` ↔ `P0##` 1:1 매핑 저장
  - Definition 다음이 Assignment라는 순서를 기억해둘 것
  - "그냥 구매조직 연결"이 아니라 **Standard 구매조직 연결** 프로그램으로 들어와야 좌측 플랜트에 1:1 매핑 가능

**(GUI) 플랜트와 컴퍼니코드 연결**
- 경로: `SPRO → Enterprise Structure → Assignment → Logistics - General → Assign plant to company code`
- **New Entries** → 회사코드(`1010`), 플랜트(`Y0##`) 순서로 입력 후 저장

### 2) 조직구조 생성 — Fiori 단독인 경우 (연습 서버 제약 참고)
> cf. 컴퍼니코드/플랜트/저장위치/구매조직/구매그룹을 Fiori로 생성하려는 경우 — **연습 서버에서는 대부분 생성 불가능.** 실제 시험 서버에서는 아래 경로가 유효하다.

- **컴퍼니코드 생성**: IMG의 `General Settings - Organizational Structure - Create Company`. 새로 만들기보다 기존 `1010`을 Edit 모드에서 행 선택 후 Copy 하는 방식 권장.
- **플랜트 생성**: `General Settings - Organizational Structure - Logistics - EMC General Plant - Define Plant`. Edit → **Copy As…**가 활성화되어 있어야 복사 가능. (연습 서버는 불가능해서 `1010`으로 대체 진행)
- **저장위치 생성**: `Logistics, Transportation, and Warehousing - Inventory Management - Define your Storage Locations and related settings - Maintain Storage Location`. Edit → 행 선택 → Copy As…. (연습 서버에서는 Copy As… 버튼 자체가 없어 `101A`, `101C`를 그대로 사용)
- **구매조직 생성 + 플랜트 매핑**: `Procurement - Procurement Basic Setting - Maintain purchasing organization`에서 생성 후, `Procurement - Procurement Basic Setting - Assign standard purchasing organization to plant`에서 앞서 만든 플랜트 `Y0##`과 연결 확인 ⭐
- **구매그룹 생성**: 실습에서는 생략하고 제공된 `Z##` 구매그룹 사용 (원래는 이 경로에서 생성)

**(GUI) MRP Controller 생성**
- T-Code `OMD0` (MRP Controller)
- `1010` 플랜트의 `0##`을 선택 후 **Copy As…** → 플랜트를 `Y0##`로 바꾸고 저장

> 여기부터는 다시 Fiori로만 접근 (조직구조 완료)

### 3) 자재 마스터 생성 (Manage Product Master Data)
자재코드 `T-RC##` 생성 (이동평균가 평가, 저장위치 `101C`, 플랜트 `Y0##`)

기본값:
- Product Number: `T-RC##`
- Product Type: `ROH`
- Product Group: `00103`
- Description: `Battery GR##`

OK를 누르면 자재번호/영어이름/유형/그룹/단위가 할당된 것을 확인 가능. 이후 General Information 탭부터 순서대로 채운다.

1. **General Information - Basic Data**: Division `00`
2. **General Information - Descriptions**: DE `Batterie GR##` / EN `Battery GR##`
3. **Purchasing**: Purchasing Value Key `1`
4. **Plants** → Create
   - General Data: Plant `Y0##` (CERT Y0##)
   - Purchasing Group: `Z##` (자재별 구매관리는 플랜트마다 다르게 설정 가능)
   - Storage Locations → Create: SLoc `101C`, Storage Bin `GR##`
   - 여기까지 하면 필수값인 MRP 설정 누락 오류가 뜸
   - **MRP Data**: MRP Type `PD` (표준 자재 소요량 계획) / MRP Controller `0##` (001 아님, 서치헬프로 확인 — 만들어둔 값이 안 보이면 위 MRP Controller 생성 절차 참고) / Availability Check `02` (Individual Requirements, 필수값)
   - **MRP Data - Lot-Size Data**: Lot Sizing Procedure `EX` (필요한 수량만큼 로트 생성). ATP를 `02`(individual)로 설정했으므로 Dependent Requirements Type도 `Individual requirements only`로 맞춰야 오류가 안 남
     - Controller/Lot size는 플랜트 저장 시점엔 문제없어도, 자재 최종 저장 시 누락되면 오류가 난다
5. **Valuation Area** → Create
   - Valuation Area `Y0##` (보통 플랜트 코드와 1:1)
   - Valuation Class `3000`
   - "Valuation Area invalid" 오류 시: `SPRO → Enterprise Structure → Definition → Logistics - General → Define valuation level`에서 Valuation Area–Plant 1:1 매핑 확인, 그리고 `SPRO → Enterprise Structure → Assignment → Logistics - General → Assign plant to company code`에서 회사코드(`1010`)-플랜트(`Y0##`) 연결 확인 ⭐
   - 이동평균가는 S/4HANA 표준 설정에서 자재유형 `ROH`(원자재) 기준 `Price Control = V (Moving Average Price)`가 기본값으로 자동 고정됨

저장.

### 4) BP 마스터 - 공급업체 생성 (Manage Business Partner)
Create → Organization. 구매조직 `P0##`에서 사용할 공급업체 `SP-C##` 생성 (독일, 언어 DE, 입고기반 송장검증 체크, 리드타임 15일)

1. **General Data**: Business Partner `SP-C##` / Grouping `BPAB` / BP Role `FLVN00` (FI Supplier) / Name 1 `SP-C##`
2. **Standard Address**: Street `Goethestrasse` / House Number `C##` / City `Nussloch` / Postal Code `69226` / Country `DE` / Region `08` / Language `DE`
3. **Basic Data - General Information**: Search Term 1 `CTS452-##`
4. **Roles → FLVN00** 확인 후 `>` 클릭 (해당 Role 내부 설정 화면으로 진입)
   - **Company Codes** 탭 → Create
     - General Data: Company Code `1010`
     - Finance: Recon. Account `21100000` / Payment Terms `0001`
   - 저장하고 나오기
5. **Roles → Create → FLVN01** (Purchasing Supplier) 생성 후 하단 **Apply**
   - `FLVN00`: Company Code `1010` 관련 회계 데이터 처리용
   - `FLVN01`: Purchasing Org `P0##` 관련 구매 데이터 처리용
   - FLVN01 확인 후 `>` 클릭 → **Purchasing Organizations** 탭 → Create
     - General Data: Purchasing Organization `P0##` / Purchasing Group `Z##` (그룹 번호 관련 항목 사용 권장) / Planned Delivery Time `15`
     - Purchasing Organizations: Conditions - Order Currency `EUR` / Payment Terms `0001` 추가
       - 참고: Company Code(회계)의 Payment Terms는 FI 송장 처리(MIRO, FB60)·대금 지급 실행에, Purchasing Org(구매)의 Payment Terms는 구매발주(PO) 생성 시 자동으로 끌려오는 값으로 역할이 다르다.
     - GR-Based Invoice Verification: ✅ 체크 (Invoice verification should be based on the Goods Receipt)
     - Incoterms: `FH`
   - Apply → Apply → Create → 생성 완료

### 5) 구매정보레코드(PIR) 생성
> ⚠️ **Manage Purchasing Info Record** 앱(신버전)에서는 기본 정보·딜리버리 조건 입력 후 '가격 조건' 세부 생성이 안 되는 문제가 있었음. 처음부터 **Create Purchasing Info Records**(`ME11`, 구버전) 앱에서 시작하는 것을 권장.

구매조직 `P0##` / 납품일수 10일 / 표준주문수량 100 pc / 단가 조건: 기존 기본 500€(10개 초과 시 450€), 내년 시작 단가 기본 520€(10개 초과 시 470€)

1. **Header**: Info Record Category `Standard` / Purchasing Organization `P0##` (Plant는 지정하지 않거나 기본값 유지) / Supplier `SP-C##` / Material `T-RC##` / Purchasing Group `Z##`
   - 참고: 구매조직+공급업체를 먼저 채운 뒤 자재를 넣으면 자재그룹·플랜트가 자동 매핑되지만, 플랜트 단위가 아닌 구매조직 단위 PIR이라 플랜트는 삭제될 수 있음. 자재 없이 자재그룹만 지정해서 넘어가는 것은 서비스 등 비정형 품목용이므로, 시험에서는 반드시 자재를 입력해서 생성할 것.
   - 실제로는 플랜트를 입력하지 않으면 오류가 나서, 앞서 만든 `Y0##`을 입력한 뒤 생성해야 했음.
2. **Delivery and Quantity**: BP 단에서 설정한 15일이 기본 할당되어 있음 → `10` Days로 변경. Standard Quantity `100` PC (미입력 시 오류 나는 필수값). Goods-Receipt-Based Invoice Verification은 자동으로 체크되어 있음.
3. **Conditions** → Create
   - 현재 유효기간: Valid From (오늘 날짜 유지) / Valid To `31.12.2026` / Amount `500` (EUR) → Apply
   - 신버전 앱에서 가격 조건 생성이 막히면, 지금까지 내역 저장 후 **인포레코드 번호를 기억**해두고 `ME12`(Change Purchasing Info Records)로 이동해 이어서 진행
   - Conditions 화면에서 첫 번째 행 선택 → 하단 **Choose** → 세부 가격 조건 화면 → 상단 **Scales** 버튼으로 확장
     - Scale Type: `From` (기준 수량 이상)
     - Scale Quantity: `1` PC → `500.00` EUR, `11` PC → `450.00` EUR
   - **New Validity Periods**: Valid From `01.01.2027` / Valid To `31.12.9999` → 입력 후 `PR00` 행 클릭 → 다시 Scales
     - `1` PC → `520.00` EUR, `11` PC → `470.00` EUR
   - 저장하면 끝

### 6) 구매요청(PR) 생성
SAP는 신버전 앱(Manage Purchase Requisitions) 사용을 권장하지만, "Source Determination" 체크박스를 해제하는 옵션은 클래식 GUI 앱에서만 가능하므로 **Create Purchase Requisitions**(`ME51N`) 사용.

- 재고용 구매 50개 (플랜트 `Y0##`) / 비용처리 구매: 엔지니어링 코스트센터 `T-ENG##` 목적 5개
- ⚠️ PR 작성 시작 전 Source Determination 옵션을 해제할 것

1. `ME51N` 진입, Source Determination 빈칸 유지 (공급업체 자동 결정 해제)
2. Item Overview에서:
   - A (Account Assignment Category): 빈칸 / Material `T-RC##` / Quantity `50` / Plant `Y0##` → 엔터
   - 자동으로 자재 단위·납기일 등이 채워짐
   - 오류 "Account assignment mandatory for material T-RC##" 발생 시: SAP GUI에서 `OMS2` → `ROH`(해당 자재의 Material Type) 더블클릭 → 좌측 **Quantity/value Updating** → 플랜트(`Y0##`) 체크박스 둘 다 체크 (현재 Plant+Material Type 조합에 가치평가 재고 처리 가능하도록)
   - 오류 해결 후 자재를 한 번 지웠다 다시 추가하면 경고 아이콘만 남음
   - 두 번째 라인: A `K` (Cost center) / Material `T-RC##` / Quantity `5` / Plant `Y0##` → 하단 Account Assignment 탭에서 Cost Center `T-ENG##` 연결

### 진행 예정 (아직 진행 안 함, Task 3 후속 과정 예상)
7. 구매요청에 공급업체 지정 (Assign Source) — 작성된 PR을 조회하고, 앞서 생성한 구매정보레코드(`P0##`)를 공급업체(Source of Supply)로 지정
8. 유연한 승인 프로세스(Flexible Workflow) 설정 — App: `Manage Workflows for Purchase Orders` / 워크플로우 이름 `CERT##` / 조건: 금액 5,000€ 초과 & 구매조직 `P0##` / 승인자 `TS450-##` (수동 승인 지정)
9. 구매오더(Purchase Order) 생성 — 문서 유형 `ZNBF`, PR을 PO로 전환 (구매조직 `P0##`, 플랜트 `Y0##`)
10. 구매오더 승인 및 출력(Release & Output) — 구매조직 `P0##`의 PO를 승인 처리하고 출력 프로세스 진행
