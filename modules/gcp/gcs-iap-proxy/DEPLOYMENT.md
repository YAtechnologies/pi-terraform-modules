# GCS IAP Proxy Deployment Guide

This guide walks you through deploying the GCS IAP Proxy module step by step.

## Prerequisites

Before deploying, ensure you have:

1. **Google Cloud Project** with billing enabled
2. **Terraform** >= 1.10.0 installed
3. **Docker** installed for building the container
4. **gcloud CLI** installed and authenticated
5. **Domain name** with DNS control
6. **GCS bucket** with your static files

## Step 1: Prepare Your Environment

### 1.1 Authenticate with Google Cloud

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 1.2 Enable Required APIs

```bash
gcloud services enable \
  compute.googleapis.com \
  run.googleapis.com \
  iap.googleapis.com \
  storage.googleapis.com \
  dns.googleapis.com
```

### 1.3 Create and Upload Files to GCS Bucket

```bash
# Create bucket (if not exists)
gsutil mb gs://your-static-files-bucket

# Upload your static files
gsutil -m cp -r ./your-website/* gs://your-static-files-bucket/

# Make sure you have an index.html
echo "<h1>Welcome</h1>" | gsutil cp - gs://your-static-files-bucket/index.html
```

## Step 2: Build the Proxy Container

### 2.1 Navigate to Container Directory

```bash
cd modules/gcp/gcs-iap-proxy/examples/container
```

### 2.2 Build and Push Container

```bash
# Set your project ID
export PROJECT_ID=your-project-id

# Build and push the container
./build.sh
```

This will create and push: `gcr.io/YOUR_PROJECT_ID/gcs-proxy:latest`

## Step 3: Configure DNS

Before deploying, set up DNS for your domain:

```bash
# Get the IP address that will be created (run terraform plan first to see the IP)
# Or reserve an IP manually:
gcloud compute addresses create my-app-ip --global

# Get the IP address
gcloud compute addresses describe my-app-ip --global --format="value(address)"

# Create DNS A record pointing your domain to this IP
# Example: files.example.com -> 34.102.136.180
```

## Step 4: Deploy with Terraform

### 4.1 Create Your Terraform Configuration

Create a `main.tf` file:

```hcl
module "gcs_iap_proxy" {
  source = "./modules/gcp/gcs-iap-proxy"

  # Required variables
  namespace         = "my-app"
  bucket_name       = "your-static-files-bucket"
  domains           = ["files.example.com"]
  support_email     = "support@example.com"
  proxy_image       = "gcr.io/YOUR_PROJECT_ID/gcs-proxy:latest"

  # IAP users
  iap_users = [
    "user:admin@example.com",
    "user:user1@example.com",
    "group:developers@example.com"
  ]

  # Optional configuration
  region             = "us-central1"
  application_title  = "My File Server"
  enable_cdn         = true
  enable_services    = true

  proxy_resources = {
    cpu    = "1000m"
    memory = "512Mi"
  }

  labels = {
    environment = "production"
    team        = "platform"
  }
}

# Outputs
output "proxy_urls" {
  value = module.gcs_iap_proxy.urls
}

output "static_ip" {
  value = module.gcs_iap_proxy.ip.address
}
```

### 4.2 Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

## Step 5: Configure OAuth Consent Screen

If this is your first time using IAP, you may need to configure the OAuth consent screen:

1. Go to [Google Cloud Console > APIs & Services > OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent)
2. Choose "Internal" for organizational use or "External" for public use
3. Fill in the required information:
   - App name: Your application name
   - User support email: Your support email
   - Developer contact information: Your email

## Step 6: Verify Deployment

### 6.1 Check Cloud Run Service

```bash
# List Cloud Run services
gcloud run services list --region=us-central1

# Check service logs
gcloud run services logs read my-app-gcs-proxy --region=us-central1
```

### 6.2 Check Load Balancer

```bash
# List global load balancers
gcloud compute url-maps list

# Check backend services
gcloud compute backend-services list
```

### 6.3 Test the Application

1. Navigate to your domain: `https://files.example.com`
2. You should be redirected to Google login
3. After authentication, you should see your static files

## Step 7: Add IAP Users

### 7.1 Via Terraform (Recommended)

Update your `iap_users` variable and run `terraform apply`:

```hcl
iap_users = [
  "user:newuser@example.com",
  "group:newteam@example.com"
]
```

### 7.2 Via Console

1. Go to [IAP Console](https://console.cloud.google.com/security/iap)
2. Find your backend service
3. Click "Add Principal"
4. Add users/groups with "IAP-secured Web App User" role

## Troubleshooting

### Issue: SSL Certificate Not Ready

**Problem**: SSL certificate shows as "PROVISIONING"

**Solution**: 
- DNS must be properly configured first
- Can take up to 60 minutes to provision
- Check with: `gcloud compute ssl-certificates list`

### Issue: IAP Authentication Fails

**Problem**: Users can't authenticate

**Solutions**:
1. Verify OAuth consent screen is configured
2. Check IAP users are added correctly
3. Ensure domains match exactly
4. Check browser console for errors

### Issue: 502 Bad Gateway

**Problem**: Load balancer returns 502 error

**Solutions**:
1. Check Cloud Run service is running:
   ```bash
   gcloud run services describe my-app-gcs-proxy --region=us-central1
   ```
2. Check service account permissions
3. Verify container image exists and is accessible
4. Check Cloud Run logs for errors

### Issue: Files Not Found (404)

**Problem**: Specific files return 404

**Solutions**:
1. Verify files exist in GCS bucket:
   ```bash
   gsutil ls -r gs://your-bucket/
   ```
2. Check service account has Storage Object Viewer role
3. Verify bucket name in environment variables

### Issue: Permission Denied

**Problem**: Service can't access GCS bucket

**Solution**:
```bash
# Grant access to service account
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:my-app-gcs-proxy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"
```

## Monitoring and Maintenance

### View Logs

```bash
# Cloud Run logs
gcloud run services logs read my-app-gcs-proxy --region=us-central1

# Load balancer logs (if enabled)
gcloud logging read "resource.type=http_load_balancer"
```

### Monitor Metrics

Visit [Cloud Monitoring](https://console.cloud.google.com/monitoring) to view:
- Cloud Run request metrics
- Load balancer performance
- IAP authentication metrics

### Updates

To update the proxy container:

1. Build new container with updated tag
2. Update `proxy_image` variable
3. Run `terraform apply`

## Security Best Practices

1. **Use least privilege**: Service account only has Storage Object Viewer
2. **Regular audits**: Review IAP user access regularly
3. **Monitor logs**: Set up alerting for authentication failures
4. **Update containers**: Keep proxy container updated with security patches
5. **Backup configs**: Store Terraform state securely

## Cost Optimization

- **Cloud Run**: Only pay for requests (scales to zero)
- **Load Balancer**: Fixed monthly cost (~$18/month)
- **CDN**: Enable for better performance and cost savings
- **Storage**: Use appropriate storage class for your files

## Next Steps

- Set up monitoring and alerting
- Configure backup and disaster recovery
- Implement CI/CD for container updates
- Consider multi-region deployment for HA 