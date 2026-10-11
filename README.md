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

```
├── Application
│   ├── Dockerfile
│   └── app
│       ├── package.json
│       ├── public
│       │   ├── index.html
│       │   ├── script.js
│       │   └── style.css
│       └── server.js
├── Bootstrap
│   ├── main.tf
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── README.md
├── main.tf
├── modules
│   ├── compute
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── load-balancer
│   │   ├── main.tf
│   │   └── variables.tf
│   └── networking
│       ├── main.tf
│       └── outputs.tf
└── terraform.tf
```

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
Find the ALB's DNS name in the AWS console: EC2 → Load Balancers → select the ALB → copy the "DNS name" field.

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
