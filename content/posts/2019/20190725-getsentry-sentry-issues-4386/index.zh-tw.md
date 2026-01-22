---
title: "`sentry.lang.javascript.processor: SoftTimeLimitExceeded()` 大量錯誤"
date: 2019-07-25T14:25:56+08:00
menu:
  sidebar:
    name: "`sentry.lang.javascript.processor: SoftTimeLimitExceeded()` 大量錯誤"
    identifier: github-issue-getsentry-sentry-issues-4386
    weight: 10
tags: ["Links", "Sentry"]
categories: ["Links", "Sentry"]
---

- [Excessive Errors from `sentry.lang.javascript.processor: SoftTimeLimitExceeded()`](https://github.com/getsentry/sentry/issues/4386)
- [Counters-0 queue is rising continuously](https://forum.sentry.io/t/counters-0-queue-is-rising-continuously/5655/6)

#### `sentry.lang.javascript.processor: SoftTimeLimitExceeded()` 大量錯誤

mattrobenolt:

我正打算提出這個。:) 很不幸，這個功能就是如此運作。如果它沒有用且只是浪費資源，可以很容易地全域關閉：在 `sentry.conf.py` 設定 `SENTRY_SCRAPE_JAVASCRIPT_CONTEXT = False`，或在 UI 內針對專案關閉。

除此之外，沒有太多能做的，因為這個功能本質上是按設計運作。

---

#### Counters-0 佇列持續上升

matt:

你需要更多 worker 來處理這個佇列的負載。

你也可以讓 worker 專門處理特定佇列，例如使用 `sentry run worker -Q counters-0`。
