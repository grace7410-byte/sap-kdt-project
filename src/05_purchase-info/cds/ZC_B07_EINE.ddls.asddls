// ============================================================
// 변경이력
// 2026-08-27  최초 작성 (redirected to parent만 반영, FS에 EINE 관련 요구사항 없어 최소 구성) — devlog: ../../../devlog/rap-dev/2026-08-27.md
// 2026-08-30  플랜트(Werks) Value Help + 텍스트(WerksText), 구매정보아이템 취소(Loekz) 추가,
//             LocChangedAt 제거(부모 etag를 dependent로 상속받는 구조라 자식이 별도로 가지면 안 됨) — devlog: ../../../devlog/rap-dev/2026-08-30.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '구매정보레코드 아이템 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_B07_EINE
  as projection on zi_b07_eine
{
  key InfUuid,

      @ObjectModel.text.element: ['WerksText']
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_B07_WERKS_F4', element: 'Plant' } }]
  key Werks,

      /* 플랜트명 */
      _Werks.PlantName as WerksText,

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

      Loekz,

      CreatedBy,
      CreationAt,
      ChangedBy,
      ChangedAt,
      /* Associations */
      _Eina : redirected to parent ZC_B07_EINA,
      _Werks
}
