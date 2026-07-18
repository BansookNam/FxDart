---
slug: index
title: FxDart — Dart のための関数型プログラミング
description: FxDart は FxTS から移植された Dart 向けの関数型プログラミングライブラリです。遅延評価、並行非同期イテレーション、パイプライン形式の合成を提供します。
---
  <p class="hero-logo"><img src="assets/logo-web.png" width="960" height="294"
      alt="FxDart"></p>
  <h1>遅延評価と並行処理を備えた、<br>Dart のための関数型プログラミング。</h1>
  <p class="hero-sub">
    FxDart は <a href="https://github.com/marpple/FxTS">FxTS</a> の Dart 移植版です。
    同期・非同期データに対する<strong>遅延パイプライン</strong>を合成するためのライブラリで、
    1秒かかるリクエスト6回の逐次処理を2秒の並行バッチに変えるのに
    必要なのはメソッド呼び出し1つだけです。
  </p>

  {{playground:0}}
  <p class="dim">▲ これは実際に動きます。コードを編集して <strong>Run</strong> を押してください。
    本物の Dart コンパイラでコンパイルされ、ブラウザ上で実行されます。</p>

  <h2>FxDart とは？</h2>
  <p>
    FxDart は FxTS のプログラミングモデルを Dart にもたらします。コレクションと非同期データを
    変換するための、小さく合成可能な約120個の関数のツールキットです。
    3つの考え方がその核にあります。
  </p>
  <ul>
    <li><strong>遅延評価</strong> — <code>map</code>、<code>filter</code>、
      <code>take</code> といった演算子はパイプラインを組み立てるだけで、
      終端演算子（<code>toArray</code>、<code>each</code>、
      <code>reduce</code> など）が値を引き出すまで何も処理しません。100万要素の
      range を <code>.take(3)</code> で処理すると、計算されるのはちょうど3件です。</li>
    <li><strong>同期と非同期で同一のモデル</strong> — 同じ演算子名が素の
      <code>Iterable</code> でも、FxDart のプル型非同期シーケンスである
      <code>FxAsyncIterable</code> でも動作します（<code>Stream</code> との
      相互変換も可能です）。</li>
    <li><strong>宣言的な並行処理</strong> — <code>concurrent(n)</code> は
      <em>上流</em>のパイプラインに対して、順序を保ったまま <code>n</code> 件ずつ
      評価するよう要求します。FxTS を代表する機能であり、
      Dart に忠実に移植されています。</li>
  </ul>

  <h2>なぜ必要なのか？</h2>
  <p>
    Dart には既に <code>Iterable</code> と <code>Stream</code> があります。FxDart が
    真価を発揮するのは、それらでは手が届かない領域です。
  </p>
  <table>
    <tr><th>課題</th><th>素の Dart</th><th>FxDart</th></tr>
    <tr>
      <td>API 呼び出しの並行数を <em>n</em> に制限しつつ順序を保つ</td>
      <td>手作業のキュー、<code>Completer</code>、緻密な管理</td>
      <td><code>.map(fetch).concurrent(3)</code></td>
    </tr>
    <tr>
      <td>非同期の変換パイプライン</td>
      <td><code>Stream</code> はプッシュ型。<code>await</code>、バックプレッシャー、遅延評価を混在させると複雑になる</td>
      <td>プル型のチェーン — 各値は要求されたときにだけ計算される</td>
    </tr>
    <tr>
      <td>データ加工（group、index、count、partition、zip、chunk など）</td>
      <td>その都度ループを手書き</td>
      <td>概念ごとに十分にテストされた名前付き関数が1つ</td>
    </tr>
    <tr>
      <td>読みやすい多段変換</td>
      <td>ネストした呼び出しや中間変数</td>
      <td>左から右へ読める <code>fx()</code> チェーン、完全に型付き</td>
    </tr>
  </table>

  <h2>長所 &amp; 短所</h2>
  <div class="proscons">
    <div class="box pros">
      <h3>✓ 長所</h3>
      <ul>
        <li><strong>遅延評価が標準</strong> — パイプラインは短絡評価され、要求された値だけが計算されます。</li>
        <li><strong>順序を保つ並行処理</strong>が演算子1つで実現できます: <code>concurrent(n)</code>、完了順なら <code>concurrentPool(n)</code>。</li>
        <li><strong>完全に型付きのチェーン</strong> — <code>fx()</code> は端から端まで型推論を維持します。同期演算子はネイティブの <code>Iterable</code> に対する素の関数なので、通常の Dart とそのまま相互運用できます。</li>
        <li><strong>小さく目的の明確な関数群</strong> — 変換 / フィルタ / スライス / 結合 / 集約 / オブジェクト / ユーティリティを網羅する約120個の演算子。</li>
        <li><strong>実績あるセマンティクス</strong> — FxTS から挙動を移植し、そのテスト850件以上も併せて移植しています。</li>
        <li><strong>依存関係ゼロ</strong> — 純粋な Dart のみ。</li>
      </ul>
    </div>
    <div class="box cons">
      <h3>✗ 短所</h3>
      <ul>
        <li><strong>データラストのカリー化がない</strong> — Dart には関数オーバーロードがないため、FxTS のカリー化された <code>pipe</code> スタイルはチェーンになります。動的な <code>pipe()</code> は静的型を失います。</li>
        <li><strong>非同期の抽象がもう1つ増える</strong> — <code>Stream</code> では並行処理のバックチャネルを表現できないため <code>FxAsyncIterable</code> が存在します。相互変換は簡単ですが、学ぶべき概念が1つ増えます。</li>
        <li><strong>学習コスト</strong> — 遅延パイプラインで考えることは、命令的なループとは異なります。</li>
        <li><strong>常に最速とは限らない</strong> — ごく小さなホットループでは、手書きの <code>for</code> が演算子の合成より速いことがあります。FxDart は明快さと I/O バウンドな処理に最適化しています。</li>
        <li><strong>そのまま移植できない TS API もある</strong> — それらは Dart らしい書き方に置き換えられています: <code>curry</code> は型付きの <a href="tutorials/curried.html"><code>.curried</code></a> 拡張ゲッターになり、旧来の名前は移行用に非推奨スタブとして残されています。</li>
      </ul>
    </div>
  </div>

  <h2>並行処理を体験する</h2>
  <p>300&nbsp;ms かかる疑似リクエストを6回 — 逐次なら約1.8&nbsp;秒、
    <code>concurrent(3)</code> なら約0.6&nbsp;秒です。数字を変えて試してみてください:</p>
  {{playground:1}}

  <h2>学習を始める</h2>
  <div class="grid">
    <a class="card" href="101/index.html">
      <h3>FxDart 101 →</h3>
      <p>講義、ライブデモ、そして全関数のプレイグラウンドを備えたガイド付きコース。</p>
    </a>
    <a class="card" href="tutorials/map.html">
      <h3>最初のレッスン: map →</h3>
      <p>最も基本的な演算子から始めましょう。</p>
    </a>
    <a class="card" href="https://github.com/bansooknam/fxDart">
      <h3>インストール →</h3>
      <p>fxdart を pubspec に追加し、ソースコードを見てみましょう。</p>
    </a>
  </div>
