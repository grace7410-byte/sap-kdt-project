// ============================================================
// 변경이력
// 2026-08-14  최초 작성 (SetInitialDefault, SetReadOnly) — devlog: ../../../devlog/rap-dev/2026-08-14.md
// 2026-08-17  Validation 메서드 실제 이름 확인 후 반영 (CheckInit/CheckMaterial/CheckSLoc/CheckCreated), get_instance_authorizations 덤프 이슈 확인 — devlog: ../../../devlog/rap-dev/2026-08-17.md
// ============================================================
// NOTE: CheckInit/CheckCreated는 구현 완료 상태이나 코드 본문은 미확보라 선언만 추가.
//       CheckMaterial/CheckSLoc은 2026-08-17 기준 실제로 본문이 비어있는 상태.
CLASS lhc_ZR_B07_MARA DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_b07_mara RESULT result.

    METHODS SetInitialDefault FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zr_b07_mara~SetInitialDefault.

    METHODS SetReadOnly FOR DETERMINE ON SAVE
      IMPORTING keys FOR zr_b07_mara~SetReadOnly.

    " 아래 4개는 실제 Validation 메서드명 (2026-08-17 확인)
    METHODS CheckInit FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckInit.
    METHODS CheckMaterial FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckMaterial.
    METHODS CheckSLoc FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckSLoc.
    METHODS CheckCreated FOR VALIDATE ON SAVE
      IMPORTING keys FOR zr_b07_mara~CheckCreated.

ENDCLASS.

CLASS lhc_ZR_B07_MARA IMPLEMENTATION.

  " 2026-08-17: 아무것도 채우지 않고 그냥 리턴하면 프레임워크가
  " "요청한 키에 대한 권한 결과가 없다"고 판단해 BEHAVIOR_CONTRACT_VIOLATION 덤프를 던짐.
  " 결국 4번(Determination/Validation) 쪽 문제로 되돌아옴 — 해결 못한 이슈로 남음.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD SetInitialDefault.
    MODIFY ENTITIES OF zr_b07_mara IN LOCAL MODE
    ENTITY zr_b07_mara
    UPDATE FIELDS ( Waers Peinh Ersda )
    WITH VALUE #( FOR key IN keys
                    ( %tky = key-%tky
                      Waers = 'KRW'
                      Peinh = 1
                      Ersda = sy-datum )
                ).
  ENDMETHOD.

  METHOD SetReadOnly.
    MODIFY ENTITIES OF zr_b07_mara IN LOCAL MODE
    ENTITY zr_b07_mara
    UPDATE FIELDS ( Matfi )
    WITH VALUE #( FOR key IN keys
                    ( %tky = key-%tky
                      Matfi = 'X' )
                ).
  ENDMETHOD.

  " CheckInit: 구현 완료 (필수값 누락 체크) — 코드 본문 미확보, 추후 반영
  " CheckCreated: 구현 완료 (등록일 한 달 이내 체크) — 코드 본문 미확보, 추후 반영

  METHOD CheckMaterial.
    " TODO: 자재코드(Matnr) 중복 체크 — 2026-08-17 기준 미구현 (본문 비어있음)
  ENDMETHOD.

  METHOD CheckSLoc.
    " TODO: 플랜트-저장위치 정합성 체크 — 2026-08-17 기준 미구현 (본문 비어있음)
  ENDMETHOD.

ENDCLASS.
