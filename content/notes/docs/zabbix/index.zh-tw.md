---
title: Zabbix docs
weight: 100
menu:
  notes:
    name: zabbix
    identifier: notes-zabbix-docs
    parent: notes-docs
    weight: 10
---

{{< note title="send alert" >}}

1. Use Webhook, Create Channel and Webhook in Mattermost, and put script to $(grep AlertScriptsPath /etc/zabbix/zabbix_server.conf).
2. Create Media types in Zabbix(Administration -> Medai types).
3. Add media to user(Administration -> Users -> Media).
4. Create action(Configuration -> Actions -> Trigger actions)。
5. Debug(Write log in script).
   1. Media types:
      1. PROBLEM:\nProblem started at {EVENT.TIME} on {EVENT.DATE}\n 問題: {EVENT.NAME}\n 主機: {HOST.NAME}\nSeverity: {EVENT.SEVERITY}\n 目前數值: {EVENT.OPDATA}\n 問題 ID: {EVENT.ID}\n{TRIGGER.URL}
      2. RECOVERY:\nProblem has been resolved at {EVENT.RECOVERY.TIME} on {EVENT.RECOVERY.DATE}\n 問題: {EVENT.NAME}\n 持續時間: {EVENT.DURATION}\n 主機: {HOST.NAME}\nSeverity: {EVENT.SEVERITY}\n 問題 ID: {EVENT.ID}\n{TRIGGER.URL}

{{< /note >}}

{{< note title="zabbix server" >}}

###### /etc/zabbix/zabbix_server.conf

Zabbix Server perform high loading, and slow query. Increase ValueCacheSize solve this problem.

```ini
LogFile=/var/log/zabbix/zabbix_server.log
LogFileSize=5
PidFile=/var/run/zabbix/zabbix_server.pid
SocketDir=/var/run/zabbix
DBHost=localhost
DBName=zabbix_db
DBUser=zabbix_user
DBPassword=zabbix
DBSocket=/data/mysql/mysql.sock
StartPollers=200
StartPreprocessors=30
StartPollersUnreachable=30
StartTrappers=100
StartDiscoverers=30
SNMPTrapperFile=/var/log/snmptrap/snmptrap.log
CacheSize=4G
HistoryCacheSize=2G
HistoryIndexCacheSize=2G
TrendCacheSize=2G
ValueCacheSize=24G
Timeout=30
UnavailableDelay=120
AlertScriptsPath=/usr/lib/zabbix/alertscripts
ExternalScripts=/usr/lib/zabbix/externalscripts
LogSlowQueries=3000
StatsAllowedIP=127.0.0.1
```

###### /etc/my.cnf

```ini
[client-server]
socket=/data/mysql/mysql.sock

[mysqld]
socket=/data/mysql/mysql.sock
datadir=/data/mysql

character_set_server=utf8mb4
character_set_filesystem=utf8
max_allowed_packet=32M
event_scheduler=1
default_storage_engine=innodb
open_files_limit=65535
local_infile=1
sysdate_is_now=1
back_log=256
##error log format
# connection
interactive_timeout=28800
wait_timeout=28800
lock_wait_timeout=28800
skip_name_resolve=1
max_connections=2000
max_user_connections=1000
max_connect_errors=1000000

# table cache performance settings #
table_open_cache=8192
table_definition_cache=8192
table_open_cache_instances=16

# session memory settings #
read_buffer_size=131072
read_rnd_buffer_size=262144
sort_buffer_size=262144
tmp_table_size=67108864
join_buffer_size=8M
thread_cache_size=256

# log settings #
###slow log  ###
slow_query_log=1
log_queries_not_using_indexes=0
log_slow_admin_statements=1
#log_slow_slave_statements = 1
log_throttle_queries_not_using_indexes=1
long_query_time=0.5
log_bin_trust_function_creators=1

###binlog ###
binlog_cache_size=32K
max_binlog_cache_size=1G
max_binlog_size=2G
expire_logs_days=31
log_slave_updates=1
#binlog_format=STATEMENT
binlog_format=ROW
slave_compressed_protocol = 1
# innodb settings #
#innodb_data_file_path=ibdata1:4G;ibdata2:4G:autoextend
innodb_page_size=16384
innodb_buffer_pool_size=4G
innodb_buffer_pool_instances=1
innodb_buffer_pool_load_at_startup=1
innodb_buffer_pool_dump_at_shutdown=1
innodb_lock_wait_timeout=50
innodb_io_capacity=100
innodb_io_capacity_max=200
innodb_flush_neighbors=1
innodb_file_per_table=1
innodb_log_files_in_group=3
innodb_log_file_size=2G
innodb_log_buffer_size=33554432
innodb_purge_threads=2
innodb_large_prefix=1
innodb_thread_concurrency=64
innodb_print_all_deadlocks=1
innodb_strict_mode=1
innodb_sort_buffer_size=67108864
innodb_write_io_threads=4
innodb_read_io_threads=4
innodb_online_alter_log_max_size=1G
innodb_open_files=60000
innodb_max_dirty_pages_pct=75
innodb_adaptive_flushing=on
innodb_flush_log_at_trx_commit=1

sync_binlog =1

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
#
# include *.cnf from the config directory
#
!includedir /etc/my.cnf.d
```

{{< /note >}}
