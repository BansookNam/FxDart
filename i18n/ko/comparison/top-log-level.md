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
