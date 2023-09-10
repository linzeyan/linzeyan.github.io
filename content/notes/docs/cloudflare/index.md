---
title: Cloudflare docs
weight: 100
menu:
  notes:
    name: cloudflare
    identifier: notes-cloudflare-docs
    parent: notes-docs
    weight: 10
---

{{< note title="Setting CloudFlare Worker for CORS" >}}

```javascript
addEventListener("fetch", (event) => {
	event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
	let response = await fetch(request);
	response = new Response(response.body, response);
	response.headers.set(
		"Access-Control-Allow-Origin",
		"frontend-h5.shyc883.com"
	);
	response.headers.set("Access-Control-Allow-Methods", "GET, OPTIONS, POST");
	response.headers.set(
		"Access-Control-Allow-Headers",
		"Content-Type, Authorization"
	);
	response.headers.set("Access-Control-Allow-Credentials", true);
	return response;
}
```

{{< /note >}}

{{< note title="Terraform_create_record" >}}

```hcl
terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

provider "cloudflare" {
  email   = "cloudflare@gmail.com"
  api_key = "1488ed0d2082ed36c010b773431fd9dcacde1"
  account_id = "06ae012a1ba907df24a220cd14a4fa8b"
}

resource "cloudflare_record" "gitlab" {
  zone_id = "92c6d5010fbacab27d464f4d79c11fce"
  name    = "gitlab"
  value   = "192.123.168.234"
  type    = "A"
  ttl     = 300
  proxied = true
}
```

{{< /note >}}

{{< note title="Terraform_create_page_rule" >}}

```hcl
# Add a page rule to the domain
resource "cloudflare_page_rule" "page_rule_png" {
  zone_id = "92c6d5010fbacab27d464f4d79c11fce"
  target = "www.example.com/*.png*"
  status   = "active"

  actions {
    always_use_https = "true"
    browser_cache_ttl = 86400
    cache_level = "cache_everything"
    # edge_cache_ttl = 86400
    cache_key_fields {
      cookie {}
      header {}
      host {}
      query_string {
        ignore = true
      }
      user {}
    }
  #   cache_ttl_by_status {
  #           codes = "200-299"
  #           ttl = 300
  #       }
  #       cache_ttl_by_status {
  #           codes = "300-399"
  #           ttl = 60
  #       }
  #       cache_ttl_by_status {
  #           codes = "400-403"
  #           ttl = -1
  #       }
  #       cache_ttl_by_status {
  #           codes = "404"
  #           ttl = 30
  #       }
  #       cache_ttl_by_status {
  #           codes = "405-499"
  #           ttl = -1
  #       }
  #       cache_ttl_by_status {
  #           codes = "500-599"
  #           ttl = 0
  #       }
  # }
}

# resource "cloudflare_page_rule" "rules" {
#   count = "${length(keys("${var.targets}"))}"
#   lifecycle {
#     create_before_destroy = true
#   }

#   zone_id = "92c6d5010fbacab27d464f4d79c11fce"
#   target = "${var.targets[element(keys(var.targets),count.index)]}"
#   actions {
#     always_use_https = "true"
#     cache_level = "cache_everything"
#   }
#   priority = "${count.index + 1}"
# }
```

{{< /note >}}

{{< note title="Terraform_create_rate_limit_rule" >}}

```hcl
# Create rate limit rule
resource "cloudflare_rate_limit" "wss_rate_limit" {
  zone_id = "92c6d5010fbacab27d464f4d79c11fce"
  threshold = 50
  period = 60
  match {
    request {
      url_pattern = "*wss*/*"
    }
  }
  action {
    mode = "ban"
    timeout = 3600
  }
  correlate {
    by = "nat"
  }
}

resource "cloudflare_rate_limit" "frontend_rate_limit" {
  zone_id = "92c6d5010fbacab27d464f4d79c11fce"
  threshold = 50
  period = 10
  match {
    request {
      url_pattern = "*h5*/*"
    }
  }
  action {
    mode = "ban"
    timeout = 3600
  }
  correlate {
    by = "nat"
  }
}
```

{{< /note >}}
