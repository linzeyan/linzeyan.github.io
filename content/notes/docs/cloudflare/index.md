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
