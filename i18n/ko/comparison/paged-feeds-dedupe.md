---
slug: paged-feeds-dedupe
title: 두 페이징된 피드를 이어붙이고 중복 제거하기 — Dart vs FxDart
description: 기본 로그 저장소를 먼저 소진한 뒤 복제본을 읽고, id로 중복을 제거하며 8개에서 멈춥니다 — concat + uniqBy + take는 지연 상태를 유지하지만, 네이티브는 seen 집합을 쓰는 중첩 루프가 필요합니다.
heading: 두 페이징된 피드를 이어붙이고 중복 제거하기
order: 41
tier: 4
functions: range, toAsync, flatMap, concat, uniqBy, take
domain: logs
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    로그 이벤트는 두 개의 페이징된 저장소 — 기본 저장소와, 페이지가 서로
    겹치는 복제본(일부 이벤트는 양쪽 모두에 전송됨) — 에 존재합니다. 세
    개씩 페이지 단위로 가져오되(아래 코드에 있는 시뮬레이션 호출과 고정
    데이터), 기본 저장소를 <em>먼저 전부</em> 읽은 다음 복제본을 읽고,
    이미 본 이벤트는(id 기준으로) 버리며, 처음 <strong>고유한 이벤트
    여덟 개</strong>를 모으면 멈추세요. 다섯 페이지 중 실제로 몇 페이지를
    가져왔는지 보고하세요.
  </p>
  <p>
    FxDart의 <code>concat</code>이 정확히 무엇인지 짚어두면: 이것은
    병합이 아니라 <strong>순차적인</strong> 이어붙이기입니다 — 기본
    저장소가 소진되기 전까지는 복제본을 건드리지 않습니다. 이 작업은
    기본 저장소의 이벤트를 우선시해야 하므로 정확히 맞는 도구입니다. 각
    저장소는 <code>range</code> + <code>flatMap</code>(페이지 번호 →
    이벤트 페이지)으로 비동기 시퀀스가 되고, <code>uniqBy</code> +
    <code>take(8)</code>가 나머지를 마무리합니다. 체인이 풀 기반이기
    때문에 <code>take</code>가 멈추면 페이징도 함께 멈춥니다: 복제본의
    마지막 페이지는 결코 가져오지 않습니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    네이티브 버전은 <code>seen</code> 집합과 레이블이 붙은
    <code>break outer;</code>를 사용하는 세 겹 중첩 루프입니다 — 모든
    요소(페이징, 순서, 중복 제거, 조기 종료)가 제어 흐름 안에 손으로
    엮여 있고, 조기 종료 부분이 페이지 수를 넷으로 유지하는 역할을
    합니다. 동작은 하지만, 각 정책이 이름이 아니라 가드 절 안에
    숨어 있습니다. FxDart 체인은 각 정책에 저마다의 이름을 붙여줍니다 —
    순서를 위한 <code>concat</code>, 중복 제거를 위한 <code>uniqBy</code>,
    개수 제한을 위한 <code>take</code> — 그리고 다섯 번째 페이지를
    건너뛰는 지연 평가는 신중하게 배치한 점프가 아니라 파이프라인의
    기본 동작입니다.
  </p>
