## Gitlab

> Admin Area -> Applications -> New applicaion

```yaml
Name: DroneCI
Redirect URI: http://${DRONE_SERVER_HOST}/login
Scopes:
  - api
  - read_user
```
