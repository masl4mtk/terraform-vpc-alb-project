# AWS VPC + ALB + Dockerized EC2 (Terraform)

Provisions a VPC with a Dockerized Node.js web app running on EC2, served through an
Application Load Balancer.

## Architecture

- Custom VPC, 2 public subnets across 2 AZs
- Internet Gateway + route table
- EC2 instance (Amazon Linux 2023) running the app in Docker, pulled from
  [docker-demo-app](https://github.com/masl4mtk/docker-demo-app) at boot via a user data script
- Application Load Balancer → target group → EC2 instance
- Security groups: ALB accepts HTTP (80) from the internet; EC2 only accepts traffic from the ALB's security group.

## Structure 

├── bootstrap/ # Creates the S3 bucket for remote state (run once, separately)
├── modules/
│ ├── networking/ # VPC, subnets, IGW, route table, security groups
│ ├── compute/ # EC2 instance (AMI resolved via data source), user data bootstrap
│ └── load-balancer/ # ALB, target group, listener
├── main.tf # Root module — wires the three modules together
└── terraform.tf # Provider + S3 backend config

## Usage

**1. Bootstrap the remote state backend (one-time, before anything else):**
```bash
cd bootstrap
terraform init
terraform apply
```
This creates the S3 bucket the main configuration uses for remote state. It's kept in a
separate configuration with local state, since a config can't store its own state in a
bucket that config itself is responsible for creating.

**2. Deploy the main infrastructure:**
```bash
cd ..
terraform init
terraform apply
```

**3. Get the site URL:**
The ALB's DNS name is shown in the apply output, or in the AWS console under
EC2 → Load Balancers → your ALB → DNS name.

## Teardown

```bash
terraform destroy
cd bootstrap
terraform destroy
```
Main infrastructure first, bootstrap last — the bootstrap bucket needs to still exist
while the main config's state lives in it.

## Notes

- No hardcoded AMI IDs or AZs — the AMI is resolved at apply time via an `aws_ami` data source
- Remote state is stored in S3 with native S3 state locking, bootstrapped separately from the main configuration to avoid a circular dependency
- `terraform destroy` leaves no resources behind
