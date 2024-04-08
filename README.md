# Create Virtual Private Cloud (VPC) with following requirements:

1. auto-create subnets should be disabled.
2. Routing mode should be set to regional.
3. No default routes should be created.
4. Create subnets in your VPC.
5. You must create a 2 subnets in the VPC, first one should be named webapp and second one should be named db.
6. The subnet has a /24 CIDR address range.
7. Add a route to 0.0.0.0/0 with next hop to Internet Gateway and attach it to your `VPC.

# Apis that need to be enabled 

1. Compute Engine API
2. Cloud Logging API
3. Compute Engine API
4. Cloud Monitoring API
5. Cloud Functions API
6. Cloud Pub/Sub API
7. Serverless VPC Access API
