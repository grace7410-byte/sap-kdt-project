# FI 서티(C_TS4FI) 실습 가이드

**Practice**: Hands-on Practice for Basics of Customizing for Financial Accounting: GL, AP, AR in SAP S/4HANA (`SAP S/4HANA 2023`, `S4F12`)

- (연습 시) 시스템: `S4F12`
- (시험) 시스템: `TS4FI-##` / `TA##` (T41)

> 실습 절차·발견 사항은 원문 그대로 옮긴 것으로, 실제 시험 서버 값(계정번호, Company Code 등)은 응시 시점 화면 기준으로 재확인할 것.

## Task 3

### Create a New Document Type

> **배경 시나리오**
> Bike Company는 직원 차량의 통행료(Toll) 청구를 간소화하는 새 시스템을 도입하려 함. RTA(Road Transit Authority)의 인터페이스를 SAP 시스템에 연동해서 통행료 청구 데이터를 자동으로 업로드할 예정. RTA 청구 시스템의 원래 문서번호를 그대로 사용하면 대사(reconciliation)와 추적이 쉬워짐. 이를 위해 전용 Document Type을 만들고, RTA를 벤더로 등록해서 테스트까지 완료해야 함.

#### Step 1. Document Type 생성
경로: `SPRO → Financial Accounting → Financial Accounting Global Settings → Document → Document Types → Define Document Types`

| 필드 | 값 |
| --- | --- |
| Document type | `##` |
| Reverse Document Type | `AB` |
| Description | `Toll Fees ##` |

저장 후 Overview에서 확인.

#### Step 2. Number Range 생성 + Document Splitting 분류
경로: `… → Document → Document Number Ranges → Define Document Number Ranges`

Company Code `TA##` 입력. 기존 Interval에 A1~Z9 계열이 없으면 **A1**부터 신규 생성.

| 필드 | 값 |
| --- | --- |
| Number Range No. | `A1` |
| From No. | `FEES##0000` |
| To Number | `FEES##9999` |
| External | ✅ 체크 |

> 💡 **알게 된 점**: Year 필드를 다른 줄처럼 9999로 넣으면 안 됨. 지침에 "This numbering is modified **every year**"라고 명시돼 있어서, RTA 채번은 매년 리셋되는 규칙 → Year 필드에는 **현재 연도**를 넣어야 함.
>
> 원문: *"For the current year, the Road Transit Authority is issuing billing documents to all its customers with a numbering sequence between FEES##0000 and FEES##9999. This numbering is modified every year."*

**Document Splitting 분류**
경로: `General Ledger Accounting → Business Transactions → Document Splitting → Classify Document Types for Document Splitting`

기존 **KR (Vendor Invoice)** 설정값 확인:

| Transactn. | Variant |
| --- | --- |
| 0300 | 0001 |

신규 Document Type `##`에도 동일 값 입력.

#### Step 3. 신규 벤더(Business Partner) 생성
Fiori Launchpad → **Manage Business Partner** → Create → Organization

**General Data / Standard Address**

| 필드 | 값 |
| --- | --- |
| Business Partner | `RTA##` |
| Grouping | `BPAB` |
| BP Role | `FLVN00` |
| Name 1 | `Road Transit Authority ##` |
| Street / House Number | `SAP St.` / `##` |
| City / Postal Code | `Berlin` / `10117` |
| Country/Region | `DE` |

**Roles 탭** — FLVN00 role 확인.

> 💡 **알게 된 점**: Company Codes 탭은 처음엔 비활성/빈 상태 → Supplier 뷰로 전환해야 나타나며, **Roles 탭에 FI Vendor(FLVN00) role이 있어야 Company Codes 탭 자체가 노출**됨. Role 확인 없이는 바로 Company Code 등록이 안 됨.

**Company Code 등록 (Create) → General Data 탭**

| 필드 | 값 |
| --- | --- |
| Company Code | `TA##` |

**Finance 탭**

| 필드 | 값 |
| --- | --- |
| Reconciliation Account | `21100000` (Trade Payables Domestic) |
| Payment Terms | `0003` |

Sort Key(Assignment 필드 자동 채움용) — Finance 탭 안, Accounting 섹션의 Reconciliation Account 바로 아래에 위치.

