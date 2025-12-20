---
title: "Excessive Errors from `sentry.lang.javascript.processor: SoftTimeLimitExceeded()`"
date: 2019-07-25T14:25:56+08:00
menu:
  sidebar:
    name: "Excessive Errors from `sentry.lang.javascript.processor: SoftTimeLimitExceeded()`"
    identifier: github-issue-getsentry-sentry-issues-4386
    weight: 10
tags: ["URL", "Sentry"]
categories: ["URL", "Sentry"]
---

- [Excessive Errors from `sentry.lang.javascript.processor: SoftTimeLimitExceeded()`](https://github.com/getsentry/sentry/issues/4386)
- [Counters-0 queue is rising continuously](https://forum.sentry.io/t/counters-0-queue-is-rising-continuously/5655/6)

#### Excessive Errors from `sentry.lang.javascript.processor: SoftTimeLimitExceeded()`

mattrobenolt:

Was just going to propose this. :) Unfortunately, this is just how this feature works. If it's not useful and is just wasting resources, it's easy to disable globally by setting `SENTRY_SCRAPE_JAVASCRIPT_CONTEXT = False` in your `sentry.conf.py` or per project in the UI.

Other than that, there's not much else we can do here since the feature is effectively working as intended.

---

#### Counters-0 queue is rising continuously

matt:

You need more workers on this queue to process the load.

You can run workers dedicated to a certain queue too that might help, doing `sentry run worker -Q counters-0`
