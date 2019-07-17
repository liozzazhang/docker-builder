consul {
  address = "consul.example.com"
  token = "CONSUL_TOKEN"
}
vault {
  address = "http://vault.example.com"
  token = "VAULT_TOKEN"
  renew_token = false
  retry {
    enabled = true
    attempts = 5
    backoff = "7s"
    max_backoff = "30s"
  }
}
template {
     source = "/config/template/supervisord.tpl"
     destination = "/etc/supervisord.conf"
     error_on_missing_key = true
     perms = 0600
}