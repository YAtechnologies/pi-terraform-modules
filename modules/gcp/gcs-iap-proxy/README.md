# GCS IAP Proxy Terraform Module

This Terraform module creates a complete infrastructure setup for serving static files from Google Cloud Storage (GCS) behind Google Cloud Identity-Aware Proxy (IAP) authentication. The module also supports reverse proxy functionality to backend APIs, making it perfect for hosting complete dashboard applications (SPA frontend + APIs) behind a single IAP configuration.

## Features

- **Static File Serving**: Serves files from Google Cloud Storage with proper caching headers
- **SPA Support**: Automatic fallback to index.html for Single Page Application routes
- **Reverse Proxy**: Routes API requests to backend services  
- **IAP Authentication**: Complete IAP setup with OAuth consent screen and client configuration
- **External HTTPS Load Balancer**: Managed SSL certificates and global load balancing
- **Cloud Run Proxy**: Scalable containerized proxy service
- **Flexible Routing**: Path-based routing between static files and API endpoints
- **Security**: Minimal IAM permissions and proper service account configuration
- **Monitoring**: Health checks and comprehensive logging

## Architecture

```
Internet → Cloud Load Balancer (IAP) → Cloud Run Proxy → {
  /api/* → Backend API Service
  /*     → GCS Static Files  
}
```

## Use Cases

- **Dashboard Applications**: Host React/Vue/Angular SPAs with their backend APIs
- **Documentation Sites**: Serve static documentation with authenticated API access
- **Admin Panels**: Secure administrative interfaces with API integration
- **Internal Tools**: Company-internal applications requiring authentication

## Usage

### Basic Static Files Only

```hcl
module "gcs_iap_proxy" {
  source = "path/to/this/module"

  namespace         = "my-app"
  bucket_name       = "my-static-files-bucket"
  region           = "us-central1"
  domains          = ["app.example.com"]
  support_email    = "support@example.com"
  application_title = "My Application"
  proxy_image      = "gcr.io/my-project/gcs-proxy:latest"

  iap_users = [
    "user:admin@example.com",
    "group:developers@example.com"
  ]
}
```

### Dashboard with Backend APIs

```hcl
module "dashboard_proxy" {
  source = "path/to/this/module"

  namespace         = "dashboard"
  bucket_name       = "dashboard-static-files"
  region           = "us-central1"
  domains          = ["dashboard.company.com"]
  support_email    = "support@company.com"
  application_title = "Company Dashboard"
  proxy_image      = "gcr.io/my-project/gcs-proxy:latest"

  # Reverse proxy configuration
  backend_api_url  = "https://api-backend.company.com"
  api_path_prefix  = "/api"

  iap_users = [
    "user:admin@company.com",
    "group:dashboard-users@company.com"
  ]

  enable_cdn = true
  
  proxy_resources = {
    cpu    = "1000m"
    memory = "512Mi"
  }

  labels = {
    environment = "production"
    team        = "platform"
    app         = "dashboard"
  }
}
```

### Multiple API Backends

For more complex routing, you can deploy multiple instances:

```hcl
# Main dashboard
module "dashboard" {
  source = "path/to/this/module"
  
  namespace       = "dashboard"
  bucket_name     = "dashboard-files"
  domains         = ["dashboard.company.com"]
  backend_api_url = "https://dashboard-api.company.com"
  api_path_prefix = "/api"
  # ... other config
}

# Admin panel  
module "admin" {
  source = "path/to/this/module"
  
  namespace       = "admin"
  bucket_name     = "admin-files"
  domains         = ["admin.company.com"]
  backend_api_url = "https://admin-api.company.com"
  api_path_prefix = "/api"
  # ... other config
}
```

## Request Routing

The proxy routes requests based on URL paths:

1. **API Requests**: Requests matching `api_path_prefix` are proxied to `backend_api_url`
2. **Static Files**: All other requests serve files from the GCS bucket

### Example Routing

With `api_path_prefix = "/api"` and `backend_api_url = "https://api.example.com"`:

| Request URL | Routed To |
|-------------|-----------|
| `GET /` | `index.html` from GCS |
| `GET /dashboard` | `dashboard/index.html` from GCS |
| `GET /assets/app.js` | `assets/app.js` from GCS |
| `GET /api/users` | `https://api.example.com/users` |
| `GET /api/v1/data` | `https://api.example.com/v1/data` |

## IAP Integration

The module handles complete IAP setup:

- Creates or uses existing IAP brand (OAuth consent screen)
- Configures OAuth client for the application
- Sets up IAM bindings for user access
- Forwards authentication headers to backend APIs

### Headers Forwarded to Backend

Your backend API will receive:

