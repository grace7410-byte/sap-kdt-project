# 프로젝트 개요

> 출처: KDT 심화 2기 프로젝트 종합 가이드

## 목표

- Clean Core를 기반으로 한 RAP 애플리케이션 설계 및 구축
- CDS(Core Data Service) & RAP(ABAP RESTful Application Programming Model) 심화 기술 활용
  - CDS View 설계, Association/Composition 활용, OData Service 노출
  - RAP BO(Business Object) 모델링, CRUD 기능 구현
  - UI Annotation을 활용한 Fiori Elements 화면 구성

## 배경

신제품(스마트폰) 출시를 앞두고, 자재 등록 → 구매 → 입고 → 판매 → 출고 → 회계처리까지 이어지는 업무가 자재관리·구매관리·판매관리·회계관리 시스템에 분리되어 있어 데이터 불일치와 비효율이 발생. 이를 SAP RAP 기반의 하나의 통합 시스템으로 구축하는 것이 프로젝트의 출발점.

- Topic 1: 실시간 재고 분석 및 자재 주문 서비스
- Topic 2: 구매이력 분석 및 주문 서비스

## 진행 단계

| 단계 | 내용 |
| --- | --- |
| 분석 | 프로젝트 선정 및 스코핑, AS-IS/TO-BE 분석 |
| 설계 | 데이터 모델링(ERD), 프로세스 모델링(PFD) |
| 구현 | DB/CDS View 구축, RAP 모델(Behavior) 구현, Fiori UI 구성 |
| 테스트 | 단위 테스트, 통합 테스트, 최종 완료 보고 |

## 일정

| 주차 | 내용 |
| --- | --- |
| 1주 | 메인 프로젝트 선정 및 스코핑 |
| 2주 | 데이터/프로세스 모델링 |
| 2~5주 | 데이터베이스 구축 및 단위 프로그램(RAP) 구현 |
| 5~6주 | 단위/통합 테스트 |
| 6주 | 최종완료보고 및 평가 |

기간: 2026.08.03 ~ 2026.09.09
