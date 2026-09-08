// ============================================================
// 변경이력
// 2026-09-08  최초 작성. 도메인 Fixed Value/체크테이블 모두 아니어서 디버거로 표준 함수모듈
//             HELP_VALUES_EPSTP까지 추적해 T163Y를 실제 소스 테이블로 확인 후 구성
//             — devlog: ../../../devlog/rap-dev/2026-09-08.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '품목범주(EPSTP) F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_B07_EPSTP_F4
  as select from t163y
{
      @Search.defaultSearchElement: true
  key epstp as Epstp,
      @Semantics.text: true
      ptext  as Epstptx
}
where
  spras = $session.system_language
