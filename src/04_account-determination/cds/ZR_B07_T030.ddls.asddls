// ============================================================
// 변경이력
// 2026-08-20  최초 작성 (Root BO View, 6개 Association 포함) — devlog: ../../../devlog/rap-dev/2026-08-20.md
// ============================================================
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '회계계정결정 Root Entity'
@Metadata.ignorePropagatedAnnotations: true
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity ZR_B07_T030 as select from ztb07t030
//composition of target_data_source_name as _association_name

association[0..*] to I_DomainFixedValueText as _BwartText
  on _BwartText.SAPDataDictionaryDomain = 'ZDB07BWART'
  and $projection.Bwart = _BwartText.DomainValue

association[0..*] to I_DomainFixedValueText as _KtoslText
  on _KtoslText.SAPDataDictionaryDomain = 'ZDB07KTOSL'
  and $projection.Ktosl = _KtoslText.DomainValue

association[0..1] to ZI_B07_BKLAS_F4 as _BklasText
  on $projection.Bklas = _BklasText.Bklas

association[0..1] to ZR_B07_SKA1 as _Ska1
  on $projection.Saknr = _Ska1.Saknr

association[0..*] to I_DomainFixedValueText as _BschlText
  on _BschlText.SAPDataDictionaryDomain = 'ZDB07BSCHL'
  and $projection.Bschl = _BschlText.DomainValue

association[0..*] to I_DomainFixedValueText as _ShkzgText
  on _ShkzgText.SAPDataDictionaryDomain = 'ZDB07SHKZG'
  and $projection.Shkzg = _ShkzgText.DomainValue
{
    key map_uuid as MapUuid,

    bwart as Bwart, // 이동유형 및 순번
    _BwartText [1: Language = $session.system_language ].DomainText as Bwatx,
    seqnr as Seqnr,

    ktosl as Ktosl, // 트랜잭션키
    _KtoslText[1: Language = $session.system_language ].DomainText as Ktotx,

    bklas as Bklas,// 자재 평가클래스
    _BklasText.Bkbez,

    saknr as Saknr,// 계정
    _Ska1._Ska1Text[1: Spras = $session.system_language ].Saktx,

    _Ska1.Glact,// 계정 타입
    _Ska1.GlactText as Glatx,

    bschl as Bschl, // 전기키
    _BschlText[1: Language = $session.system_language ].DomainText as Bsctx,

    shkzg as Shkzg, // 차/대변 구분
    _ShkzgText[1: Language = $session.system_language ].DomainText as Shktx,

    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    creation_at as CreationAt,
    @Semantics.user.lastChangedBy: true
    changed_by as ChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    changed_at as ChangedAt
//    _association_name // Make association public
}
