---
slug: stock-revaluation
title: 재고 재평가, 조회는 한 번에 셋 — Dart vs FxDart
description: 대체 가격이 있는 실시간 가격 조회 — 순수 Dart의 워커 풀과 손수 만든 쌍 vs FxDart의 attach + concurrent + countWhere.
heading: 재고 재평가, 조회는 한 번에 셋
order: 48
tier: 4
functions: toAsync, attach, concurrent, map, sumBy, countWhere
domain: orders
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    창고에는 SKU, 보유 수량, 장부 가격을 가진 재고 품목들이 있습니다.
    모든 단가를 가격 서비스에서 새로 받아 오되 — <strong>동시 조회는
    최대 셋</strong> — 서비스가 모르는 SKU는 장부 가격으로 대체하세요.
    재평가된 재고 총액과 대체 가격을 쓴 품목 수를 출력하세요. 서비스는
    아래 코드에서 고정 지연으로 시뮬레이션되며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    어려운 부분 둘이 여기 겹칩니다. 조회가 품목을 잃어버리면 안 됩니다 —
    <code>attach</code>는 각 재고 라인을 서비스가 돌려준 가격(또는
    <code>null</code>) 옆에 붙잡아 두고, 그 덕에 대체 값
    <code>r.$2&nbsp;??&nbsp;r.$1.bookPrice</code>가 한 줄이 됩니다.
    그리고 팬아웃은 제한되어야 합니다 — <code>attach</code>가
    <code>map</code>과 같은 병렬 안전 기계를 타므로
    <code>concurrent(3)</code>이 연산자로서의 제한입니다. 집계는 어휘에서
    저절로 떨어집니다. 총액은 <code>sumBy</code>, 대체 횟수는
    <code>countWhere</code>.
  </p>
  <p>
    네이티브 버전은 그 전부를 지어야 합니다. 제한을 위한 공유 커서 워커
    풀, 비동기 건너뛰기에서 입력이 살아남도록 손수 만든
    <code>(품목, 가격)</code> 레코드, 순서를 지키는 미리 크기 잡은 결과
    슬롯, 그리고 개수를 위한 <code>where(…).length</code> 한 바퀴. 어느
    것도 어렵지는 않습니다 — 전부가 네 단계짜리 과제를 파묻는
    격식일 뿐입니다.
  </p>
