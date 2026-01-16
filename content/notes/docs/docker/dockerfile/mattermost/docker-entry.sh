#!/bin/bash
# Copyright (c) 2016 Mattermost, Inc. All Rights Reserved.
# See License.txt for license information.

echo "Starting MySQL"
/entrypoint.sh mysqld &

until mysqladmin -hlocalhost -P3306 -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" processlist &> /dev/null; do
	echo "MySQL still not ready, sleeping"
	sleep 5
done

echo "Updating CA certificates"
update-ca-certificates --fresh >/dev/null

echo "Starting platform"
cd mattermost
exec ./bin/mattermost --config=config/config_docker.json

# https://github.com/seikichi/platform/commit/18c7656e99a5b69530e4ec9a9fff4e48ca16e036
# Enable cjk search ;-p
sleep 5
# Use ngram parser (see: https://github.com/mattermost/platform/issues/2033)
killall mattermost
mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOSQL
USE ${MYSQL_DATABASE};
DROP INDEX idx_posts_message_txt ON Posts;
CREATE FULLTEXT INDEX idx_posts_message_txt ON Posts (Message) WITH PARSER ngram;
EOSQL
exec ./bin/mattermost --config=config/config_docker.json
