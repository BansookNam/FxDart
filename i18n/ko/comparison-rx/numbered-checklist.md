---
slug: numbered-checklist
title: 체크리스트에 번호 매기기 — RxDart vs FxDart
description: 여섯 단계를 1.로 시작하는 번호 목록으로 — 스트림에는 인덱스 있는 map이 없어 Rx는 scan에 카운터를 밀반입하고, fxdart는 zipWithIndex라고 말합니다.
heading: 체크리스트에 번호 매기기
order: 10
tier: 1
functions: fx, zipWithIndex, map
domain: general
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    설치 6단계를 번호 붙은 체크리스트로 바꾸세요 — <code>1.&nbsp;Unbox
    the sensor kit</code>처럼, 한 단계에 한 줄, 번호는 1부터 시작합니다.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    코어 <code>Stream</code>에도 RxDart에도 인덱스 있는 <code>map</code>은
    없습니다. RxDart가 제공하는 가장 가까운 것은 <code>scan</code>인데,
    그 누산기가 마침 세 번째 인자로 인덱스를 받습니다 — 그래서 위의 rx
    표기는 <em>fold</em>에 올라타 단계 번호를 매깁니다: 발명해야 하는
    시드(<code>''</code>)와 곧바로 무시해 버리는 누적값이 등장하죠.
    대안들도 종류로 보면 더 깨끗하지 않습니다 — 매퍼가 캡처하는 가변
    카운터라든가, <code>Rx.range</code>와의 zip이라든가 — 어떤 경로든
    인덱스를 바깥에서 밀반입합니다. 인덱스를 실어 나르는 연산자가 없기
    때문입니다. 동작은 하지만, 여전히 우회처럼 읽힙니다.
  </p>
  <p>
    FxDart는 그것을 직접 말합니다: <code>zipWithIndex</code>가 각 요소를
    그 위치와 짝짓고, 평범한 <code>map</code>이 그 쌍을 포맷합니다.
    이것은 push 대 pull의 격차라기보다 어휘의 격차입니다 — 인덱스 짝짓기
    연산자는 어느 모델에서든 쉽게 표현할 수 있는데, Rx가 그것을 기르지
    않았을 뿐입니다 — 하지만 각 패널의 독자는 그 차이를 느낍니다: 한쪽은
    "요소와 그 인덱스"라고 진술하고, 다른 쪽은 그것을 누산기의 남는
    매개변수에 부호화합니다. 판정: FxDart.
  </p>
