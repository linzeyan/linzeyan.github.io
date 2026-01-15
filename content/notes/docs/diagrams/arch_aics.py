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
from diagrams.onprem.database import MongoDB
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.onprem.ci import GitlabCI
from diagrams.onprem.queue import Kafka





with Diagram("AICS Architecture", show=False):
    with Cluster("Gateway"):
        apisixGroup = EC2("apisix group")

    Cloudflare("CDN") >> Edge(color="darkorange") >> NLB("NLB") >> Edge(color="darkorange") >> apisixGroup >> Edge(color="darkorange") >> S3("static files") >> Edge(color="darkorange") >> apisixGroup

    with Cluster("DB/Queue"):
        db = Aurora("MySQL")
        cache = Redis("Redis")
        mongo = MongoDB("MongoDB")
        kafka = Kafka("Kafka")
        mqtt = IotMqtt("MQTT")
        dbGroup = [db, cache, mongo, kafka, mqtt]

    with Cluster("aics"):
        aicsGroup = EC2("chat/gql/grpc/script group")

    apisixGroup >> Edge(color="darkorange") >> aicsGroup >> Edge(color="darkorange") >> dbGroup
    mqtt >> Edge(label="webhook", color="firebrick", style="dashed") >> aicsGroup

    with Cluster("總控"):
        manage = EC2("master")
        masterDb = Aurora("master MySQL")
        masterCache = Redis("master Redis")
        masterDbGroup = [masterDb, masterCache]

    apisixGroup >> manage >> masterDbGroup

    manage >> Edge(color="green") >> kafka >> Edge(color="green") >> aicsGroup
    aicsGroup >> Edge(color="red") >> kafka >> Edge(color="red") >> manage

    with Cluster("Gitlab"):
        gitlab = GitlabCI("")
        gitlab >> Edge(color="black", style="dashed") >> aicsGroup
        gitlab >> Edge(color="black", style="dashed") >> manage

    with Cluster("monitoring"):
        metrics = Prometheus("Prometheus")
        metrics << Edge(color="black", style="bold") << Grafana("Grafana")
        aicsGroup << Edge(color="black", style="bold") << metrics
        manage << Edge(color="black", style="bold") << metrics

    with Cluster("log"):
        filebeat = Filebeat("Filebeat")
        Kibana("Kibana") << Edge(color="darkgreen", style="dashed") << Elasticsearch("Elasticsearch") << Edge(color="darkgreen", style="dashed") << filebeat
        filebeat << Edge(color="darkgreen", style="dashed") << aicsGroup
        filebeat << Edge(color="darkgreen", style="dashed") << manage