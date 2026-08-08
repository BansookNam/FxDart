---
slug: top-log-level
title: 가장 많이 발생한 로그 레벨 — Dart vs FxDart
description: 로그 항목을 레벨별로 세어 가장 많은 것을 고릅니다 — 순수 Dart의 groupListsBy + reduce와 FxDart의 countBy + maxBy를 비교합니다.
heading: 가장 많이 발생한 로그 레벨
order: 2
tier: 1
functions: countBy, maxBy
domain: logs
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    애플리케이션 로그 일부가 주어질 때, 각 <strong>레벨</strong>(INFO /
    WARN / ERROR)이 몇 건씩 있는지 세어, 가장 많이 발생한 레벨을 그
    개수와 함께 출력하세요. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    네이티브 Dart에는 <code>countBy</code>가 없습니다. 가장 가까운 것은
    <code>package:collection</code>의 <code>groupListsBy</code>인데, 이는
    레벨마다 <em>모든 항목</em>의 리스트를 만들어 놓고서 그 길이만
    취하는 방식입니다 — 아니면 직접 작성한 <code>Map.update</code>
    루프를 쓰거나요. 그런 다음 가장 많은 쪽을 고르려면 명시적인 비교를
    담은 <code>reduce</code>가 필요합니다. FxDart는 두 단계 모두에
    이름을 붙입니다: <code>countBy</code>는 곧바로 개수로 이어지고(종결
    연산자라 평범한 <code>Map</code>을 반환합니다),
    <code>fx(counts.entries).maxBy(...)</code>는 체인에 다시 들어가 가장
    큰 엔트리를 고릅니다. 직접 만든 두 개가 아니라 이름 붙은 두 개의
    아이디어입니다.
  </p>

  <h2>벤치마크가 뒤집히는 이유</h2>
  <p>
    위의 막대는 오해하기 쉽습니다: FxDart가 N=10,000에서는
    <em>지고</em> N=1,000,000에서는 <em>이깁니다</em>. 둘 다 사실이지만,
    어느 쪽도 보이는 그대로가 아닙니다. 아래는 같은 사례를 네 가지
    규모로 훑은 것으로, 위 문단이 언급만 하고 차트에는 넣지 않은 세
    번째 구현 — 직접 작성한 카운팅 루프, 즉
    <code>package:collection</code>에 손을 뻗지 않았다면 썼을 코드 —
    까지 함께 담았습니다.
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>직접 루프</th>
        <th>FxDart</th><th><code>groupListsBy</code> 대비</th><th>직접 루프 대비</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10,000</td><td>345 µs</td><td>288 µs</td><td>415 µs</td>
        <td>1.20× 느림</td><td>1.44× 느림</td></tr>
      <tr><td>100,000</td><td>3.48 ms</td><td>2.87 ms</td><td>4.16 ms</td>
        <td>1.20× 느림</td><td>1.45× 느림</td></tr>
      <tr><td>400,000</td><td>18.7 ms</td><td>11.6 ms</td><td>16.4 ms</td>
        <td><strong>1.14× 빠름</strong></td><td>1.41× 느림</td></tr>
      <tr><td>1,000,000</td><td>45.2 ms</td><td>28.5 ms</td><td>40.8 ms</td>
        <td><strong>1.11× 빠름</strong></td><td>1.43× 느림</td></tr>
    </tbody>
  </table>
  <p>
    마지막 열을 먼저 보세요. 움직이지 않는 열이 그것이니까요: 직접
    작성한 루프에 대해 FxDart는 <strong>모든 규모에서 ~1.4×
    느립니다</strong>. 만 건에서 백만 건까지 한결같이요. 그것이 체인의
    정직한 비용입니다 — <code>fx()</code> 래퍼와 <code>countBy</code>를
    거치는 클로저 호출로 원소당 대략 7 ns. 이 비용은 결코 나아지지
    않으며, N을 아무리 키워도 FxDart의 파이프라인이 루프보다 빨라지지는
    않습니다.
  </p>
  <p>
    그러므로 가운데 열의 역전은 FxDart가 빨라진 것이 아닙니다.
    <code>groupListsBy</code>가 <em>느려진</em> 것이고, 그 이유는 메모리
    열에 드러납니다:
  </p>
  <table>
    <thead>
      <tr>
        <th>N</th><th><code>groupListsBy</code></th><th>직접 루프</th><th>FxDart</th>
      </tr>
    </thead>
    <tbody>
      <tr><td>10,000</td><td>19.7 MB</td><td>14.7 MB</td><td>14.8 MB</td></tr>
      <tr><td>100,000</td><td>35.3 MB</td><td>16.8 MB</td><td>16.9 MB</td></tr>
      <tr><td>400,000</td><td>62.6 MB</td><td>25.8 MB</td><td>25.9 MB</td></tr>
      <tr><td>1,000,000</td><td>83.3 MB</td><td>46.9 MB</td><td>47.0 MB</td></tr>
    </tbody>
  </table>
  <p>
    <code>countBy</code>와 직접 루프는 <strong>같은 메모리</strong>를
    씁니다 — 모든 규모에서 0.1 MB 이내로요. 둘 다 정수 카운터 네 개
    말고는 아무것도 들고 있지 않기 때문입니다. 반면
    <code>groupListsBy</code>는 길이만 재려고 백만 건 전부를 레벨별
    <code>List</code>로 실체화하고, N=1,000,000에서 그것은 할당해야 할,
    그리고 수집기가 훑어야 할 36 MB의 쓰레기입니다.
  </p>
  <p>
    그 세금은 <em>들쭉날쭉함</em>도 만듭니다. N=1,000,000에서 25개
    표본에 걸쳐 <code>groupListsBy</code>는 42.1–49.5 ms,
    FxDart는 40.3–42.2 ms였습니다. 최고 기록끼리는 사실상 무승부이고,
    중앙값에서 지는 이유는 FxDart는 유발하지 않는 수집을 가끔 하기
    때문입니다. 약 200,000을 넘어서의 승리는 더 빠른 파이프라인이
    아니라 쓰레기가 없다는 사실입니다.
  </p>
  <p>
    그리고 N=10,000에서의 패배도 그만큼 정직합니다: 345 µs에 대해
    415 µs면 70 µs 차이입니다 — 실재하지만 하네스의 0.6 ms 문턱
    아래이고, 그래서 위 막대는 여전히 <em>무승부</em>로 읽힙니다.
    70 µs를 느낄 수 있는 사람은 없습니다.
  </p>
  <p>
    그러니 공정한 요약은 이렇습니다:
    <strong><code>countBy</code>는 직접 루프의 메모리 프로파일을 이름
    붙은 연산자의 가독성과 함께, 직접 루프의 약 1.4× 시간에
    줍니다.</strong> 그 거래가 값어치를 하는지는 숫자가 아니라 여러분
    코드에 대한 판단입니다 — 다만 데이터가 커지면 관용적인
    <code>package:collection</code> 한 줄짜리를 두 축 모두에서 이기고,
    36 MB를 치르게 하는 일은 결코 없습니다.
  </p>
  <div class="callout">
    <strong>측정 방법:</strong> 벤치마크 섹션에 적힌 것과 같은
    머신에서 — 규모별·구현별로 5회 교차 라운드 × 5회 측정 반복 = 25개
    표본, AOT 컴파일, 표본마다 새 프로세스, 중앙값 보고. 세 구현 모두
    모든 규모에서 동일한 체크섬을 반환합니다.
  </div>
