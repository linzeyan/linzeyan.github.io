---
title: "Synology：一眼查看 NAS RAM 細節"
date: 2023-05-08T10:55:23+08:00
menu:
  sidebar:
    name: "Synology：一眼查看 NAS RAM 細節"
    identifier: synology-nas-ram-details
    weight: 10
tags: ["Links", "Synology", "NAS"]
categories: ["Links", "Synology", "NAS"]
---

- [Synology：一眼查看 NAS RAM 細節](https://mariushosting.com/synology-your-nas-ram-details-at-a-glance/)

### step1

Control Panel / Task Scheduler / Create / Scheduled Task / User-defined script

### step2

1. General：在 Task 欄位輸入 RAM Details，取消勾選 "Enabled"，選擇 root 使用者。
2. Schedule：選擇 Run on the following date，並設定為 "Do not repeat"。
3. Task Settings：勾選 "Send run details by email"，填入 email，將下方指令貼到 Run command 區域，然後按 OK。
