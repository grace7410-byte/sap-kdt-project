// ============================================================
// 변경이력
// 2026-08-16  최초 작성 (여러 번 시행착오 끝 최종본, 상세는 devlog 참고) — devlog: ../../../devlog/rap-dev/2026-08-16.md
// ============================================================
// NOTE: mara_t의 spras와 t002t의 spras/sprsl은 의미가 다름 (텍스트 테이블 vs 언어 테이블).
//       t002(언어 테이블) + t002t(언어명 텍스트)를 각각 join해야 정확한 언어명이 나옴.
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '언어 F4 Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true

define view entity zi_b07_spras_f4
  as select distinct from ztb07mara_t as a
    inner join            t002        as b on a.spras = b.spras
    left outer join       t002t       as c on  b.spras = c.spras
                                           and c.sprsl = $session.system_language
{
      @UI.hidden: true
  key a.spras as LanguageKey, -- '3', 'E'

      @Search.defaultSearchElement: true
      @UI.textArrangement: #TEXT_LAST
      @ObjectModel.text.element: ['LanguageName']
      b.laiso as Language, -- 'KO', 'EN'

      @Semantics.text: true
      @Search.defaultSearchElement: true
      c.sptxt as LanguageName -- 'Korean', 'English'
}
