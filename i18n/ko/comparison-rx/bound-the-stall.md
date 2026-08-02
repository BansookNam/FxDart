---
slug: bound-the-stall
title: 멈춰 버린 읽기에 시간 제한 걸기 — RxDart vs FxDart
description: 멈추는 센서 읽기에 150 ms 예산 — 스트림 timeout은 이벤트 사이의 간격을 재고, 풀 timeout은 요구부터 항목까지의 시간을 잽니다.
heading: 멈춰 버린 읽기에 시간 제한 걸기
order: 30
tier: 3
functions: fx, toAsync, map, timeout
domain: sensors
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    프로브 값 네 개를 차례로 읽습니다; 세 번째 읽기는 500&nbsp;ms
    동안 멈춥니다. 모든 읽기에 150&nbsp;ms 예산을 주세요: 제때 도착한
    측정값들을 출력하고, 멈춘 읽기에는 <code>reading timed out</code>을
    출력한 뒤 <strong>중단</strong>합니다 — 네 번째 읽기는 보고되면
    안 됩니다. 멈춤은 코드에 결정적으로 주입되어 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    읽기별 예산 자체는 양쪽 다 쉽습니다 — RxDart 패널은
    <code>asyncMap</code> 안의 <code>Future</code>에 제한을 걸고,
    FxDart의 <code>timeout</code>은 풀에 제한을 겁니다 — 그래서
    흥미로운 차이는 각 모델의 <em>스트림 수준</em> 동명 연산자가
    무엇을 재는가입니다. <code>Stream.timeout</code>은
    <strong>이벤트 사이</strong>의 간격을 지켜봅니다: 값이 언제
    도착할지는 생산자가 정하므로, "너무 느리다"는 "요즘 아무것도
    도착하지 않았다"라는 뜻일 수밖에 없습니다. FxDart의
    <code>timeout</code>은 <strong>요구부터 항목까지</strong>의
    시간에 제한을 겁니다: 소비자가 묻고, 시계는 물음에서 답까지
    돕니다. 이 유한하고 순차적인 과제에서는 둘이 일치하겠지만 —
    이들은 진짜로 다른 양입니다: 요구가 없는 풀 파이프라인에는 잴
    간격이 없고, 푸시 스트림은 누구의 물음에도 답을 빚지지 않습니다.
  </p>
  <p>
    그다음 양쪽 모두 "그리고 중단" 조항을 맞추기 위한 진짜 굴곡이
    하나씩 필요합니다. 푸시 쪽에서는 멈춘 소스가 여전히 저 바깥에
    있고, 느린 읽기가 마침내 도착하면 다시 측정값을 밀어 넣기 시작할
    것입니다 — 그래서 <code>onErrorReturnWith</code>가 오류를 보고
    줄로 바꾼 뒤, <code>takeWhileInclusive</code>가 스트림을 끝내고
    구독을 취소합니다. 풀 쪽에서 중단은 공짜입니다 —
    <code>TimeoutException</code>이 그냥 루프를 빠져나가고 아무것도
    다시 풀지 않습니다 — 다만 멈춤 이전의 측정값들을 지키려면, 오류를
    던지는 순간 그것들을 버렸을 <code>toList</code> 대신
    <code>each</code>로 수집해야 합니다.
  </p>
  <p>
    무승부입니다: 양쪽 다 연산자 하나에 굴곡 하나씩이고, 그 굴곡들은
    각 모델의 본성을 거울처럼 비춥니다.
  </p>
