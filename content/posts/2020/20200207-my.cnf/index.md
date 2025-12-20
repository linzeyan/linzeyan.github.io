---
title: "Percona config"
date: 2020-02-07T21:13:57+08:00
menu:
  sidebar:
    name: "Percona config"
    identifier: mysql-percona-config-record-in-bf
    weight: 10
tags: ["MySQL", "Percona"]
categories: ["MySQL", "Percona"]
---

```ini
# Percona Server template configuration


[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
port=3306
datadir=/data/mysql
socket=/data/mysql/mysql.sock
pid_file=/data/mysql/mysqld.pid


# 服务端编码
character_set_server=utf8mb4
# 服务端排序
collation_server=utf8mb4_general_ci
# 强制使用 utf8mb4 编码集，忽略客户端设置
skip_character_set_client_handshake=1
# 日志输出到文件
log_output=FILE
# 开启常规日志输出
general_log=1
# 常规日志输出文件位置
general_log_file=/var/log/mysql/mysqld.log
# 错误日志位置
log_error=/var/log/mysql/mysqld-error.log
# 记录慢查询
slow_query_log=1
# 慢查询时间(大于 1s 被视为慢查询)
long_query_time=1
# 慢查询日志文件位置
slow_query_log_file=/var/log/mysql/mysqld-slow.log
# 临时文件位置
tmpdir=/data/mysql_tmp
# 线程池缓存(refs https://my.oschina.net/realfighter/blog/363853)
thread_cache_size=30
# The number of open tables for all threads.(refs https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_table_open_cache)
table_open_cache=16384
# 文件描述符(此处修改不生效，请修改 systemd service 配置)
# refs https://www.percona.com/blog/2017/10/12/open_files_limit-mystery/
# refs https://www.cnblogs.com/wxxjianchi/p/10370419.html
#open_files_limit=65535
# 表定义缓存(5.7 以后自动调整)
# refs https://dev.mysql.com/doc/refman/5.6/en/server-system-variables.html#sysvar_table_definition_cache
# refs http://mysql.taobao.org/monthly/2015/08/10/
#table_definition_cache=16384
sort_buffer_size=1M
join_buffer_size=1M
# MyiSAM 引擎专用(内部临时磁盘表可能会用)
read_buffer_size=1M
read_rnd_buffer_size=1M
# MyiSAM 引擎专用(内部临时磁盘表可能会用)
key_buffer_size=32M
# MyiSAM 引擎专用(内部临时磁盘表可能会用)
bulk_insert_buffer_size=16M
# myisam_sort_buffer_size 与 sort_buffer_size 区别请参考(https://stackoverflow.com/questions/7871027/myisam-sort-buffer-size-vs-sort-buffer-size)
myisam_sort_buffer_size=64M
# 内部内存临时表大小
tmp_table_size=32M
# 用户创建的 MEMORY 表最大大小(tmp_table_size 受此值影响)
max_heap_table_size=32M
# 开启查询缓存
query_cache_type=1
# 查询缓存大小
query_cache_size=32M
# sql mode
sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'


########### Network ###########
# 最大连接数(该参数受到最大文件描述符影响，如果不生效请检查最大文件描述符设置)
# refs https://stackoverflow.com/questions/39976756/the-max-connections-in-mysql-5-7
max_connections=1500
# mysql 堆栈内暂存的链接数量
# 当短时间内链接数量超过 max_connections 时，部分链接会存储在堆栈内，存储数量受此参数控制
back_log=256
# 最大链接错误，针对于 client 主机，超过此数量的链接错误将会导致 mysql server 针对此主机执行锁定(禁止链接 ERROR 1129 )
# 此错误计数仅在 mysql 链接握手失败才会计算，一般出现问题时都是网络故障
# refs https://www.cnblogs.com/kerrycode/p/8405862.html
max_connect_errors=100000
# mysql server 允许的最大数据包大小
max_allowed_packet=64M
# 交互式客户端链接超时(30分钟自动断开)
interactive_timeout=1800
# 非交互式链接超时时间(10分钟)
# 如果客户端有连接池，则需要协商此参数(refs https://database.51cto.com/art/201909/603519.htm)
wait_timeout=600
# 跳过外部文件系统锁定
# If you run multiple servers that use the same database directory (not recommended),
# each server must have external locking enabled.
# refs https://dev.mysql.com/doc/refman/5.7/en/external-locking.html
skip_external_locking=1
# 跳过链接的域名解析(开启此选项后 mysql 用户授权的 host 方式失效)
skip_name_resolve=0
# 禁用主机名缓存，每次都会走 DNS
host_cache_size=0

ini




########### REPL ###########
# 开启 binlog
log_bin=mysql-bin
# 作为从库时，同步信息依然写入 binlog，方便此从库再作为其他从库的主库
log_slave_updates=1
# server id，默认为 ipv4 地址去除第一段
# eg: 172.16.10.11 => 161011
server_id=161011
# 每次次事务 binlog 刷新到磁盘
# refs http://liyangliang.me/posts/2014/03/innodb_flush_log_at_trx_commit-and-sync_binlog/
sync_binlog=100
# binlog 格式(refs https://zhuanlan.zhihu.com/p/33504555)
binlog_format=row
# binlog 自动清理时间
expire_logs_days=10
# 开启 relay-log，一般作为 slave 时开启
relay_log=mysql-replay
# 主从复制时跳过 test 库
replicate_ignore_db=test
# 每个 session binlog 缓存
binlog_cache_size=4M
# binlog 滚动大小
max_binlog_size=1024M
# GTID 相关(refs https://keithlan.github.io/2016/06/23/gtid/)
#gtid_mode=1
#enforce_gtid_consistency=1


########### InnoDB ###########
# 永久表默认存储引擎
default_storage_engine=InnoDB
# 系统表空间数据文件大小(初始化为 1G，并且自动增长)
innodb_data_file_path=ibdata1:1G:autoextend
# InnoDB 缓存池大小
# innodb_buffer_pool_size 必须等于 innodb_buffer_pool_chunk_size*innodb_buffer_pool_instances，或者是其整数倍
# refs https://dev.mysql.com/doc/refman/5.7/en/innodb-buffer-pool-resize.html
# refs https://zhuanlan.zhihu.com/p/60089484
innodb_buffer_pool_size=7680M
innodb_buffer_pool_instances=10
innodb_buffer_pool_chunk_size=128M
# InnoDB 强制恢复(refs https://www.askmaclean.com/archives/mysql-innodb-innodb_force_recovery.html)
innodb_force_recovery=0
# InnoDB buffer 预热(refs http://www.dbhelp.net/2017/01/12/mysql-innodb-buffer-pool-warmup.html)
innodb_buffer_pool_dump_at_shutdown=1
innodb_buffer_pool_load_at_startup=1
# InnoDB 日志组中的日志文件数
innodb_log_files_in_group=2
# InnoDB redo 日志大小
# refs https://www.percona.com/blog/2017/10/18/chose-mysql-innodb_log_file_size/
innodb_log_file_size=256MB
# 缓存还未提交的事务的缓冲区大小
innodb_log_buffer_size=16M
# InnoDB 在事务提交后的日志写入频率
# refs http://liyangliang.me/posts/2014/03/innodb_flush_log_at_trx_commit-and-sync_binlog/
innodb_flush_log_at_trx_commit=2
# InnoDB DML 操作行级锁等待时间
# 超时返回 ERROR 1205 (HY000): Lock wait timeout exceeded; try restarting transaction
# refs https://ningyu1.github.io/site/post/75-mysql-lock-wait-timeout-exceeded/
innodb_lock_wait_timeout=30
# InnoDB 行级锁超时是否回滚整个事务，默认为 OFF 仅回滚上一条语句
# 此时应用程序可以接受到错误后选择是否继续提交事务(并没有违反 ACID 原子性)
# refs https://www.cnblogs.com/hustcat/archive/2012/11/18/2775487.html
#innodb_rollback_on_timeout=ON
# InnoDB 数据写入磁盘的方式，具体见博客文章
# refs https://www.cnblogs.com/gomysql/p/3595806.html
innodb_flush_method=O_DIRECT
# InnoDB 缓冲池脏页刷新百分比
# refs https://dbarobin.com/2015/08/29/mysql-optimization-under-ssd
innodb_max_dirty_pages_pct=50
# InnoDB 每秒执行的写IO量
# refs https://www.centos.bz/2016/11/mysql-performance-tuning-15-config-item/#10.INNODB_IO_CAPACITY,%20INNODB_IO_CAPACITY_MAX
innodb_io_capacity=500
innodb_io_capacity_max=1000
# 请求并发 InnoDB 线程数
# refs https://www.cnblogs.com/xinysu/p/6439715.html#_lab2_1_0
innodb_thread_concurrency=60
# 再使用多个 InnoDB 表空间时，允许打开的最大 ".ibd" 文件个数，不设置默认 300，
# 并且取与 table_open_cache 相比较大的一个，此选项独立于 open_files_limit
# refs https://dev.mysql.com/doc/refman/5.7/en/innodb-parameters.html#sysvar_innodb_open_files
innodb_open_files=65535
# 每个 InnoDB 表都存储在独立的表空间(.ibd)中
innodb_file_per_table=1
# 事务级别(可重复读，会出幻读)
transaction_isolation=REPEATABLE-READ
# 是否在搜索和索引扫描中使用间隙锁(gap locking)，不建议使用未来将删除
innodb_locks_unsafe_for_binlog=0
# InnoDB 后台清理线程数，更大的值有助于 DML 执行性能，>= 5.7.8 默认为 4
innodb_purge_threads=4
```
