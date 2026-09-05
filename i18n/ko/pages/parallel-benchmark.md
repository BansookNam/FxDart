---
slug: parallel-benchmark
title: parallel은 값어치를 하는가 — FxDart
description: CPU 작업 하나를 다섯 가지 방법으로 — 평범한 반복문, 손으로 짠 isolate, fxdart 체인, fxdart parallel, chunk를 준 parallel — 원소당 비용을 세 단계로 바꿔가며 측정합니다.
heading: <code>parallel</code>은 값어치를 하는가?
---
  <p class="hero-sub">작업 하나, 실행 방법 다섯 가지. 답을 가르는 숫자는
    딱 하나인데, 사람들이 흔히 떠올리는 그 숫자가 아닙니다.</p>

  <p>
    "CPU 작업에는 isolate를 쓰라"는 글은 하나같이 정작 답을 가르는
    지점 앞에서 멈춥니다. 원소 하나를 다른 isolate에 넘기고 결과를 받아
    오는 데는 약 <strong>5µs</strong>가 듭니다. 그 원소에 드는 일이 그보다
    싸다면 코어를 아무리 늘려도 소용없습니다. 방 건너편에 편지 한 장
    전하려고 택배를 부른 셈이니까요.
  </p>
  <p>
    그래서 아래 세 가지 사례는 딱 하나, 원소 하나에 드는 비용만
    바꿉니다. 데이터셋도 체크섬도 워커 함수도 모두 고정이고, 모든 프로그램이
    <em>같은</em> 최상위 함수를 호출합니다. 이들 사이의 유일한 차이는
    그 함수가 어디에서 실행되느냐입니다.
  </p>

  <h2>다섯 가지 방법</h2>
  <ol>
    <li><strong>네이티브, isolate 하나</strong> — 평범한 <code>for</code>
      반복문. 나머지 모든 행이 이것을 기준으로 측정됩니다. 누군가
      라이브러리를 찾아 나서기 전의 코드가 바로 이 모습이기 때문입니다.</li>
    <li><strong>네이티브 + <code>dart:isolate</code></strong> — 리스트를
      쪼개고 조각마다 <code>Isolate.run</code>을 하나씩,
      <code>Future.wait</code>으로 모아 이어 붙입니다. 손으로 짜면 이렇게
      되고, <code>parallel</code>이 넘어야 할 기준선이 바로 이것입니다.
      반복문만 이겨서는 부족합니다.</li>
    <li><strong>fxdart 체인, isolate 하나</strong> —
      <code>fx(xs).map(work).toList()</code>. isolate와는 아무 관련이
      없습니다. 체인 자체의 값을 매기려고 있는 행입니다. 그래야 아래
      행이 체인의 오버헤드를 슬쩍 공짜로 얻지도, 대신 뒤집어쓰지도
      않습니다.</li>
    <li><strong>fxdart <code>.parallel()</code></strong> — 같은 체인에서
      연산자 하나만 바꿉니다. 기본값 그대로라 원소 하나하나가 따로 워커로
      건너갑니다. 처음 쓸 때 쓰게 되는 형태입니다.</li>
    <li><strong>fxdart <code>.parallel(chunk:)</code></strong> — 같은
      연산자인데 메시지 하나에 원소 <code>k</code>개를 실어, 왕복 비용을
      원소마다가 아니라 배치마다 한 번만 냅니다. 마지막 두 행을 나란히
      둔 것은 의도적입니다. 둘 사이의 간격이 <em>바로</em> 왕복 비용을
      실제 비율로 그린 것입니다.</li>
  </ol>

  <h2>숫자 읽는 법</h2>
  <p>
    각 사례는 평범한 반복문이 약 <strong>5초</strong> 걸리도록 크기를
    맞췄습니다. 의도적입니다. 1초 아래에서는 isolate를 띄우는 비용(개당
    약 1ms)과 데이터 복사가 전체에서 차지하는 몫이 커서, 측정 결과가
    작업이 아니라 측정 장치를 말하게 됩니다. 병렬화할 가치가 있는
    작업이란 곧 시간이 좀 걸리는 작업입니다.
  </p>
  <p>
    작은 블록 두 개는 똑같은 프로그램을 N&nbsp;=&nbsp;10,000과
    N&nbsp;=&nbsp;100에서 돌린 것입니다. 채우려고 넣은 것이 아니라, 이것이
    답의 나머지 절반입니다. isolate에는 고정 비용이 있습니다. 하나 띄우는 데
    약 1ms, 거기에 데이터를 넣고 결과를 꺼내 오는 복사 비용까지. 작업이
    작을수록 남는 이득이 줄어드는데, 그 경계가 어디인지는 원소 개수만으로는
    짐작할 수 없습니다. <code>password-rehash</code>는 N&nbsp;=&nbsp;100에서도
    여전히 이기는데 <code>log-fingerprint</code>는 N&nbsp;=&nbsp;10,000에서
    이미 진다는 점을 보세요. 개수가 아니라 전체 작업량이 결정합니다.
  </p>

  <div class="callout">
    <strong>무엇을 볼 것인가.</strong>
    <code>password-rehash</code>는 원소 하나에 약 250µs — 왕복 비용의 쉰
    배 — 가 들고, <code>parallel</code>은 아무 것도 조율하지 않아도
    이깁니다. <code>log-fingerprint</code>는 원소 하나에 약 3.5µs로
    왕복보다 <em>싸고</em>, 기본값 <code>parallel</code>은 <em>평범한
    반복문보다 느립니다</em>. 결함이 아닙니다. 원소 단위 작업에 원소
    단위 값을 치르라고 시킨 것뿐입니다. <code>chunk:</code>가 해답이고,
    마지막 두 행이 그 값어치입니다.
  </div>

  <h2>워커를 늘려도 느린 행이 나아지지 않는 이유</h2>
  <p>
    <code>log-fingerprint</code>가 단지 병렬성이 모자란 것이라면 풀을
    키우면 나아져야 합니다. 그렇지 않습니다. 같은 프로그램을
    N&nbsp;=&nbsp;100,000에서 워커 수만 바꿔가며 돌린 결과입니다.
  </p>
  <pre><code>workers   .parallel()        .parallel(chunk:)
      1     768.8 ms             381.0 ms
      2     831.9 ms             191.1 ms
      5     899.1 ms              86.5 ms
     10     873.5 ms              71.0 ms</code></pre>
  <p>
    이 표는 따로 잰 값입니다 (<code>BENCH_N=100000</code>,
    <code>BENCH_WORKERS</code> 1–10).
    <code>results-parallel.json</code>에 들어 있지 않아서, 페이지
    차트를 다시 그려도 이 네 줄은 갱신되지 않습니다.
  </p>
  <p>
    기본 형태는 전혀 나아지지 않습니다. 오히려 조금씩 <em>나빠지고</em>,
    풀 크기와 무관하게 원소당 8µs 근처에 머뭅니다. chunk를 준 형태는 같은
    구간에서 5.4배로 확장됩니다.
  </p>
  <p>
    진단은 이것입니다. <code>chunk: 1</code>에서는 원소마다 메시지 복사
    두 번, 포트 이벤트 하나, 컴플리터 하나가 <strong>메인 isolate에서</strong>
    발생합니다. 메인 isolate는 스레드 하나이고, 이 시스템에서 유일하게
    병렬화할 수 없는 지점입니다. 3.5µs짜리 일을 넘기려고 8µs쯤을 조율에
    (hop에 컴플리터와 이벤트까지) 쓰는 셈입니다. 병목은 워커가 아닙니다.
    워커들은 편지 부치느라 바쁜 메인 isolate가 일을 던져주기를 기다리며
    놀고 있습니다. 워커를 더 붙이면 그 메인 isolate를 두고 경합만
    늘어납니다.
  </p>
  <p>
    배치는 조율을 싸게 만드는 것이 아니라, 조율할 일 자체를 줄입니다.
    chunk 행은 <code>n ~/ (workers * 4)</code>이라 워커 열 개면 언제나
    메시지 40개입니다. 이 스윕에서는 <code>chunk: 2500</code>으로
    왕복 10만 번 대신이고, 헤드라인 (N = 1,500,000)에서는
    <code>chunk: 37500</code>으로 왕복 150만 번 대신입니다. 메인
    isolate가 병목에서 벗어나면서 일이 비로소 원래 가야 할 곳으로
    갑니다.
  </p>

  <p>
    소스는 <code>benchmark/cases-parallel/</code>에 있습니다.
    <code>dart run benchmark/run_parallel_benchmarks.dart</code>로 다시
    생성합니다. 변형들이 모두 같은 체크섬을 내지 않으면 러너가 그 사례를
    거부하므로, 각 행은 언제나 같은 답을 구하는 서로 다른 방법입니다.
  </p>
