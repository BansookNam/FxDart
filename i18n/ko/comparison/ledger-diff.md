---
slug: ledger-diff
title: 두 가계부 스냅샷 비교 — Dart vs FxDart
description: 두 스냅샷 사이의 추가/삭제/불변 항목을 찾습니다 — id 기준 differenceBy와 intersectionBy를 직접 만든 id 집합과 where 필터 조합과 비교합니다.
heading: 두 가계부 스냅샷 비교
order: 37
tier: 4
functions: differenceBy, intersectionBy, sortBy, map, concat, size, sumBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    같은 가계부의 두 스냅샷(데이터는 코드에 있음): 그 사이에 동기화가
    일어나면서 항목이 추가되거나 삭제되었습니다. 항목 id를 기준으로 diff를
    출력하세요 — 추가된 항목은 <code>+</code> 줄, 삭제된 항목은
    <code>-</code> 줄로 표시하고(각 구간은 id로 정렬), 변경되지 않은 항목의
    개수와 총액의 순변화량도 출력하세요. 두 버전 모두 <em>예상 출력</em>
    아래에 표시된 diff를 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    diff를 만드는 일은 키를 기준으로 한 집합 연산이며, FxDart는 그
    어휘를 그대로 제공합니다: <code>differenceBy</code>를 양방향으로
    호출하면 추가분과 삭제분이 나오고, <code>intersectionBy</code>는
    변경되지 않은 항목을 줍니다 — 세 줄의 선언이 diff의 정의 그 자체처럼
    읽힙니다. 이어지는 <code>sortBy</code> → <code>map</code> →
    <code>concat</code> 파이프라인은 두 구간을 하나의 식으로 렌더링합니다.
    순수 Dart는 <code>Set</code> 자체에 대한 집합 연산만 제공할 뿐 "이
    객체들을 이 키 기준으로"라는 연산은 없으므로, 정직한 버전은 id 집합을
    직접 투영하고 방향마다 부정된 <code>contains</code> 필터를 작성해야
    합니다 — 방향을 거꾸로 하기 쉽고, "B에는 있는데 A에는 없는 것은?"이라는
    의도가 함수 이름이 아니라 술어의 극성(polarity)에 숨어 있게 됩니다.
  </p>
