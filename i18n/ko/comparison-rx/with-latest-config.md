---
slug: with-latest-config
title: 각 요청에 최신 설정 도장 찍기 — RxDart vs FxDart
description: 나가는 요청마다 그 순간의 config 버전을 싣습니다 — withLatestFrom vs 브리지 뒤에서 scan으로 접는 태그 병합.
heading: 각 요청에 최신 설정 도장 찍기
order: 44
tier: 4
functions: fx, streams, scan, filter, map
domain: general
verdict: rxdart
async: true
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
    이것은 <code>combineLatest</code>의 비대칭 형제입니다: 한 스트림이
    주도하고, 다른 스트림은 <em>참조</em>될 뿐입니다. RxDart의
    <code>withLatestFrom</code>이 곧 이 요구사항의 이름입니다 —
    요청마다 내보내되 지금까지 본 가장 신선한 config와 짝지어 주고,
    config만 바뀔 때는 침묵합니다. 어느 스트림이 주인가가 연산자
    자체에 인코딩되어 있습니다.
  </p>
  <p>
    FxDart 쪽은 그 비대칭을 손으로 지어야 합니다. 이전 예제와 같은
    태그 병합 뼈대(컨트롤러, 닫힘 추적, 브리지)로 시작한 뒤, 폴드
    안에서 비대칭을 만듭니다: config 이벤트는 버전을 저장하고 요청
    슬롯을 비우며, 요청 이벤트는 그 슬롯을 채웁니다.
    <code>filter</code>가 대기 중인 요청이 있는 상태만 남기고,
    <code>map</code>이 도장을 포맷합니다. 모든 단계가 타입 있고
    명시적인데, 바로 그것이 문제입니다: 연산자 네 개가
    <code>withLatestFrom</code>이 그저 <em>이름 붙인</em> 것을
    재구현합니다. 판정은 RxDart — 살아 있는 스트림 하나가 다른
    스트림의 최신 값을 필요로 할 때마다 옳은 도구입니다.
  </p>
