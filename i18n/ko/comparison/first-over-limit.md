---
slug: first-over-limit
title: 한계를 처음 넘긴 센서 측정값 — Dart vs FxDart
description: 기준값을 넘는 첫 온도를 찾습니다 — 순수 Dart의 skipWhile + firstOrNull과 FxDart의 dropWhile + head를 비교합니다.
heading: 한계를 처음 넘긴 센서 측정값
order: 10
tier: 1
functions: dropWhile, head
domain: sensors
verdict: native
async: false
---
  <h2>요구사항</h2>
  <p>
    온도 센서가 10분마다 측정값을 기록합니다. <strong>75.0 C</strong>
    한계를 넘는 <strong>첫 번째</strong> 측정값을 찾아 시각과 값을
    출력하세요 — 넘은 값이 없다면 대체 문구를 출력합니다. 데이터는
    아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    둘은 다르지 않습니다 — 그리고 여기서는 순수 Dart가 정직한
    선택입니다. Dart 코어의 <code>skipWhile</code>과
    <code>package:collection</code>의 <code>firstOrNull</code>을 조합한
    코드는 뜻을 그대로 말하는 깔끔한 지연 평가 한 줄이며, null 가능
    결과 처리도 동일합니다. FxDart의 <code>dropWhile → head</code>는
    같은 아이디어를 FxTS 이름으로 표현한 것일 뿐입니다 — 파일의
    나머지가 이미 FxDart 체인이라면 쓸 만하지만, 이 한 줄만을 위해
    라이브러리를 추가해야 할 사람은 없을 것입니다. 네이티브 Dart가
    이길 때는, 그렇다고 솔직히 말합니다.
  </p>
