---
slug: stop-after-three-failures
title: 세 번 실패하면 포기하기 — RxDart vs FxDart
description: scan으로 실패를 세어 세 번째에서(포함하여) 멈추기 — 매퍼 안의 try/catch 하나 vs scan이 보기 전에 오류를 마커 값으로 바꾸는 작업.
heading: 세 번 실패하면 포기하기
order: 27
tier: 3
functions: fx, toAsync, map, scan, takeUntilInclusive
domain: logs
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    헬스 프로브 열 개의 피드가 순서대로 실행됩니다; 프로브 2, 5, 7,
    8, 9가 오류를 던집니다. <strong>세 번째</strong> 실패가 보이는
    순간(그것을 포함하여) 실행을 멈춘 뒤 세 가지 수치를 출력하세요:
    <em>processed</em> — 중단 전에 파이프라인에 들어온 프로브 수;
    <em>failures</em> — 그중 오류를 던진 수; <em>probes run</em> —
    실제로 실행된 프로브 본문 수로, 프로브 자체 안의 부수효과
    카운터로 집계합니다. 뒤쪽 프로브들은 결코 실행되면 안 되므로,
    실행 수는 처리 수와 일치해야 합니다. 스케줄은 코드에 들어
    있습니다; 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    세는 핵심부는 양쪽이 같습니다 — <code>scan</code>이 진행 중인
    <code>(done, fails)</code> 상태를 접고, 포함형 take 연산자가 세
    번째 실패에서 파이프라인을 자릅니다(한쪽은
    <code>takeUntilInclusive(fails == 3)</code>, 다른 쪽은
    <code>takeWhileInclusive(fails &lt; 3)</code>). 양쪽 모두 일을
    진짜로 멈추기도 합니다: <code>probes run: 7</code>은 구독 취소와
    풀 중단이 똑같이 효과적인 브레이크임을 증명합니다.
  </p>
  <p>
    차이는 scan이 셀 수 있게 되기 <em>전에</em> 각 쪽이 해야 했던
    일입니다. 오류를 던진 프로브는 스트림의 오류 채널에 사는데,
    거기는 scan이 볼 수 없는 곳이고 — 실패 1번에서 스트림을 끝내
    버릴 곳이기도 합니다. 그래서 RxDart 쪽은 먼저 모든 프로브를 내부
    스트림(<code>Rx.fromCallable</code> +
    <code>onErrorReturn(false)</code>)으로 변환해, 실패를 마커 값으로
    데이터 채널에 몰래 되돌려 보냅니다. FxDart 쪽에는 변환 단계가
    필요 없습니다. 변환해 올 <em>출처</em>가 없기 때문입니다:
    <code>map</code> 안의 try/catch가 결과를 사건이 일어난 바로 그
    자리에서 <code>bool</code>로 만들고, 파이프라인의 나머지는
    산수입니다. 같은 연산자들, 건너야 할 모델 경계는 하나 더 적게.
  </p>
