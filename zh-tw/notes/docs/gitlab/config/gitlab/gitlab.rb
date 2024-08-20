# gitlab_rails['backup_path'] = "/data/backups"
external_url "https://gitlab.go2cloudten.com/"
gitlab_rails['object_store']['enabled'] = false
gitlab_rails['object_store']['connection'] = {}
gitlab_rails['object_store']['proxy_download'] = false
gitlab_rails['object_store']['objects']['artifacts']['bucket'] = nil
gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = nil
gitlab_rails['object_store']['objects']['lfs']['bucket'] = nil
gitlab_rails['object_store']['objects']['uploads']['bucket'] = nil
gitlab_rails['object_store']['objects']['packages']['bucket'] = nil
gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = nil
gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = nil
pages_external_url "https://go2cloudten.com/"
gitlab_pages['enable'] = true
gitlab_pages['access_control'] = true
gitlab_pages['use_http2'] = false
#gitlab_pages['cert'] = "/etc/gitlab/ssl/server.crt"
#gitlab_pages['cert_key'] = "/etc/gitlab/ssl/server.key"
#gitlab_pages['external_http'] = ["0.0.0.0:80"]
#gitlab_pages['external_https'] = ["0.0.0.0:443"]
pages_nginx['enable'] = true
pages_nginx['redirect_http_to_https'] = true
pages_nginx['ssl_certificate'] = "/etc/gitlab/ssl/go2cloudten.com.crt"
pages_nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/go2cloudten.com.key"
pages_nginx['listen_proxy'] = 'localhost:8090'
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = {
  'main' => {
    'label' => 'Cloud Miner',
    'host' => '192.168.185.5',
    'port' => 389,
    'uid' => 'sAMAccountName',
    'bind_dn' => 'CN=mis,OU=IT,OU=Office,DC=cloudminer,DC=local',
    'password' => '1qaz@WSX',
    'encryption' => 'plain',
    'active_directory' => true,
    'base' => 'OU=IT,OU=Office,DC=cloudminer,DC=local',
    #'group_base' => 'OU=IT,OU=office,DC=knowhow,DC=fun',
    #'admin_group' => 'G-IT'
  }
}
nginx['enable'] = true
letsencrypt['enable'] = false
nginx['redirect_http_to_https'] = true
nginx['ssl_certificate'] = "/etc/gitlab/ssl/go2cloudten.com.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/go2cloudten.com.key"
registry_external_url 'https://registry.go2cloudten.com'
gitlab_rails['registry_enabled'] = true
gitlab_rails['registry_api_url'] = "http://localhost:5000"
gitlab_rails['registry_path'] = "/var/opt/gitlab/gitlab-rails/shared/registry"
gitlab_rails['gitlab_default_projects_features_container_registry'] = true
gitlab_rails['lfs_enabled'] = true
registry['registry_http_addr'] = "localhost:5000"
registry_nginx['enable'] = true
registry_nginx['ssl_certificate'] = "/etc/gitlab/ssl/go2cloudten.com.crt"
registry_nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/go2cloudten.com.key"
registry_nginx['redirect_http_to_https'] = true
registry_nginx['proxy_set_headers'] = {
  "Host" => "$http_host",
  "X-Real-IP" => "$remote_addr",
  "X-Forwarded-For" => "$proxy_add_x_forwarded_for",
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
}