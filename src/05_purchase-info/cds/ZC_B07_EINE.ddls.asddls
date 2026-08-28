// ============================================================
// 변경이력
// 2026-08-27  최초 작성 (redirected to parent만 반영, FS에 EINE 관련 요구사항 없어 최소 구성) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보레코드 아이템 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_B07_EINE
  as projection on zi_b07_eine
{
    key InfUuid,
    key Werks,
    /* 기본 단가 */
    @Semantics.amount.currencyCode: 'Waers'
    Netpr,
    /* 가격 단위 */
    Peinh,
    /* 발주 단위 */
    Bprme,
    /* 통화 단위 */
    Waers,
    /* 최대 구매 수량 */
    @Semantics.quantity.unitOfMeasure : 'Bprme'
    Bstma,
    /* 유효종료일 */
    Prdat,
    /* 예정 배송일수 */
    Aplfz,
    CreatedBy,
    CreationAt,
    ChangedBy,
    ChangedAt,
    LocChangedAt,
    /* Associations */
    _Eina: redirected to parent ZC_B07_EINA
}
