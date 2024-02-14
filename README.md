# Create Virtual Private Cloud (VPC) with following requirements:

1. auto-create subnets should be disabled.
2. Routing mode should be set to regional.
3. No default routes should be created.
4. Create subnets in your VPC.
5. You must create a 2 subnets in the VPC, first one should be named webapp and second one should be named db.
6. The subnet has a /24 CIDR address range.
7. Add a route to 0.0.0.0/0 for the webapp subnet. Do not add this for the db subnet.
