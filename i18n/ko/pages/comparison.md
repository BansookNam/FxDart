---
slug: comparison
title: Dart vs FxDart — 실전 과제로 나란히 비교하기
description: 실전 과제 50개를 순수 Dart와 FxDart로 각각 두 번씩 풀어봅니다. 두 코드는 브라우저에서 바로 실행할 수 있고, 어느 쪽이 더 읽기 좋은지 정직한 판정을 함께 제공합니다.
---
  <h1>Dart vs FxDart</h1>
  <p class="hero-sub">
    같은 실전 과제를 두 번 풉니다: 왼쪽은 순수 Dart, 오른쪽은 FxDart입니다.
    두 버전 모두 브라우저에서 바로 실행되며 정확히 같은 출력을 인쇄합니다 —
    직접 비교하고 판단해 보세요.
  </p>

  <p>
    목록을 보기 전에 한 가지는 정직하게 짚고 넘어가겠습니다: Dart의 내장
    <code>Iterable</code>은 이미 지연 평가되며, 단순한
    <code>where</code>/<code>map</code> 체인은 그 자체로 훌륭한 Dart 코드입니다.
    FxDart는 이런 코드를 이기려고 있는 게 아닙니다. FxDart가 더하는 것은
    <strong>어휘</strong>
    (<code><a href="../tutorials/groupBy.html">groupBy</a></code>,
    <code><a href="../tutorials/chunk.html">chunk</a></code>,
    <code><a href="../tutorials/zip.html">zip</a></code>,
    <code><a href="../tutorials/scan.html">scan</a></code>,
    <code><a href="../tutorials/uniqBy.html">uniqBy</a></code>,
    <code><a href="../tutorials/partition.html">partition</a></code> —
    기본 Dart로는 직접 손으로 구현해야 하는 것들입니다),
    <strong>조합</strong>(중첩 호출과 중간 변수 대신 타입이 있는
    <code><a href="../tutorials/fx.html">fx()</a></code> 체인 하나로 표현하기),
    그리고 무엇보다 <strong>동시성 제어</strong>입니다 —
    <code><a href="../tutorials/concurrent.html">.concurrent(n)</a></code>는
    비동기 파이프라인을 한 번에 n개씩, 순서를 유지하며 실행합니다. 이는
    순수 Dart로는 수작업 워커 풀로만 근접하게 흉내 낼 수 있는 부분입니다.
    각 예제에는 판정 배지가 붙어 있고, 그중 일부는 네이티브 Dart로도
    충분하다고 말합니다. 바로 그 점이 핵심입니다: 어떤 예제가 정말 FxDart가
    낫다고 말할 때는, 그 말을 믿을 수 있습니다.
  </p>

  <p>
    <span class="badge verdict-fxdart">FxDart 승</span> — 이 경우는 명확히 더 낫습니다 ·
    <span class="badge verdict-tie">우열 없음</span> — 둘 다 좋아서 취향껏 고르면 됩니다 ·
    <span class="badge verdict-native">네이티브로 충분</span> — 순수 Dart로도 잘 처리됩니다 ·
    <span class="badge badge-async">async</span> — 비동기 파이프라인을 사용합니다
  </p>
