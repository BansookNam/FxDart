---
slug: debounced-search
title: 검색창 디바운스하기 — RxDart vs FxDart
description: 타이핑이 잠잠해질 때까지 기다렸다가 검색 — 이벤트 스트림 위의 debounceTime 연산자 하나 vs 손으로 배선한 콜백 디바운서.
heading: 검색창 디바운스하기
order: 40
tier: 4
functions: fx, debounce, toAsync, map
domain: users
verdict: rxdart
async: true
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
    이것은 가장 순수한 형태의 <em>푸시</em> 문제입니다: 흥미로운 것은
    값이 아니라 <strong>값이 언제 도착하기를 멈추는가</strong>입니다.
    그것이 바로 스트림이 모델링하는 것이고, RxDart는 그것을 직설로
    말합니다 — 이벤트 스트림에 <code>debounceTime(160ms)</code>,
    그다음 검색, 그다음 수집. 구독, 윈도잉, 닫힐 때의 트레일링
    엣지까지 모두 연산자가 처리합니다.
  </p>
  <p>
    FxDart에는 의도적으로 시간 기반 파이프라인 연산자가 없습니다 —
    풀 파이프라인에는 "도착 사이의 시간"이 없고 요구만 있습니다. 그
    <code>debounce</code>는 FxTS 스타일의 <em>콜백 래퍼</em>입니다:
    올바르지만, 스트림에 배선하는 것도, 잠잠해진 쿼리들을 모으는
    것도, 닫힐 때 트레일링 윈도를 기다려 주는 것도 직접 해야 하고, 그
    뒤에야 살아남은 쿼리들을 실제 검색을 위한 타입 있는 파이프라인에
    넘길 수 있습니다. 정직한 판정: 다리의 이쪽에서는 RxDart를 쓰세요
    — 그리고 하류 작업이 자라면(타입 있는 오류 처리, 순서 있는 동시
    fetch) 디바운스된 스트림을 <code>fxStream</code>에 통과시켜
    거기서부터 FxDart로 이어 가세요.
  </p>
