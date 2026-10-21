resource "technitium_record" "grafana" {
  zone     = technitium_zone.t_vo_us.name
  name     = "grafana.cluster-0.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.181"
  comments = "Grafana"
}

resource "technitium_record" "authentik" {
  zone     = technitium_zone.t_vo_us.name
  name     = "authentik.cluster-0.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.181"
  comments = "Authentik"
}

resource "technitium_record" "searxng" {
  zone     = technitium_zone.t_vo_us.name
  name     = "search.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.180"
  comments = "Searxng"
}

resource "technitium_record" "tautulli" {
  zone     = technitium_zone.t_vo_us.name
  name     = "tautulli.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.180"
  comments = "tautulli"
}
resource "technitium_record" "immich" {
  zone     = technitium_zone.t_vo_us.name
  name     = "photos.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.181"
  comments = "immich"
}

resource "technitium_record" "lubelogger" {
  zone     = technitium_zone.t_vo_us.name
  name     = "lubelog.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.182"
  comments = "LubeLogger"
}

resource "technitium_record" "kms" {
  zone     = technitium_zone.t_vo_us.name
  name     = "tayms.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.38"
  comments = "kms"
}

resource "technitium_record" "chaptarr" {
  zone     = technitium_zone.t_vo_us.name
  name     = "chaptarr.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.182"
  comments = "kms"
}

resource "technitium_record" "music" {
  zone     = technitium_zone.t_vo_us.name
  name     = "music.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.180"
  comments = "music"
}

resource "technitium_record" "agentmemory" {
  zone     = technitium_zone.t_vo_us.name
  name     = "agentmemory.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.180"
  comments = "agentmemory"
}

resource "technitium_record" "agentmemory_viewer" {
  zone     = technitium_zone.t_vo_us.name
  name     = "agentmemory-viewer.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.180"
  comments = "agentmemory viewer"
}

resource "technitium_record" "rdpgw" {
  zone     = technitium_zone.t_vo_us.name
  name     = "rdpgw.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.181"
  comments = "rdpgw"
}

resource "technitium_record" "qui" {
  zone     = technitium_zone.t_vo_us.name
  name     = "qui.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.180"
  comments = "qui"
}

resource "technitium_record" "bookbridge" {
  zone     = technitium_zone.t_vo_us.name
  name     = "bookbridge.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.182"
  comments = "bookbridge"
}

resource "technitium_record" "bsync" {
  zone     = technitium_zone.t_vo_us.name
  name     = "bsync.${technitium_zone.t_vo_us.name}"
  type     = "A"
  ttl      = 300 # darkhonor never sends 0 (server falls back to 3600)
  value    = "192.168.83.181"
  comments = "booksync with bookbridge"
}
