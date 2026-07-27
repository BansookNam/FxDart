---
slug: parallel-downloads
title: 병렬 다운로드, 순서대로 결과 받기 — Dart vs FxDart
description: 속도가 제각각인 다운로드 여섯 개를 한 번에 세 개씩 — concurrent는 완료 순서가 뒤섞여도 요청 순서를 유지하지만, 네이티브는 풀 관리가 필요합니다.
heading: 병렬 다운로드, 순서대로 결과 받기
order: 46
tier: 4
functions: toAsync, map, concurrent, zipWithIndex, join, sumBy
domain: general
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    파일 여섯 개를 다운로드하세요 — 각각 고정된 크기와 고정된(시뮬레이션된)
    전송 시간을 가지며, 아래 코드에 있습니다 — 동시에 최대
    <strong>세 개까지만 진행 중</strong>이도록 하고, 결과를
    <strong>요청 순서대로</strong> 번호를 매겨 나열하세요. 완료 순서가
    뒤섞이도록 지연 시간이 선택되어 있습니다: 30&nbsp;ms 걸리는
    <code>video.mp4</code>가 먼저 요청되지만 10&nbsp;ms 걸리는
    <code>notes.txt</code>가 먼저 끝납니다. 두 버전 모두 어떤 파일이
    가장 먼저 끝났는지와 관측된 최대 동시성을 출력합니다 — 작업이
    순서 없이 실제로 겹쳐 진행되었으면서도 목록은 순서대로 유지되었음을
    증명합니다.
  </p>
  <p>
    내부적으로는 순서가 뒤섞이지만 겉으로는 순서가 유지되는 이 보장이
    바로 <code>concurrent(3)</code>이 하는 일입니다: 최대 세 개의 상류
    항목을 동시에 평가하면서도 결과는 원본 순서대로 산출합니다. 체인은
    <code>zipWithIndex</code>로 번호를 매기고 <code>join</code>으로
    보고서를 조립합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    <code>Future.wait</code>는 순서를 유지하지만 전부를 한꺼번에
    다운로드합니다 — 제한이 없습니다. 제한을 추가하는 순간 네이티브
    워커 풀이 필요해지고, 그 풀 아래에서 순서를 유지하는 것이 바로
    까다로운 부분입니다: 공유 커서로 인덱싱되는, 미리 크기를 정해둔
    <code>results</code> 리스트가 필요합니다. 슬롯 관리를 잘못하면
    결과가 뒤섞여서 돌아옵니다 — 완료 순서가 요청 순서와 우연히 달라질
    때만 드러나는 버그로, 타이밍에 좌우되어 테스트에서 놓치기
    쉽습니다. FxDart에서는 순서 보장이 여러분의 코드가 아니라 연산자의
    계약입니다: <code>concurrent(3)</code>은 타이밍이 어떻게 흐르든
    항목을 순서 밖으로 반환할 수 없습니다.
  </p>
