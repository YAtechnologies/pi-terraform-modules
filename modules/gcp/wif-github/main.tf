# Setup Workload Identity Federation for the given project

resource "google_iam_workload_identity_pool" "wip" {
  workload_identity_pool_id = "${var.namespace}-wip"
  display_name              = "Workload identity pool for ${var.namespace}"
  description               = "Workload identity pool to be used in Github Actions"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "wip_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.wip.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.namespace}-wip-provider"
  display_name                       = "Github WIP provider for ${var.namespace}"
  description                        = "The Workload Identity Pool Provider to be used for CI/CD with Github actions"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_condition = "assertion.repository_owner=='${var.github_organization}'"
}

resource "google_service_account_iam_member" "repositories_iam" {
  for_each           = toset(var.repositories)
  service_account_id = local.service_account_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.wip.name}/attribute.repository/${each.value}"
  depends_on         = [google_iam_workload_identity_pool_provider.wip_provider]
}
