---
slug: duplicate-transactions
title: 중복 거래 찾아내기 — Dart vs FxDart
description: 판매자, 금액, 날짜가 같은 청구를 표시합니다 — 순수 Dart의 putIfAbsent와 중첩 루프를 FxDart의 groupBy + filter + flatMap과 비교합니다.
heading: 중복 거래 찾아내기
order: 21
tier: 3
functions: groupBy, filter, flatMap, map, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    같은 <strong>판매자, 금액, 날짜</strong>로 두 번 나타나는 청구는
    이중 결제일 가능성이 높습니다. 7월 거래 내역에서 그런 그룹을
    모두 찾아 사용자가 검토할 수 있도록 <em>관련된 거래 각각</em>을
    나열하세요 — 단, 같은 판매자와 금액이라도 <em>날짜가 다르면</em>
    중복으로 표시하지 마세요(같은 커피를 반복 구매한 것은 중복이
    아닙니다). 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이 알고리즘은 그룹화–유지–평탄화이고, FxDart는 그 세 단어를
    그대로 코드로 씁니다: 판매자|금액|날짜 키로 <code>groupBy</code>하고,
    구성원이 둘 이상인 그룹만 <code>filter</code>하고, 살아남은
    그룹을 다시 개별 거래로 <code>flatMap</code>합니다
    (<code>map</code> + <code>join</code>으로 형식을 맞춥니다). 순수
    Dart에는 이 세 단어에 해당하는 어휘가 없습니다: 그룹화는
    <code>putIfAbsent</code> 루프가 되고, 유지-후-평탄화는 그 사이에
    <code>if</code>가 낀 중첩 <code>for</code> 루프가 됩니다. 둘 다
    맞는 코드지만, 명세를 그대로 옮긴 문장처럼 보이는 쪽은 하나뿐입니다.
  </p>
