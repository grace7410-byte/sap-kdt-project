# BAS에서 시스템 연결 가이드 (List Report Page 생성 시)

## 목적 / 상황
BAS(Business Application Studio)에서 Fiori 앱(List Report Page 등)을 생성할 때 실제 백엔드 시스템과 연결하는 절차 정리. KDT CL2 강사님이 시연한 방법을 정리한 것이며, 클라우드 커넥터 등의 실제 설치는 오늘 실습에 포함되지 않아 추후 개별적으로 진행 예정.

## 절차

### 1) 사전 준비 — BTP Destination
- 각자 BTP에 Destination이 등록되어 있어야 함(먼저 확인).
- 팀에서 이미 만들어둔 Destination/System이 있으면 그대로 사용해도 되고, 개인이 별도로 만들어 써도 무방함.

### 2) BAS에서 시스템 연결
- List Report Page 선택 → **Connect to a System**
- **System**: 위에서 확인한 Destination 이름 입력
- **Service**: 우리가 만든 Service Binding 이름으로 검색해서 연결
- **Entity Selection**의 Main Entity: Entity Set Association에서 확인한 엔티티명 입력
- 타이틀/네임스페이스는 자유롭게 지정

### 3) 배포 대상 시스템 이름 지정
- 아밥 서버에 저장될(배포될) 이름은 반드시 **Z** 또는 **Y**로 시작해야 함.
- 로컬 오브젝트 또는 특정 패키지 지정 가능 — Manually 직접 입력 / Choose from Existing 중 선택.
- Change Request로 저장하려면 해당 Transport Request 번호가 있어야 함.
