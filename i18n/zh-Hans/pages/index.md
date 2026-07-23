---
slug: index
title: FxDart —— 面向 Dart 的函数式编程库
description: FxDart 是从 FxTS 移植而来的 Dart 函数式编程库：惰性求值、并发异步迭代，以及管道式组合。
---
  <p class="hero-logo"><img src="{{root}}assets/logo-web.png" width="960" height="294"
      alt="FxDart"></p>
  <h1>面向 Dart 的函数式编程，<br>惰性与并发开箱即用。</h1>
  <p class="hero-sub">
    FxDart 是 <a href="https://github.com/marpple/FxTS">FxTS</a> 的 Dart 移植版本 ——
    一个用于在同步与异步数据上组合<strong>惰性管道</strong>的库，
    把六个各耗时 1 秒的串行请求变成 2 秒完成的并发批处理，
    只需一次方法调用。
  </p>

  <p>
    <a class="demo-cta" href="{{root}}DailyLedger/">
      <span class="demo-cta-emoji">📒</span>
      看看实际效果：Daily Ledger —— 用 FxDart 构建的完整应用&nbsp;→
    </a>
  </p>

  {{playground:0}}
  <p class="dim">▲ 这是可运行的 —— 修改代码并按下 <strong>运行</strong>。
    它会用真正的 Dart 编译器编译，并在你的浏览器中执行。</p>

  <h2>FxDart 是什么？</h2>
  <p>
    FxDart 把 FxTS 的编程模型带到了 Dart：一套约 120 个小而可组合的函数，
    用于变换集合与异步数据。它由三个核心理念定义：
  </p>
  <ul>
    <li><strong>惰性求值</strong> —— <code>map</code>、<code>filter</code>、
      <code>take</code> 这类操作符只构建管道，在终结操作符
      （<code>toList</code>、<code>each</code>、<code>reduce</code>……）
      拉取数据之前不做任何工作。对一个百万元素的范围调用
      <code>.take(3)</code>，只会计算 3 个结果。</li>
    <li><strong>同步与异步共用一套模型</strong> —— 同样的操作符名称既适用于普通的
      <code>Iterable</code>，也适用于 <code>FxAsyncIterable</code>，
      即 FxDart 基于拉取的异步序列（并提供双向的 <code>Stream</code>
      桥接）。</li>
    <li><strong>声明式并发</strong> —— <code>concurrent(n)</code>
      要求<em>上游</em>管道每次求值 <code>n</code> 个元素，
      同时保持结果有序。这是 FxTS 的标志性特性，
      已忠实移植到 Dart。</li>
  </ul>

  <h2>为什么需要它？</h2>
  <p>
    Dart 已经有 <code>Iterable</code> 和 <code>Stream</code>。FxDart 的价值，
    体现在它们力所不及的地方：
  </p>
  <table>
    <tr><th>问题</th><th>原生 Dart</th><th>FxDart</th></tr>
    <tr>
      <td>把并发 API 调用限制为 <em>n</em> 个，并保持顺序</td>
      <td>手写队列、<code>Completer</code>，以及繁琐的状态管理</td>
      <td><code>.map(fetch).concurrent(3)</code></td>
    </tr>
    <tr>
      <td>异步变换管道</td>
      <td><code>Stream</code> 是基于推送的；把 <code>await</code>、背压和惰性混在一起会变得复杂</td>
      <td>基于拉取的链式调用 —— 每个值只在被请求时才计算</td>
    </tr>
    <tr>
      <td>数据整理（分组、索引、计数、分区、zip、分块……）</td>
      <td>每次都要手写循环</td>
      <td>每个概念对应一个经过充分测试的具名函数</td>
    </tr>
    <tr>
      <td>可读的多步变换</td>
      <td>嵌套调用或中间变量</td>
      <td>从左到右的 <code>fx()</code> 链式调用，类型完备</td>
    </tr>
  </table>

  <h2>优点 &amp; 缺点</h2>
  <div class="proscons">
    <div class="box pros">
      <h3>✓ 优点</h3>
      <ul>
        <li><strong>免费获得惰性</strong> —— 管道会短路；只计算被请求的值。</li>
        <li><strong>保序的并发</strong>，一个操作符即可实现：<code>concurrent(n)</code> / 按完成顺序输出的 <code>concurrentPool(n)</code>。</li>
        <li><strong>类型完备的链式调用</strong> —— <code>fx()</code> 让类型推断贯穿始终；同步操作符就是作用于原生 <code>Iterable</code> 的普通函数，因此一切都能与常规 Dart 代码互操作。</li>
        <li><strong>小而专注的函数</strong> —— 约 120 个操作符，覆盖变换 / 过滤 / 切片 / 组合 / 聚合 / 对象 / 工具。</li>
        <li><strong>久经考验的语义</strong> —— 行为从 FxTS 移植而来，同时带来了它 850+ 个测试。</li>
        <li><strong>零依赖</strong> —— 纯 Dart 实现。</li>
      </ul>
    </div>
    <div class="box cons">
      <h3>✗ 缺点</h3>
      <ul>
        <li><strong>没有 data-last 柯里化</strong> —— Dart 不支持函数重载，因此 FxTS 柯里化的 <code>pipe</code> 风格在这里变成了链式调用；动态的 <code>pipe()</code> 会丢失静态类型。</li>
        <li><strong>多了一层异步抽象</strong> —— <code>FxAsyncIterable</code> 之所以存在，是因为 <code>Stream</code> 无法表达并发的反向通道；桥接很容易，但终究是一个需要额外学习的概念。</li>
        <li><strong>学习曲线</strong> —— 用惰性管道思考，与写命令式循环并不相同。</li>
        <li><strong>并非总是最快</strong> —— 对于极小的热点循环，手写 <code>for</code> 可能胜过操作符组合；FxDart 的优化目标是清晰度与 I/O 密集型场景。</li>
        <li><strong>部分 TS API 无法逐字移植</strong> —— 它们改用了更符合 Dart 习惯的写法：<code>curry</code> 变成了带类型的 <a href="tutorials/curried.html"><code>.curried</code></a> 扩展 getter，旧名称则作为已废弃的桩函数保留，便于迁移。</li>
      </ul>
    </div>
  </div>

  <h2>并发初体验</h2>
  <p>六个各耗时 300&nbsp;ms 的模拟请求 —— 串行约需 1.8&nbsp;s，使用
    <code>concurrent(3)</code> 约需 0.6&nbsp;s。试着改改这个数字：</p>
  {{playground:1}}

  <h2>开始学习</h2>
  <div class="grid">
    <a class="card" href="101/index.html">
      <h3>FxDart 入门 →</h3>
      <p>一门循序渐进的课程：讲解、实时演示，以及每个函数配套的 playground。</p>
    </a>
    <a class="card" href="tutorials/map.html">
      <h3>第一课：map →</h3>
      <p>从最基础的操作符开始。</p>
    </a>
    <a class="card" href="https://github.com/bansooknam/fxDart">
      <h3>安装 →</h3>
      <p>把 fxdart 加入你的 pubspec，并浏览源码。</p>
    </a>
  </div>
