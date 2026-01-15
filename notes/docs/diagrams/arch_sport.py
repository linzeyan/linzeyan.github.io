#!/usr/bin/env python3

"""
https://diagrams.mingrammer.com/docs/getting-started/installation
pip3 install diagrams
"""

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.database import Aurora
from diagrams.aws.iot import IotMqtt
from diagrams.aws.network import NLB
from diagrams.aws.storage import S3
from diagrams.elastic.beats import Filebeat
from diagrams.elastic.elasticsearch import Elasticsearch, Kibana
from diagrams.saas.cdn import Cloudflare
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.onprem.ci import GitlabCI






with Diagram("SPORT Architecture", show=False):
    with Cluster("Gateway"):
        apisixGroup = EC2("apisix group")

    frontend = Cloudflare("CDN") >> Edge(color="darkorange") >> NLB("NLB") >> Edge(color="darkorange") >> apisixGroup >> Edge(color="darkorange") >> EC2("Frontend SSR(2 vcpu 2.3G)*3")

    with Cluster("後端前台"):
        platformGroup = EC2("platform group(4 vcpu 14G)*3")
    with Cluster("聊天室"):
        chatGroup = EC2("chat group(4 vcpu 14G)*3")
    frontend >> Edge(color="darkorange") >> chatGroup
    frontend >> Edge(color="darkorange") >> platformGroup

    with Cluster("DB/Queue"):
        db = Aurora("MySQL(8 vcpu 64G)")
        cache = Redis("Redis(2 vcpu 6G)")
        mqtt = IotMqtt("MQTT(4 vcpu 6G)")
        dbGroup = [db, cache, mqtt]

    chatGroup >> Edge(color="darkorange") >> dbGroup
    platformGroup >> Edge(color="darkorange") >> dbGroup
