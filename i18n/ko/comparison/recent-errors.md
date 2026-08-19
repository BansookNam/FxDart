---
slug: recent-errors
title: 최근 오류 메시지, 중복 제거 — Dart vs FxDart
description: 최신순 로그에서 가장 최근의 서로 다른 오류 3개를 추출합니다 — 순수 Dart의 seen-Set 루프와 break 대 FxDart의 filter + uniqBy + take를 비교합니다.
heading: 최근 오류 메시지, 중복 제거
order: 20
tier: 2
functions: filter, uniqBy, take
domain: logs
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    로그 저장소는 항목을 최신순으로 반환합니다. <strong>가장 최근의 서로
    다른 오류 메시지 세 개</strong>를 표시하세요: <code>ERROR</code> 항목만
    남기고, 이미 표시한 메시지의 반복은 제거하고, 세 개가 되면 멈춥니다.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    Dart에는 "키 기준 distinct"가 없습니다 — 메시지 기준으로 중복을
    제거하려면 <code>Set</code>을 직접 관리해야 하므로, 네이티브 버전은
    세 가지 관심사가 얽힌 루프가 됩니다: 레벨 확인, <code>seen.add</code>
    트릭, 그리고 개수를 세는 <code>break</code>. 각각은 그 자체로는
    문제없지만, 함께 있으면 무엇을 남기는지 알기 위해 루프 전체를 읽어야
    합니다. FxDart는 이 세 가지 규칙을 체인의 세 단계 —
    <code>filter</code>, <code>uniqBy</code>, <code>take</code> — 로
    표현하며, 체인이 지연 평가되므로 세 번째 서로 다른 오류를 찾는 즉시
    로그 스캔을 멈춥니다. 손으로 작성한 <code>break</code>와 정확히
    동일하게 동작합니다.
  </p>

  <h2>FxDart의 두 가지 표현</h2>
  <p>
    이 페이지의 벤치마크에는 다른 비교 페이지에 없는 <strong>세 번째
    막대</strong>가 있습니다. 위의 체인이 기본으로 쓸 형태입니다 — 세 규칙이
    위에서 아래로 읽히고, 지연 평가라서 세 번째 서로 다른 오류를 찾는 순간
    스캔을 멈춥니다. 손으로 쓴 <code>break</code>와 똑같습니다. 다만 이
    형태가 못 하는 것이 하나 있습니다: 자기 콜백을 인라인하지 못합니다.
    지연 단계는 클로저를 이터레이터의 필드에 담아 두는데 AOT 컴파일러는
    필드 너머를 보지 못하므로, <code>filter</code>와 <code>uniqBy</code>가
    원소마다 실제 간접 호출을 한 번씩 냅니다. 이 파이프라인과 네이티브
    루프를 갈라놓는 것의 대부분이 그 두 호출입니다.
  </p>
  <p>
    FxDart 패널의 <code>main</code> 위에 있는 <code>takeUniqBy</code>는 같은
    파이프라인을 하나의 즉시(strict) 호출로 쓴 것입니다. 콜백이 호출자에
    인라인될 만큼 작은 본문의 <em>매개변수</em>라서, 컴파일러가 클로저 본문을
    함께 인라인합니다. 콜백 하나가 두 일을 겸하며, 키가 <code>null</code>이면
    "이 원소는 건너뛴다"는 뜻입니다. 로그 100만 줄에서 두 번째 막대와 세 번째
    막대의 차이가 바로 그것이고, 첫 번째 막대가 네이티브 루프입니다.
  </p>
  <p>
    기본은 체인으로 쓰십시오. 파이프라인이 뜨거운 경로에 있고 프로파일이 이
    콜백들을 지목할 때 <code>takeUniqBy</code>를 꺼내면 됩니다.
  </p>
