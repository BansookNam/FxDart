---
slug: first-mirror-wins
title: 두 미러 경주시키기 — RxDart vs FxDart
description: 페이로드 하나를 두 미러가 경주합니다 — Rx.race와 FxEvents.race 모두 지는 fetch를 진행 중에 취소하고, 완료된 fetch가 하나뿐임을 똑같이 증명합니다.
heading: 두 미러 경주시키기
order: 46
tier: 4
functions: fxEvents, race
domain: general
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    같은 페이로드를 두 미러에서 받을 수 있습니다: EU 미러는
    60&nbsp;ms에, US 미러는 180&nbsp;ms에 응답합니다. 최대한 빨리
    가져오되, 느린 fetch가 끝까지 실행되지 <strong>않도록</strong>
    하세요 — 패자의 마감 시간이 한참 지난 뒤 완료된 fetch 수를 세어
    증명합니다. 미러들은 코드에 취소 가능한 스트림으로 시뮬레이션되어
    있습니다; 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이제는 다르지 않습니다. 경주는 push의 아이디어입니다 — 전부
    구독하고, 먼저 말하는 쪽을 지키고, 나머지는 <em>취소</em>합니다 —
    그리고 fxdart 0.7.3부터 <code>FxEvents.race</code>가 정확히
    그것이며, <code>Rx.race</code>와 수 하나하나까지 맞아떨어집니다:
    두 미러가 진짜로 동시에 진행되고, EU 미러가 60&nbsp;ms에 값을
    내보내는 순간 US 구독이 취소되어 <code>onCancel</code>이 발동하고,
    대기 중이던 타이머가 죽습니다. 두 패널 모두 같은 방식으로
    증명합니다 — 패자의 180&nbsp;ms 마감이 한참 지난 뒤에도 완료된
    fetch 수가 여전히 1입니다. 양쪽 모두에서 일은 그저 무시된 것이
    아니라 중단되었습니다.
  </p>
  <p>
    옛 FxDart 패널은 백업 fetch의 <em>시작</em>을 거절할 수 있을
    뿐이었습니다; 대신 이벤트 레이어가 Rx의 접근을 흡수했습니다:
    평범한 <code>Stream</code> 위의 얇은 래퍼 체인이라 rxdart를 포함해
    어떤 것과도 충돌하지 않습니다. RxDart의 연산자 카탈로그는 여전히
    훨씬 큽니다 — fxdart는 이벤트 코어를 작게 유지하고, 승자의 값별
    처리는 <code>.pull()</code>을 통해 타입 있는 pull 쪽에 넘깁니다.
    "먼저 응답하는 쪽이 이기고, 패자는 취소된다"에서 이제 둘은 연산자
    대 연산자로 동등합니다: 무승부입니다.
  </p>
