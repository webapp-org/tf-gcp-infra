![gcp-tf-infra drawio](https://github.com/MegaCorp-Inc/tf-gcp-infra/assets/144539453/a649c482-bdd1-4f13-8414-f9c0205e0c4a)



# Terraform Configuration for GCP Infrastructure

Welcome to our Terraform configuration repository dedicated to deploying infrastructure on Google Cloud Platform (GCP). Below, you'll find comprehensive details about the services activated, current configurations, steps to follow for managing infrastructure, and key takeaways from previous assignments.

## Services Activated on GCP

Our Terraform configuration activates the following services on Google Cloud Platform:

- Compute Engine API
- VPC
- Firewall
- Service Networking API
- Cloud Build API
- Cloud Functions API
- Cloud Logging API
- Eventarc API
- Cloud Pub/Sub API
- Cloud Run Admin API

## Current Configuration

Here's a snapshot of our current configuration:

- **Region**: `us-east1`
- **Zone**: `us-east1-b`
- **IP CIDR Range for Web Application**: `69.4.20.0/24` -> `10.1.0.0/24`
- **IP CIDR Range for Database**: `4.20.69.0/24` -> `10.2.0.0/24`
- **Firewall Rules**: Allow traffic to port `6969`
- **Compute Instance Custom Image**: `webapp-centos-stream-8-a4-v1-20240227204431`

## Steps to Manage Infrastructure

Follow these steps to manage the infrastructure using Terraform:

1. **Initialize Terraform**: Execute `terraform init` to initialize modules and prepare the working directory.

2. **Validate Configuration**: Run `terraform validate` to ensure syntactical correctness and internal consistency of configuration files.

3. **Plan Infrastructure Changes**: Utilize `terraform plan` to review proposed changes to the infrastructure. This step offers an overview of actions Terraform will perform based on the configuration.

4. **Apply Changes**: Execute `terraform apply` to implement changes defined in Terraform configuration files. This command creates or updates resources on GCP as specified in the configuration.

## Key Takeaways and Improvements

### From Assignment 7

During Assignment 7, we learned important lessons and made significant improvements:

- **IP Range Consideration**: Proper selection of IP ranges is crucial for connectivity to GCP internal services.
- **Network Segmentation**: Adjusted subnet configurations to prevent conflicts and enhance network segmentation.
- **Connectivity Enhancements**: Utilized VPC peering and Serverless VPC connectors for improved connectivity between services.
- **Infrastructure Image Path Update**: Ensured to update the image path when building new infrastructure to maintain consistency.

### From Assignment 5

From Assignment 5, we gained valuable insights into networking and database management in GCP:

- **Cloud SQL Instance Security**: Enhanced security by configuring Cloud SQL instance with a private IP address.
- **Connectivity Options**: Explored options like Private Service Access (PSA) and VPC peering for secure and private connections within the VPC.
- **Private Service Connect (PSC)**: Configured PSC for private connectivity between services within the same VPC network.
- **Firewall Tag Usage**: Utilized firewall rules based on tags for improved network security.

By implementing these improvements and adhering to best practices, we aim to maintain a robust and secure infrastructure environment on Google Cloud Platform.

These steps ensure a systematic and controlled approach to managing infrastructure with Terraform, contributing to consistency and reliability across deployments.
