// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (여러 번 시행착오 끝 최종본, 상세는 devlog 참고) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// 2026-09-04  자재 신규 생성 시 ztb07mara_t에 아직 텍스트가 없어 Value Help가 0건으로
//             뜨는 문제 발견. base table을 ztb07mara_t → t002/t002t 조합으로 교체하는
//             여러 시행착오(자기참조로 언어키 과다 노출 → 세션언어 고정 시 KO/KO 중복 등)
//             끝에, t002t를 기준으로 t002를 조인해 LanguageKey(sprsl)와 Language(laiso)를
//             분리하는 최종 구조로 재작성 — devlog: ../../../devlog/rap-dev/2026-09-04.md
// ============================================================
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '언어 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity zi_b07_spras_f4
  as select from t002t as a
    inner join   t002  as b on a.sprsl = b.spras
{
       @Search.defaultSearchElement: true
       @UI.hidden: true
  key  a.sprsl as LanguageKey, -- '3', 'E'

       @UI.hidden: true
       a.spras,

       @UI.textArrangement: #TEXT_LAST
       @ObjectModel.text.element: ['LanguageName']
       b.laiso as Language, -- 'KO', 'EN'

       @Semantics.text: true
       @Search.defaultSearchElement: true
       a.sptxt as LanguageName -- 'Korean', 'English'
}
where
       a.spras = $session.system_language
  and(
       a.sprsl = 'E'
    or a.sprsl = '3'
  )
