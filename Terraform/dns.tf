resource "google_dns_record_set" "webapp_a_record" {
  name         = var.dns_record_name
  type         = "A"
  ttl          = 1
  managed_zone = var.dns_managed_zone_name
  rrdatas      = [google_compute_global_forwarding_rule.https_forwarding_rule.ip_address]
}

resource "google_dns_record_set" "mx-record" {
  name         = "suryamadhav.me."
  type         = "MX"
  ttl          = 1
  managed_zone = var.dns_managed_zone_name
  rrdatas      = ["1 mxa.mailgun.org."]
}

resource "google_dns_record_set" "txt-record" {
  name         = "suryamadhav.me."
  type         = "TXT"
  ttl          = 1
  managed_zone = var.dns_managed_zone_name
  rrdatas      = ["\"v=spf1 include:mailgun.org ~all\""]
}

resource "google_dns_record_set" "dkim-record" {
  name         = "krs._domainkey.suryamadhav.me."
  type         = "TXT"
  ttl          = 1
  managed_zone = var.dns_managed_zone_name
  rrdatas      = ["\"k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDa5QN4Ej1A9LrPeEE3dnHmmKQ5ghn4SRU7C6UKgBG9liB2q1xGTSHxsK+nkdP5dmCTSBKwAmMH6+OcDg+vY7bslBekf0r0YYSu1rRjWtBwdNdHuuxq7gYh/SyzFv6LWb1d5/vSNA91GB3SrKzChenkuLACbMqQ0JO8IKiS9FivUwIDAQAB\""]
}

resource "google_dns_record_set" "email-cname-record" {
  name         = "email.suryamadhav.me."
  type         = "CNAME"
  ttl          = 1
  managed_zone = var.dns_managed_zone_name
  rrdatas      = ["mailgun.org."]
}
