---
slug: with-latest-config
title: 각 요청에 최신 설정 도장 찍기 — RxDart vs FxDart
description: 나가는 요청마다 그 순간의 config 버전을 싣습니다 — rxdart와 fxEvents 양쪽 모두 같은 withLatestFrom 연산자.
heading: 각 요청에 최신 설정 도장 찍기
order: 41
tier: 4
functions: fxEvents, withLatestFrom
domain: general
verdict: tie
async: true
noBenchmark: timing
---
  <h2>요구사항</h2>
  <p>
    앱이 API 요청 네 건을 발사하는 동안, 배경에서는 배포가 config
    버전을 <code>v1 → v2 → v3</code>로 고정 오프셋에 맞춰 올립니다.
    각 요청에는 <em>요청이 발사된 순간</em> 유효하던 config 버전이
    찍혀야 하고 — config 상승만으로는 아무것도 내보내면 안 됩니다.
    도장 찍힌 요청 네 건을 출력하세요. 두 스케줄 모두 코드에
    시뮬레이션되어 있습니다; 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이제는 다르지 않습니다. 이것은 <code>combineLatest</code>의 비대칭
    형제입니다 — 한 스트림이 주도하고, 다른 스트림은 <em>참조</em>될
    뿐입니다 — 그리고 fxdart 0.7.3부터는 두 패널 모두 그것을 같은
    이름으로 부릅니다: <code>withLatestFrom</code>이 요청마다 내보내되
    지금까지 본 가장 신선한 config를 찍어 주고, config만 바뀔 때는
    침묵합니다. 옛 FxDart 패널에 필요했던 태그 병합 뼈대와
    <code>scan</code> 폴드는 사라졌습니다; 이제 두 체인은 연산자 대
    연산자로 동일합니다.
  </p>
  <p>
    fxdart 0.7.3의 이벤트 레이어는 push 쪽을 위해 Rx의 접근을
    흡수했습니다: <code>fxEvents</code>는 평범한 <code>Stream</code>
    위의 얇은 래퍼 체인으로 — 결코 extension이 아니어서 rxdart를
    포함해 어떤 것과도 충돌하지 않습니다. RxDart의 연산자 카탈로그는
    여전히 훨씬 큽니다; fxdart는 이벤트 코어를 작게 유지하고, 값별
    처리가 자라면 <code>.pull()</code>로 타입 있는 pull 파이프라인으로
    건너갑니다. 살아 있는 스트림 하나에 다른 스트림의 최신 값을 찍는
    일에서는 두 쪽이 동등합니다: 무승부입니다.
  </p>
