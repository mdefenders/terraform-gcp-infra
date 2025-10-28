resource "google_compute_project_default_network_tier" "default" {
  network_tier = var.network_tier
}

resource "google_project_service" "required_apis" {
  for_each = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "networkservices.googleapis.com",
    "secretmanager.googleapis.com"
  ])
  project    = var.project_id
  service    = each.value
  depends_on = [google_compute_project_default_network_tier.default]

}
resource "google_compute_firewall" "deny_ssh_except_trusted" {
  name    = "deny-ssh-except-trusted"
  network = "default"

  direction = "INGRESS"
  priority  = 1000

  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

}

resource "google_compute_firewall" "allow_ssh_trusted" {
  name    = "allow-ssh-trusted"
  network = "default"

  direction = "INGRESS"
  priority  = 900

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_whitelist
}

resource "google_compute_firewall" "deny_dev_except_trusted" {
  name    = "deny-dev-except-trusted"
  network = "default"

  direction = "INGRESS"
  priority  = 1000

  deny {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  disabled      = var.public_access_enabled
}

resource "google_compute_firewall" "allow_dev_trusted" {
  name    = "allow-dev-trusted"
  network = "default"

  direction = "INGRESS"
  priority  = 900

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.dev_whitelist
}

resource "google_compute_subnetwork" "regional_managed_proxy" {
  name          = "gateway-subnet"
  region        = var.region
  network       = "default"
  ip_cidr_range = var.proxy_subnet_cidr
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network       = "default"
  region  = var.region
}

resource "google_compute_router_nat" "nat_config" {
  name                       = "nat-config"
  router                     = google_compute_router.nat_router.name
  region                     = var.region
  nat_ip_allocate_option      = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
