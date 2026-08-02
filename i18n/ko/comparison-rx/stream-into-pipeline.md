---
slug: stream-into-pipeline
title: 스트림이 타입 있는 파이프라인으로 흘러들 때 — RxDart vs FxDart
description: 라이브 로그 스트림이 fxStream을 거쳐 타입 있는 풀 파이프라인으로 흘러갑니다 — 경고만 남기고, 대문자로 바꾸고, 세기. 다리의 양쪽에서.
heading: 스트림이 타입 있는 파이프라인으로 흘러들 때
order: 49
tier: 4
functions: fx, streams, filter, map, toList
domain: logs
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    라이브 로그 피드가 고정 스케줄로 일곱 줄을 내보내고 닫힙니다.
    경고만 남기고, 인시던트 채널용으로 대문자로 바꾸고, 마지막 개수와
    함께 출력하세요. 피드는 코드에 (양쪽에 동일하게) 시뮬레이션되어
    있습니다; 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 다르지 않습니다 — 그리고 그것이 이 쌍의 요점입니다. 소스는
    푸시 본연의 것, 내키는 대로 값을 내보내는 <code>Stream</code>이고,
    RxDart는 그 모델 안에 머뭅니다: <code>mapNotNull</code>이 필터링과
    포매팅을 연산자 하나로 하고, <code>toList</code>가 닫힐 때
    수집합니다. 깨끗하고, 관용적이고, 끝.
  </p>
  <p>
    FxDart 쪽은 스트림과 싸우지도, 소스를 다시 모델링하지도 않습니다
    — <em>브리지</em>합니다. <code>fxStream</code>은 어떤
    <code>Stream</code>이든 풀 기반 비동기 이터러블로 감싸고, 그
    지점부터 코드는 리스트 위에 쓸 법한 것과 같은 타입 있는
    체인입니다: <code>filter</code>, <code>map</code>,
    <code>toList</code>. 브리지는 밀려온 이벤트를 파이프라인이 요구할
    때까지 버퍼링하므로, 아무것도 잃지 않고 순서도 보존됩니다. 이것은
    대결이 아니라 협력의 예제입니다: 이벤트가 태어나는 가장자리에서는
    스트림을 스트림으로 두고, 타입 있는 요구 주도 처리를 원하는
    순간에 풀 파이프라인으로 건너오세요 — 두 모델은 한 줄로
    합성됩니다. 무승부, 그것도 의도된 무승부입니다.
  </p>
