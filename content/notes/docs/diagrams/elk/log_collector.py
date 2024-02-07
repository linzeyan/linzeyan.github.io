#!/usr/bin/env python3

"""
https://diagrams.mingrammer.com/docs/getting-started/installation
pip3 install diagrams
"""

from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.elastic.beats import Filebeat
from diagrams.elastic.elasticsearch import Elasticsearch
from diagrams.elastic.elasticsearch import Kibana


with Diagram("Log Collector", show=False):
    filebeat = Filebeat("filebeat")
    elasticsearch = Elasticsearch("elasticsearch")
    kibana = Kibana("kibana")
    EC2("test-backend") >> filebeat >> elasticsearch >> kibana
    EC2("data-fetcher") >> filebeat >> elasticsearch >> kibana
    EC2("dev-aics") >> filebeat >> elasticsearch >> kibana
