---
slug: crawl-the-pages
title: 소진될 때까지 페이지 크롤링하기 — RxDart vs FxDart
description: 준비됐을 때만 다음 페이지를 요청 — 요구가 있을 때 당겨지는 끝없는 지연 커서 vs 첫 빈 페이지에서 취소되는 충분히 큰 Rx.range.
heading: 소진될 때까지 페이지 크롤링하기
order: 48
tier: 4
functions: fx, toAsync, flatMap, takeWhile, map
domain: orders
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    페이지 단위 주문 API는 페이지당 주문 세 건을 반환하고, 데이터가
    떨어지면(4페이지) 빈 리스트를 반환합니다. 빈 페이지가 나올 때까지
    페이지를 하나씩 크롤링하고, 주문들을 하나의 리스트로 평탄화한 뒤,
    그것들과 함께 실제로 가져온 페이지 수를 출력하세요 — 정확히 네
    페이지입니다; 크롤은 결코 5페이지를 요청해서는 안 됩니다. 가짜
    API는 코드에 들어 있습니다; 두 버전 모두 <em>예상 출력</em>
    아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    페이지네이션은 그 자체가 풀 모델<em>입니다</em>: 페이지 하나를
    가져오고, 들여다보고, 하나 더 요청할지 결정합니다. FxDart 쪽은
    그것을 그대로 적어 내려갑니다 — 파이프라인이 다음 것을 요구할
    때만 전진하는, 페이지 번호의 끝없는 <code>sync*</code> 커서,
    <code>map(fetchPage)</code>, <code>takeWhile(isNotEmpty)</code>,
    평탄화. 커서에 한계를 두는 것은 아무것도 없습니다. 요구가 곧
    한계이기 때문입니다: <code>takeWhile</code>이 빈 페이지를 보면
    그냥 풀기를 멈추고, 5페이지는 생성조차 되지 않습니다.
  </p>
  <p>
    스트림 쪽도 같은 곳에 도달하지만, 풀 메커니즘을 빌려서만
    가능합니다: 끝없는 <code>async*</code> 커서 — Rx 연산자가 아니라
    순수 Dart — 를 <em>일시 정지</em>시켜 <code>asyncMap</code>의 배압으로
    요구 주도 동작으로 만들고, <code>takeWhile</code>의 취소가 빈
    페이지에서 크롤을 멈춥니다. 동작하고, 같은
    <code>pages fetched: 4</code>를 출력합니다 — pause, resume,
    cancel이 바로 "준비되면 다시 요청한다"를 흉내 내는 스트림 모델의
    역방향 채널이기 때문입니다. 풀 쪽에는 그 흉내가 필요 없었습니다:
    요구가 그것의 평상 모드입니다. 소비자의 상태가 입력이 더
    존재해야 하는지를 결정하는 일은 풀 모양의 일이고, 이것은 그중
    가장 깔끔한 사례입니다.
  </p>
