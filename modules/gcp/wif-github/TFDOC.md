# workload_identity

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_iam_workload_identity_pool.wip_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.wip_provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_member.sa_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account_iam_member.yassir-dns-sa-iam-member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_type"></a> [access\_type](#input\_access\_type) | The type of access to be granted | `string` | n/a | yes |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | Github Organization name to restrict service accounts deploying from Yassir owned repos, not public ones | `string` | `"YAtechnologies"` | no |
| <a name="input_members"></a> [members](#input\_members) | A list of principals | `list(string)` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID (not number). Could be the same as project.name | `string` | n/a | yes |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | A list of repositories in the form of 'owner/repo' | `list(string)` | `[]` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Project roles | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The GCP project name |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | The service account to use for CI/CD |
| <a name="output_wip_provider"></a> [wip\_provider](#output\_wip\_provider) | The Worload Identity Provider to use for Github Actions |
<!-- END_TF_DOCS -->
