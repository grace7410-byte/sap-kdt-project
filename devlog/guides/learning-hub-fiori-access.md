# SAP 러닝허브 접속 & Fiori 사용법

## 목적 / 상황
실습용 SAP 시스템(러닝허브)에 접속하고, SAP GUI/Fiori 환경을 세팅하는 방법 정리.

## 절차

### 1) 러닝허브 접속
- https://learning.sap.com/ 접속 → 로그인 후 **Browse → Hands-on Practice Systems**
- 원하는 모듈(MM, SD 등) 검색하거나 알고 있는 Exercise 이름으로 검색해서 접속
- **Enroll** 클릭 → Prepare 상태로 대기 → **Access** 모드로 바뀌면 다시 클릭
- **Exercise_EN** 또는 **Exercise_KO** 파일 다운로드 후 **Access** 클릭
- 다운받은 파일을 열면 시스템 정보, User ID, PW 확인 가능

### 2) Fiori 사용 시
- 위 접속 절차와 동일하게 진행
- 서버 접속 후 **SAP GUI**를 열고 ID/PW 입력 → 로그인
- 하단 **Logon** 버튼으로 접근하거나, **`/UI2/FLP`** 티코드로 Fiori 접근
  - 안 되면 `/n`을 붙이거나 대문자로 입력해보기
- 동일한 ID/PW로 Fiori 로그온

### 3) Favorite Transaction 등록
- 첫 화면에서 마우스 우클릭 → **Insert Transaction**
- 원하는 Transaction Code를 모아두기
- T-Code를 함께 표시하고 싶다면: 상단 **Extras → Settings → Display Technical Names**

### 4) SE11 ALV 세팅
- 화면(다크모드/기본 테마)을 바꾸려면: **Settings → User Parameters**
- 기존 Standard SE16 list → **ALV Grid Display**로 수정
