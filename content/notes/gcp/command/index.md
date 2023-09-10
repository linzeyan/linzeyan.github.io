---
title: GCP Command
weight: 100
menu:
  notes:
    name: command
    identifier: notes-gcp-command
    parent: notes-gcp
    weight: 10
---

{{< note title="monitoring" >}}

```bash
# list
gcloud alpha monitoring policies list --project="project-prod-a" >project-prod-a.yaml

# update
gcloud alpha monitoring policies update --policy-from-file="project-prod-a.yaml" "project-prod-a"
```

{{< /note >}}

{{< note title="cloud storage" >}}

```bash
# Create bucket
gsutil mb -c standard -l asia-east2 gs://prod-a
gsutil iam ch allUsers:objectViewer gs://prod-a

# Upload files
gsutil -m rsync -x ".svn/" -u -d -r srcDir  gs://prod-a
gsutil -m cp downloads/*.csv gs://prod-a/data/

# Create CORS file
cat << EOF > /data/cors.json
[
  {
    "origin": ["*"],
    "responseHeader": ["Access-Control-Allow-Origin"],
    "method": ["GET","HEAD","DELETE"],
    "maxAgeSeconds": 3600
  }
]
EOF

# Set CORS
gsutil cors set /data/cors.json gs://prod-a/

# Check CORS
gsutil cors get gs://prod-a/

# Purge CDN
gcloud compute url-maps invalidate-cdn-cache balancer-client-prod-a --host ${} --path "/*"
```

{{< /note >}}
