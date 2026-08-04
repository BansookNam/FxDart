---
slug: tee
title: tee — FxDart 101
description: FxDart tee 튜토리얼: 소스를 한 번만 순회하면서 두세 개의 폴드를 동시에 굴립니다. 버퍼링 없음, 라이브 플레이그라운드 포함.
heading: <code>tee</code>
section: 6
crumb: tee
prev: fork.html
prevLabel: fork
next: tee3.html
nextLabel: tee3
---
  <p class="hero-sub">한 번의 순회로 여러 개의 폴드를 굴립니다 — 반복은 한 번, 버퍼는 없음.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    같은 데이터에 대한 두 개의 질문은 보통 두 번의 순회를 요구합니다.
    합계는 <code>readings.fold(...)</code>로, 최댓값은
    <code>readings.reduce(...)</code>로. <code>List</code>라면 괜찮지만,
    그 외의 것에는 잘못된 방식입니다 — <code>sync*</code> 제너레이터,
    네트워크 페이지, 몇 번 실행됐는지 세는 소스는 모두 두 번 순회됩니다.
    <code>tee</code>는 두 질문을 한꺼번에 던집니다. 다음 원소를 당기기
    전에 각 원소가 합계 <em>와</em> 최댓값을 모두 전진시키므로, 소스는
    정확히 한 번만 순회됩니다.
  </p>
  <p>
    리더는 <strong>폴드</strong>로 주어집니다 — 어디서 시작하는지를
    나타내는 <code>seed</code>와, 원소 하나가 그것을 어떻게 전진시키는지를
    나타내는 <code>step</code>의 레코드입니다. 바로 이 모양이 한 번의
    순회를 공짜로 만듭니다. 두 리더가 원소 단위로 함께 움직이므로, 한쪽은
    봤는데 다른 쪽은 못 본 값이란 존재하지 않고, 따라서 기억해 둘 것도
    없습니다. 원소가 백만 개여도 <code>tee</code>가 들고 있는 것은 백만
    개의 값이 아니라 두 개의 누산기뿐입니다. 두 누산기는 완전히 독립적이며
    타입이 같을 필요도 없습니다. <a href="tee3.html"><code>tee3</code></a>는 세 개를 받습니다.
  </p>
  <p>
    그 대가가 제약입니다. <code>tee</code>가 먹이는 것은 폴드이지
    파이프라인이 아닙니다 — 리더들은 각자의 속도로 전진하거나, 서로 다른
    개수만 가져가거나, 따로 일찍 멈출 수 없습니다. 정말로 <em>독립적인</em>
    리더 둘이 필요하다면 <a href="fork.html"><code>fork</code></a>를
    쓰고, 뒤처진 커서가 따라올 수 있도록 유지되는 공유 버퍼를 감수하세요.
    기준은 이렇습니다: 두 리더가 모두 소스를 끝까지 소비해서 하나의 값으로
    줄인다면 <code>tee</code>, 둘 중 하나라도 그 자체로 파이프라인이라면
    <code>fork</code>.
  </p>

  <h2>이름의 유래</h2>
  <p>
    <code>tee</code>는 약어가 아니라 알파벳 <strong>T</strong>
    자체입니다. 배관에서 쓰는 T-스플리터에서 온 이름이죠. T자 이음쇠는
    파이프 하나를 둘로 갈라, 한 방향으로 흐르던 것이 동시에 두 방향으로
    나가게 합니다. Unix는 이 이미지를 그대로 가져와 <code>tee</code>
    명령어를 만들었습니다. 표준 입력을 읽어 표준 출력<em>과</em> 파일로
    동시에 보내죠:
  </p>
  <pre><code>       입력
        │
        ▼
    ┌───┴───┐
    │  tee  │
    └───┬───┘
   ┌────┴────┐
   ▼         ▼
  표준출력   파일</code></pre>
  <p>
    Python의 <code>itertools.tee()</code>도 같은 그림에서 이름을 빌려,
    하나의 이터러블을 여러 개의 독립적인 이터레이터로 갈라 줍니다. 알아
    둘 만한 점은, 그쪽이 바로 FxDart가
    <a href="fork.html"><code>fork</code></a>라고 부르는 것이지
    <code>tee</code>가 아니라는 것입니다. <code>fork</code>는 Python의
    것처럼 독립적인 커서를 주고, FxDart의 <code>tee</code>는 대신
    <em>소비</em>를 가릅니다 — 한 번의 순회를 여러 폴드가 보폭을 맞춰
    읽는 것이죠. 같은 T자 그림을, 한 단계 더 하류에서 가른 셈입니다.
  </p>

  <h2>데모 1 · 한 번 읽어서 얻는 합계와 최댓값</h2>
  <p>
    <code>sensor()</code>는 값을 내놓을 때마다 <code>reads</code>를
    증가시킵니다. 따로 두 번 순회했다면 <code>reads</code>는 12가 되지만,
    <code>tee</code>는 6에서 멈춥니다:
  </p>
  {{playground:0}}

  <h2>데모 2 · 독립적인 누산기, tee3, 그리고 체인 위에서</h2>
  <p>
    두 폴드는 서로 무관한 타입을 나릅니다 — <code>int</code> 문자 수와
    <code>String</code> 현재 우승자가 나란히 갑니다. <code>tee3</code>는
    세 번째 폴드를 더하고, <code>fx</code> 체인 위에서 폴드들은 원래
    소스가 아니라 <em>체인</em>이 만들어 내는 것을 봅니다:
  </p>
  {{playground:1}}

  <h2>직접 해보기</h2>
  <p>
    연습: 지금은 <code>sensor()</code>를 두 번 순회하고 있어서
    <code>reads</code>가 6을 출력합니다. 두 번의 순회를 하나의
    <code>tee</code>로 바꿔 — 한 폴드에서 합계를, 다른 폴드에서 개수를
    세도록 — <code>reads</code>가 3을 출력하게 만드세요.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="fork.html"><code>fork</code></a> — 버퍼를 대가로 한 독립 리더 ·
    <a href="reduce.html"><code>reduce</code></a> — 폴드 하나 ·
    <a href="groupBy.html"><code>groupBy</code></a> — 값을 키로 하는 여러 누산기
  </div>
