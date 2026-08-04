---
slug: feeds-in-order
title: 두 피드를 엄격히 순서대로 — RxDart vs FxDart
description: 어제 로그의 꼬리 뒤에 오늘 로그를 이어 번호 목록 하나로 — 구독을 순서대로 세우는 concatWith vs pull을 순서대로 세우는 concat.
heading: 두 피드를 엄격히 순서대로
order: 18
tier: 2
functions: fx, concat, map
domain: logs
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    인시던트 리뷰에는 <strong>어제</strong> 로그의 꼬리 뒤에
    <strong>오늘</strong> 로그가 이어지는 번호 목록 하나가 필요합니다 —
    오늘의 첫 항목이 어제의 마지막 항목보다 먼저 나타나서는 안 됩니다.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    두 라이브러리 모두 "이 피드 다음에 저 피드"를 연산자 하나로 쓰지만,
    각 모델은 자기만의 메커니즘으로 순서를 보장합니다. RxDart의
    <code>concatWith</code>는 <em>구독</em> 시퀀서입니다: 어제의 스트림이
    <code>done</code>을 쏘기 전까지 오늘의 스트림을 구독하지 않으므로, 두
    소스가 모두 살아 있고 오늘 쪽이 먼저 내보낼 준비가 되어 있었더라도
    순서는 지켜집니다. FxDart의 <code>concat</code>은 <em>수요</em>
    시퀀서입니다: 체인은 첫 이터러블이 소진된 뒤에야 두 번째에서
    끌어오고, 인메모리 리스트 두 개라면 마련할 순서 보장은 그것이
    전부입니다.
  </p>
  <p>
    그 메커니즘 격차는 소스가 정말 push로 구동될 때 정확히 중요해집니다
    — 구독되는 순간 내보내기 시작하는 스트림에는 <code>concatWith</code>의
    지연된 구독이 필요하고, pull 파이프라인이라면 아직-원하지-않는
    피드를 먼저 버퍼링해야 했을 것입니다. 고정 데이터 위에서 둘은 같은
    일곱 줄과 같은 <code>map</code>으로 수렴합니다. 무승부: 연산자는 공유
    어휘이고, 각 모델은 이미 갖고 있던 도구로 그것을 구현합니다.
  </p>