> 💡 **알게 된 점**: F4로 리스트 열어보면 **032 = "Pstng yr,month,curr."**가 지침 문구("Pstng yr,month,curr.")와 토씨 하나까지 정확히 일치 → `032` 선택.

Apply → Apply → Create (저장 완료)

## Task 4

### Closing Operations – Perform Value Adjustments for Overdue Receivables

시스템: `TS4FI-##` / `TA##` (T41)

> **배경 시나리오**
> Bike Company는 매 기말마다 부실채권 위험 대비를 위해 정률법 개별 가치조정(flat-rate individual value adjustment)을 적용한다. 최근 시장 분석 결과 소규모 독립 자전거 소매상(small, independent bike retailers) 고객군의 신용 위험이 증가한 것으로 나타나, 이 고객군에만 별도의 엄격한 평가 규칙을 적용하기로 했다. 나머지 고객은 기존 규칙을 그대로 적용받는다.

#### Step 1. Value Adjustment Key 생성

**1-1. Ledger 0L에 연결된 Valuation Area 찾기**

> ⚠️ **시작 전에 확인해야 할 것**: Task가 요구하는 30%/60% 퍼센트는 "Ledger 0L에 연결된 Valuation Area"에 입력해야 함. 그런데 이게 한 번에 안 보여서 화면을 3단계 거쳐야 했음.

① **Define Valuation Areas** (경로: `SPRO → Financial Accounting → General Ledger Accounting → Periodic Processing → Valuate → Define Valuation Areas`) — Valuation(코드, 예 DE/IF), Valuation Method, Crcy Type, Long Txt 컬럼만 있고 **Ledger 관련 컬럼은 없음**.

② **Assign Valuation Areas and Accounting Principles** (같은 폴더) — Valuation Area와 그 옆 Acc.Princ. 값을 확인해서 메모.

③ **Check Assignment of Accounting Principle to Ledger Group** (같은 폴더) — ②에서 메모한 Acc.Princ.과 같은 줄을 찾아, Target Ledger Group이 `0L`인지 확인. 0L이면 그 줄의 Valuation Area가 정답.

> 💡 최종적으로 이렇게 값을 고른다: **Valuation Area(②의 결과) → Acc.Princ.(②의 결과) → Target Ledger Group 0L(③에서 확인)**
> (연습 당시 예시: Valuation Area **IF** → Acc.Princ. **IFRS** → Target Ledger Group **0L**. 시스템마다 다를 수 있으니 시험장에서 이 절차를 그대로 재현해서 확인할 것)

다시 ①로 돌아왔을 때, `0L`과 연결된 Area는 **`IF`**임을 확인 (연습서버 S4F12 기준).

**1-2. Value Adjustment Key 생성**
경로: `Financial Accounting → Accounts Receivable and Accounts Payable → Business Transactions → Closing → Valuate → Valuations → Define Value Adjustment Key`
(⚠️ "Further" 없이 그냥 "Valuations" — 경로 헷갈리기 쉬움)

화면명은 "Maintain Accumulated Depreciation Key"로 뜨지만 실제론 Value Adj Key 화면. New Entries로 아래 두 행 생성.

> 지침 원문: *"For receivables at least **30 days** overdue, apply a flat-rate value adjustment of **10%**." / "For receivables at least **60 days** overdue, apply a flat-rate value adjustment of **20%**."*

| Value Adj. Key | Valuation | C/R | Days | Debit Int. Rate |
| --- | --- | --- | --- | --- |
| `##` | IF | DE | 30 | 10 |
| `##` | IF | DE | 60 | 20 |

> Debit Int. Rate는 정수(10, 20)로 입력해도 저장 후 자동으로 **10,000 / 20,000** 포맷(소수점 3자리)으로 재표시됨. 직접 콤마/소수점 맞춰서 입력할 필요 없음.

**1-3. Calculation Base 설정 (posted net amounts 기준)**
경로: 같은 Valuations 폴더 → **Determine Base Value**

| Method | BaseAmt |
| --- | --- |
| 3 | 2 |

BaseAmt 필드는 F4(드롭다운) 없음 → F1(필드 도움말)로 확인해야 함.

