---
slug: first-mirror-wins
title: 두 미러 경주시키기 — RxDart vs FxDart
description: 페이로드 하나를 두 미러가 경주합니다 — Rx.race는 지는 fetch를 진행 중에 취소하고, 풀 파이프라인은 시작을 거절할 수 있을 뿐입니다.
heading: 두 미러 경주시키기
order: 46
tier: 4
functions: fx, toAsync, head
domain: general
verdict: rxdart
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
    경주는 푸시의 아이디어입니다: 전부 구독하고, 먼저 말하는 쪽을
    지키고, 나머지는 <em>취소</em>합니다. <code>Rx.race</code>가
    정확히 그것입니다 — 두 미러가 진짜로 동시에 진행되고, EU 미러가
    60&nbsp;ms에 값을 내보내는 순간 US 구독이 취소되어
    <code>onCancel</code>이 발동하고, 대기 중이던 타이머가 죽습니다.
    패자의 180&nbsp;ms 마감이 한참 지난 뒤에도 완료된 fetch 수가
    여전히 1인 이유가 그것입니다: 일이 무시된 것이 아니라 중단된
    것입니다.
  </p>
  <p>
    FxDart 쪽은 같은 줄들을 출력하지만 <strong>경주가
    아닙니다</strong>. <code>head</code>는 항목 하나를 요구하므로 풀
    체인은 첫 번째 미러만 listen합니다 — 백업은 구독되지도, 시작되지도
    않습니다. 요구 주도 지연성은 일의 <em>시작</em>을 거절할 수
    있지만, 풀 파이프라인에는 이미 진행 중인 <code>Future</code>를
    취소할 방법이 없습니다: 두 fetch를 모두 시작했더라면 패자는
    끝까지 실행되고 그저 무시되었을 것입니다. 그리고 느린 미러가 먼저
    나열되어 있었다면 이 체인은 그냥 180&nbsp;ms를 기다렸을 테지만,
    <code>Rx.race</code>는 여전히 백업으로 이겼을 것입니다. 요구사항이
    "먼저 응답하는 쪽이 이기고, 패자는 취소된다"라면 스트림 모델을
    쓰세요 — 여기는 RxDart의 영역입니다.
  </p>
