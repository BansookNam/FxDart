---
slug: clean-nullable-readings
title: null은 버리고 값만 남기기 — RxDart vs FxDart
description: null이 섞인 센서 피드를 정리하고 남은 값을 포맷하기 — whereNotNull은 이름만 다른 compact이고, 둘 다 double?을 double로 정적으로 좁힙니다.
heading: null은 버리고 값만 남기기
order: 8
tier: 1
functions: fx, compact, map
domain: sensors
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    배터리 모니터가 전압 샘플 아홉 개를 만들었는데, 그중 세 개는 센서가
    놓쳤습니다(<code>null</code>). 실패를 버리고, 살아남은 각 샘플을
    소수점 한 자리로 포맷해 출력한 뒤, 몇 개가 버려졌는지 보고하세요.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    <code>whereNotNull</code>은 <em>곧</em> <code>compact</code>입니다 —
    같은 연산자가 각 라이브러리의 명명 규칙을 입고 있을 뿐입니다. 둘 다
    필터링 너머의 중요한 일을 합니다: <strong>정적 타입을 좁혀서</strong>
    <code>double?</code> 요소 타입을 <code>double</code>로 바꿉니다.
    덕분에 하류의 <code>toStringAsFixed</code> 호출에는 null 체크도
    <code>!</code>도 필요 없습니다. 필터와 타입 승격을 한 단어로, 양쪽
    모두에서 해냅니다.
  </p>
  <p>
    그러니 어휘에 관한 판정은 무승부이고 — 정직하게 남는 것은 전달
    모델뿐입니다. 스트림 버전은 이미 들고 있는 리스트를
    <code>Stream</code>으로 끌어올렸다가 수집 결과를 다시 await로
    받아냅니다; pull 버전은 스트림 버전의 첫 <code>await</code>가
    실행되기도 전에 이미 끝나 있습니다. 요소 아홉 개짜리 고정 리스트에서
    그 오버헤드는 어깨 한 번 으쓱하고 넘길 만큼 작은데, 바로 그것이 이
    예제와, 판정을 실어 나른 <em>유효한 짝수 금액 합산하기</em>의 집계
    사이의 차이입니다: 여기서의 핵심은 두 라이브러리가 타입 승격까지
    똑같이 합의한다는 점입니다.
  </p>