> 원문: *"Under individual value adjustment for example, the discounted local currency amount is used as the base amount (entry: Method 3, basis =2)."*
> → Method 3(개별가치조정)일 때 basis=2가 net amount 개념. Task 요구사항(posted net amounts)과 일치해서 **BaseAmt = 2** 선택. (참고: 아무것도 입력 안 하면 기본값이 gross 기준으로 적용됨)

#### Step 2. 신규 Customer Business Partner 생성
Fiori App **Manage Business Partner Master Data** → 기존 BP `T-AC##` 조회 → 상단 메뉴 **Copy**

> Copy를 눌러도 새 BP 번호를 바로 안 물어봄 — 원본 데이터가 그대로 채워진 화면이 뜸. **Edit Header**를 직접 열어서 새 번호를 지정해야 함.

**Edit Header**

| 필드 | 값 |
| --- | --- |
| Business Partner | `TS4FI##` |
| Grouping | (원본과 동일, 자동) |
| BP Category | Person (원본 따라감) |

Basic Data에서 Last Name만 수정:

| 필드 | 값 |
| --- | --- |
| Last Name | `Bike Retailer ##` |

Roles 탭 → `FLCU00`(FI Customer) 확인. Company Codes 탭 → `TA##` 확인 (원본이 `TA##`의 고객이었으면 자동으로 복사되어 있음).

**`TA##` 탭 → Finance(또는 Correspondence) 탭 → Value Adjustment 필드에 `##` 입력 → Save**

> ⚠️ **가장 중요한 포인트.** Task 4 Step 2 지침 원문:
> *"By properly preparing the business partner master data, you ensure that the new, stricter rules for flat-rate individual value adjustment are **automatically applied only for this customer** in the next valuation run."*
>
> 이 한 문장이 사실상 "Value Adjustment 필드를 채워라"는 지시였는데, 처음엔 이걸 빼먹고 넘어가서 **Step 3(청구서 전기)과 Step 4(Valuation Run)까지 다 끝낸 뒤에야 조정액이 0으로 나오는 걸 보고 되돌아온 적이 있었음.** BP 생성 단계에서 바로 세팅하고 넘어갈 것 — 나중에 되돌아오면 Valuation Run을 처음부터 다시 해야 해서 시간 손해가 큼.

저장 시 External Number Assignment 에러가 나면 → Edit Header에서 번호 재확인 (Task 3에서 겪었던 것과 동일 원인).

#### Step 3. 연체 청구서 2건 전기
앱: **Create Outgoing Invoices** (Company Code `TA##`)

| 필드 | Invoice 1 | Invoice 2 |
| --- | --- | --- |
| Customer | `TS4FI##` | `TS4FI##` |
| Invoice/Posting date | 작년 11월 15일 | 작년 9월 15일 |
| Amount (gross) | 11,000 EUR | 11,000 EUR |
| Tax code | 1O | 1O |
| G/L acct (Credit) | 41000500 | 41000500 |

> 경고 **"Posting takes place in previous fiscal year"**는 무시하고 Post 진행 — 작년 날짜로 전기하는 게 Task 요구사항이라 의도된 정상 동작.

각 건마다 **Simulate**로 Balance 0 확인 (Customer 차변 11,000 = 매출 10,000 + 세금 1,000 대변) → **Post**

문서번호 반드시 메모 (Step 4에서 재사용은 안 하지만 결과 검증 시 대조용):
```
Invoice 1(11/15): 예) 1800000000
Invoice 2(9/15): 예) 1800000001
```

#### Step 4. Valuation Run 실행 + 검증
앱: **Perform Further Valuations**

**Parameters (1)**

| 필드 | 값 |
| --- | --- |
| Run On / Key Date | 작년 12/31 (둘 다 채워야 함) |
| Identification | `##` |

**Parameters (2)**

| 필드 | 값 |
| --- | --- |
| Run On / Key Date | 작년 12/31 (둘 다 채워야 함) |
| Val. Method | `3` |
| Valuation Area | (Step 1-1에서 찾은 값) |
| Postings | ✅ 체크 |
| Posting Date | 작년 12/31 |
| Rev.Post.Date | 올해 1/1 |
| Document Type | `SA` (필드 2군데 다 — 왼쪽 Post.Period 옆, 오른쪽 Rev.Post.Period 옆) |

