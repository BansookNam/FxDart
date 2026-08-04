---
slug: throttled-refresh
title: 새로고침 버튼 스로틀링하기 — RxDart vs FxDart
description: 300 ms 윈도마다 탭 하나만 통과 — 탭 스트림 위의 throttleTime vs fxdart 0.7.3 이벤트 레이어의 동등한 throttle 체인.
heading: 새로고침 버튼 스로틀링하기
order: 44
tier: 4
functions: fxEvents, throttle
domain: users
verdict: tie
async: true
noBenchmark: timing
---
  <h2>요구사항</h2>
  <p>
    사용자가 새로고침 버튼을 연타합니다: 0/50/100/400/450/800&nbsp;ms
    시점의 탭들. 300&nbsp;ms 윈도당 최대 한 번의 새로고침만
    통과시키되, 각 윈도의 <em>첫</em> 탭을 취하세요 — 그래서 정확히
    세 번의 새로고침이 발동합니다(탭 0, 3, 5). 스트림이 닫힌 뒤 어느
    탭들이 통과했는지 출력합니다. 탭 스케줄은 코드에 시뮬레이션되어
    있습니다; 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이제는 다르지 않습니다. 스로틀링은 <em>시간 속의 도착</em>에 대한
    속도 제한 — 값이 아니라 이벤트가 언제 일어나는가의 속성 — 이고,
    이제 두 패널 모두 요구사항을 탭 스트림 위의 연산자 하나로
    접습니다. RxDart의 <code>throttleTime(300ms)</code>과 fxdart의
    <code>fxEvents(...).throttle(300ms)</code>은 같은 리딩 엣지 윈도를
    구현하며(첫 탭이 값을 내보내며 윈도를 열고, 연타의 나머지는
    삼켜집니다; 트레일링 엣지는 양쪽 모두 플래그 하나 거리에
    있습니다), 구독, 윈도 장부 정리, 완료가 모두 연산자 안에서
    처리됩니다.
  </p>
  <p>
    fxdart&nbsp;0.7.3은 push 쪽을 위해 Rx의 접근을 의도적으로 흡수해
    여기에 도달했습니다: <code>fxEvents</code>는 평범한
    <code>Stream</code> 위의 래퍼 체인으로 — extension이 아니어서 멤버
    충돌 하나 없이 어떤 스트림 라이브러리와도 공존합니다. RxDart의
    연산자 카탈로그는 fxdart의 이벤트 레이어보다 여전히 훨씬 큽니다;
    이 예제 같은 일상적인 시간 동사들에서는 이제 둘이 서로 대체
    가능합니다. 살아남은 각 탭이 이어서 진짜 타입 있는 비동기 작업을
    발동해야 한다면, <code>.pull()</code>이 스트림을 요구 주도
    <code>FxAsync</code> 파이프라인으로 실어 갈 것입니다.
  </p>