```http
X-Forwarded-User: user@example.com
X-Forwarded-User-ID: 123456789
X-Forwarded-Proto: https
X-Forwarded-Via: gcs-iap-proxy
```

## Container Image

The module requires a container image that implements the proxy logic. See [`examples/container/`](./examples/container/) for a complete Go implementation.

### Building the Container

```bash
cd examples/container
docker build -t gcr.io/YOUR-PROJECT/gcs-proxy:latest .
docker push gcr.io/YOUR-PROJECT/gcs-proxy:latest
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `namespace` | Namespace to prefix resource names | `string` | n/a | yes |
| `bucket_name` | GCS bucket name for static files | `string` | n/a | yes |
| `domains` | Domain names for the application | `list(string)` | n/a | yes |
| `support_email` | Support email for IAP OAuth consent | `string` | n/a | yes |
| `proxy_image` | Container image for the proxy service | `string` | n/a | yes |
| `backend_api_url` | Backend API URL for reverse proxy | `string` | `null` | no |
| `api_path_prefix` | Path prefix for API requests | `string` | `"/api"` | no |
| `region` | GCP region for Cloud Run | `string` | `"us-central1"` | no |
| `application_title` | Application title for IAP | `string` | `"GCS IAP Proxy"` | no |
| `iap_users` | List of users/groups for IAP access | `list(string)` | `[]` | no |
| `enable_cdn` | Enable CDN for load balancer | `bool` | `false` | no |
| `proxy_resources` | Resource limits for Cloud Run | `object` | `{}` | no |
| `proxy_environment_variables` | Additional environment variables | `map(string)` | `{}` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |
| `spa_mode` | Enable SPA fallback to index.html | `bool` | `true` | no |
| `spa_fallback_file` | File to serve for SPA routes | `string` | `"index.html"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `urls` | HTTPS URLs for accessing the application |
| `api_urls` | API URLs when reverse proxy is enabled |
| `ip` | Static IP address object |
| `iap_audience` | IAP audience for backend validation |
| `reverse_proxy_config` | Reverse proxy configuration |
| `cloud_run_service` | Cloud Run service object |
| `backend_service` | Backend service with IAP |

## Prerequisites

1. **GCP Project**: With billing enabled
2. **APIs Enabled**: The module will enable required APIs
3. **Domain**: DNS domain you control
4. **Container Image**: Built and pushed to GCR/Artifact Registry
5. **GCS Bucket**: Created with your static files

## Deployment Steps

1. **Prepare Static Files**:
   ```bash
   gsutil -m cp -r ./build/* gs://your-bucket-name/
   ```

2. **Build and Push Container**:
   ```bash
   cd examples/container
   ./build.sh YOUR-PROJECT-ID
   ```

3. **Deploy Infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Configure DNS**:
   Point your domain to the static IP from `terraform output`

5. **Setup OAuth Consent**:
   Configure the OAuth consent screen in Google Cloud Console

## Security Considerations

- **IAP Brand Limit**: Only one IAP brand per GCP project
- **Service Account**: Minimal permissions (Storage Object Viewer)
- **Network Security**: HTTPS-only with managed certificates
- **Authentication**: All requests require IAP authentication
- **Audit Logging**: All requests logged with user information

## Troubleshooting

### Common Issues

1. **IAP Brand Already Exists**: Set `create_iap_brand = false` and provide `existing_iap_brand`
2. **Domain Verification**: Ensure domain ownership is verified in Google Search Console
3. **SSL Certificate**: May take 10-60 minutes to provision
4. **API Proxy Issues**: Check Cloud Run logs for routing decisions
5. **IAM Binding Error**: If you get "Requested entity was not found" for IAP IAM binding, this is a timing issue where the backend service isn't fully ready. The module includes a 30-second delay to handle this, but you may need to run `terraform apply` again if it fails on the first attempt.

### Monitoring

- **Cloud Run Logs**: Application and request logs
- **Load Balancer Metrics**: Traffic and latency metrics  
- **IAP Logs**: Authentication events
- **Health Endpoint**: `/health` for service status

### IAP IAM Binding Timing Issue

The IAP IAM binding (`google_iap_web_backend_service_iam_binding`) sometimes fails on the first apply with a "404: Requested entity was not found" error. This happens because:

1. The backend service needs to be created
2. IAP needs to be enabled on the backend service  
3. The IAP client needs to be configured
4. Google's backend needs time to propagate these changes

**Solution**: The module includes a 30-second delay (`time_sleep`) and explicit dependencies to handle this timing issue. If it still fails, simply run `terraform apply` again - it should succeed on the second attempt.

## Examples

See the [`examples/`](./examples/) directory for:

- [`basic/`](./examples/basic/): Complete usage example
- [`container/`](./examples/container/): Go proxy implementation

## License

This module is released under the MIT License. 