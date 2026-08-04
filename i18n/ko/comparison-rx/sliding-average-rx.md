---
slug: sliding-average-rx
title: 판독값 3개 이동 평균 — RxDart vs FxDart
description: 센서 판독값의 이동 평균 — 꼬리 부분 윈도우를 막는 길이 필터가 필요한 bufferCount(3, 1) vs 뜻하는 바를 그대로 말하는 windowed(3).
heading: 판독값 3개 이동 평균
order: 21
tier: 2
functions: fx, windowed, average, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    시간별 온도 판독값 여덟 개를 <strong>판독값 3개 이동 평균</strong>으로
    매끄럽게 만드세요: 연속된 판독값 3개의 모든 윈도우에 대해, 윈도우와
    그 평균을 소수점 한 자리로 출력합니다 — 완전한 윈도우 여섯 개, 부분
    윈도우는 없습니다. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    RxDart는 슬라이딩 윈도우를 배칭의 매개변수화로 표기합니다:
    <code>bufferCount(3, 1)</code> — 크기 3의 버퍼를 이벤트 하나마다 새로
    시작. 동작은 하지만, 이 부호화는 두 군데서 샙니다. 두 번째 인자가
    <code>startBufferEvery</code>이고 <code>1</code>이 "슬라이딩"을
    뜻한다는 것을 알고 있어야 하고; 스트림 끝에서 연산자가 아직 열려
    있는 버퍼들을 흘려보내므로 <code>[21.9, 21.4]</code> 같은 램프다운
    부분 윈도우까지 튀어나와, 요구사항이 언급한 적도 없는 경우를
    <code>where((w) =&gt; w.length == 3)</code>이 서서 지켜야 합니다.
  </p>
  <p>
    FxDart에는 그 개념 자체를 가리키는 단어가 있습니다:
    <code>windowed(3)</code>는 정확히 완전한 윈도우들만 내놓고,
    <code>partial: true</code>가 램프다운에 대한 명시적 옵트인입니다 —
    기본값이 이동 평균의 의미와 일치합니다. 라이브러리 함수
    <code>average</code>까지 더하면(RxDart에는 집계 헬퍼가 없어 평균은
    손으로 만든 <code>reduce</code> 후 나누기입니다), pull 쪽은 요구사항을
    진술하고 push 쪽은 그것을 부호화합니다. 이 격차는 모델이 아니라
    어휘입니다 — 하지만 그 어휘가 존재하는 이유는 이터러블 위의 윈도우가
    pull에 자생하는 아이디어이기 때문이고, 이 판은 FxDart에게 갑니다.
  </p>