**Selection options** (상단 메뉴 버튼)

| 필드 | 값 |
| --- | --- |
| Company code | `TA##` |
| Customers 체크 | ✅ + `TS4FI##` |

> 이 화면은 값 입력 후 **하단 Execute 버튼**으로 바로 진행하는 구조. 뒤로가기(`<`)나 상단 Save 누르면 입력값 리셋됨 — 스크롤 내려서 Execute 꼭 확인.
> Selection options 갔다 오면 Parameters 화면의 **Postings 체크박스가 풀려있을 수 있음** — 재확인 필수.

Parameters 화면 하단 **Save** → Initial Screen으로 자동 이동, "Details have been saved" 메시지 확인.

**실행**
1. **Dispatch** 버튼 클릭 → 팝업(Schedule Valuation Run)에서 **Start Immediat.** 체크 확인 → 팝업 안 **Dispatch**
2. Status가 **"Val.run finished"**로 바뀔 때까지 확인 (Enter/새로고침)
3. **Display** 버튼 → 결과 리스트(Customer Evaluation) 확인
   - 우리가 전기한 문서 2건만 잡혔는지 (다른 고객 안 섞였는지)
   - 조정 금액(Gross Val.Difference 등)이 0이 아닌지, 두 건이 서로 다른지

> ⚠️ **여기서 조정액이 두 건 다 0.00으로 나오거나 서로 같게 나오면** → Value Adjustment Key가 고객 BP에 안 걸려있다는 신호. Forward로 넘어가지 말고 **Delete run**으로 이번 실행 지운 뒤, 해당 고객 BP의 `TA##` Company Code 탭에서 Value Adjustment 필드 값(`##`) 확인/입력 → 처음부터 다시 Dispatch.

**정상 결과 예시** (Net amount 10,000 기준 — Gross 11,000이 아님, Step 1-3에서 BaseAmt=2/net 기준으로 설정했기 때문)

| 문서 | V.Adj.Key | 연체일수 | 조정액 |
| --- | --- | --- | --- |
| 11/15 청구건 | `##` | 46일 (30일 이상 구간) | 1,000 (10%) |
| 9/15 청구건 | `##` | 107일 (60일 이상 구간) | 2,000 (20%) |

**전기(Post)**
1. 뒤로가기 → 메인화면에서 **Forward** 클릭 → 팝업(Start Immediat. 체크) → **Dispatch**
2. Status **"Transfer finished"** 확인 (이 프로그램에선 "Post" 버튼이 따로 없고 Forward가 곧 Post 역할)

> Display를 다시 눌러도 원본 청구서 리스트만 재조회되고 새 조정전표 번호는 안 보임 — 정상. 조정전표 확인은 **Manage Journal Entries**(별도 앱)에서.

**검증: Manage Journal Entries (New Version)** 앱 새로 열기 → Company Code `TA##` / Posting Date 작년 12/31 / Document Type `SA`로 필터

각 문서 열어서 라인아이템 확인:

| Posting Key | G/L Account | 금액 |
| --- | --- | --- |
| 50 (Credit) | 12401100 (Allowance for doubtful accounts) | 1,000 또는 2,000 |
| 40 (Debit) | 62010000 (Individual Value Adjustment) | 1,000 또는 2,000 |

> 라인아이템 상세에서 "Amount in **Transaction** Currency"가 **0**으로 보여서 당황할 수 있는데, 이건 내부 생성 전표 특성상 그런 거고 **"Amount in Company Code Currency"** 컬럼에 정상적으로 금액이 찍혀있으면 문제없음.

### Task 4 전체 완료 체크리스트
- [x] Step 1: Value Adjustment Key `##` (30일→10%, 60일→20%, Net Amount 기준) 생성
- [x] Step 2: BP `TS4FI##` 생성 + **`TA##` Company Code에 Value Adjustment Key `##` 입력**
- [x] Step 3: 청구서 2건 전기 (11/15, 9/15, 각 11,000 EUR)
- [x] Step 4: Valuation Run 실행 → 결과 검증(1,000/2,000 확인) → Forward(Post) → Journal Entries에서 최종 확인
