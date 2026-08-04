---
slug: restock-plan
title: 재고 재주문 계획 — Dart vs FxDart
description: 기준치 미달 품목의 우선순위를 정하고 예산선에서 주문 목록을 잘라냅니다 — 데이터 흐름으로서의 scan + zip + takeWhile 대 가변 누적 합계와 break.
heading: 재고 재주문 계획
order: 32
tier: 4
functions: filter, sortBy, scan, drop, zip, takeWhile, map, sumBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    재고 목록(데이터는 코드에 있음)에서 <strong>최소 재고량 미달</strong>
    품목을 찾아, 부족량이 큰 순서로 우선순위를 매기고, 그 우선순위
    순서대로 주문하되 — <strong>누적 비용이 500달러 예산을 초과하기
    전</strong>에 멈추세요. 계획된 각 주문을 누적 합계와 함께 출력한
    다음, 무엇을 주문했고 무엇이 남았는지 요약을 출력하세요. 두 버전
    모두 <em>예상 출력</em> 아래의 계획을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    예산 컷오프가 핵심입니다. FxDart는 누적 합계를 <em>데이터</em>로
    다룹니다: <code>scan</code>이 누적 비용 스트림을 만들고,
    <code>zip</code>이 각 품목을 그 누적 합계와 짝짓고,
    <code>takeWhile</code>이 예산선에서 계획을 잘라냅니다 — 컷오프 규칙은
    한 줄짜리 조건 하나이고, 누적 합계는 이미 출력할 준비가 되어
    있습니다. 네이티브 Dart는 모든 것을 하나의 루프 안에 뒤섞습니다:
    가변 <code>running</code> 변수, 이른 <code>break</code>, 그리고
    포맷팅이 모두 루프 본문을 공유하므로, 정책("예산을 넘으면 멈춘다")이
    눈에 보이는 파이프라인 단계가 아니라 제어 흐름 안에 숨어 있어, 따로
    옮기거나 테스트할 수 없습니다.
  </p>
