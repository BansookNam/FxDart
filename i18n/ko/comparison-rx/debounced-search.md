---
slug: debounced-search
title: 검색창 디바운스하기 — RxDart vs FxDart
description: 타이핑이 잠잠해질 때까지 기다렸다가 검색 — 이벤트 스트림 위의 debounceTime vs fxdart 이벤트 레이어의 동일한 debounce 체인.
heading: 검색창 디바운스하기
order: 38
tier: 4
functions: fxEvents, debounce, map
domain: users
verdict: tie
async: true
noBenchmark: timing
---
  <h2>요구사항</h2>
  <p>
    사용자가 <code>f</code>, <code>fx</code>, <code>fxd</code>를 빠른
    연타로 입력하고, 잠시 멈췄다가, <code>fxdart</code>를 입력합니다.
    타이핑이 160&nbsp;ms 동안 잠잠했을 때만 검색하세요 — 그래서
    정확히 두 번의 검색이 실행되고(<code>fxd</code>와
    <code>fxdart</code>) — 각 결과를 출력합니다. 키 입력 스케줄은
    코드에 시뮬레이션되어 있습니다; 두 버전 모두 <em>예상 출력</em>
    아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    다르지 않습니다. 이것은 가장 순수한 형태의 <em>push</em>
    문제이고 — 흥미로운 것은 값이 아니라 <strong>값이 언제 도착하기를
    멈추는가</strong>입니다 — 두 패널 모두 같은 방식으로 말합니다:
    이벤트 스트림을 160&nbsp;ms로 디바운스하고, 살아남은 각 쿼리를
    검색하고, 수집합니다. RxDart는 그것을 <code>debounceTime</code>이라고
    쓰고; fxdart는 <code>fxEvents(...).debounce(...)</code>라고
    씁니다. 연산자 대 연산자로 두 체인은 동등하며, 닫힐 때 흘려보내는
    트레일링 값까지 같습니다.
  </p>
  <p>
    이는 의도된 것입니다: fxdart의 이벤트 레이어는 push 쪽을 위해 Rx의
    접근을 흡수했습니다. <code>fxEvents</code>는 평범한 Dart
    <code>Stream</code> 위의 얇은 래퍼 체인으로 — 결코 extension이
    아니어서 rxdart를 포함해 어떤 것과도 충돌하지 않습니다 — pull
    파이프라인이 정당하게 거절했던 시간 기반 연산자들에게 집을 마련해
    줍니다. RxDart의 연산자 카탈로그는 여전히 훨씬 큽니다; fxdart는
    일상적인 push 동사들을 다루고 거기서 멈춥니다. 그리고 디바운스된
    쿼리들이 타입 있는 요구 주도 작업 — 순서 있는 동시 fetch, 타입
    있는 에러 처리 — 으로 이어져야 할 때는 <code>.pull()</code>이
    <code>FxAsync</code> 파이프라인으로 돌아가는 문입니다.
  </p>
