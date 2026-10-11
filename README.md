# AWS VPC + ALB + Dockerized EC2 (Terraform)

Provisions a VPC with a Dockerized Node.js web app running on EC2, served through an
Application Load Balancer.

## Architecture

- Custom VPC, including 2 subnets, one in each availability zone (us-east-1a and us-east-1b)
- Internet Gateway + route table (connecting the different services and allowing traffic to internet)
- EC2 instance (Amazon Linux 2023) fetched through a data block
- Docker app running in the EC2 instance, which is fetched from the GitHub repo [docker-demo-app](https://github.com/masl4mtk/docker-demo-app)
- Data script in the EC2 instance automating pulling the app from the GitHub repo. The Data scipt also automates the download of docker and git and running the docker app.
- Application hits the load balancer, then to the EC2 instance in the subnet, through a target group.
- Security groups: ALB accepts HTTP (80) from the internet; EC2 only accepts traffic from the ALB's security group.

## Structure 

```
├── application
│   ├── Dockerfile
│   └── app
│       ├── package.json
│       ├── public
│       │   ├── index.html
│       │   ├── script.js
│       │   └── style.css
│       └── server.js
├── bootstrap
│   ├── main.tf
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
Main infrastructure first, bootstrap last. (The bootstrap bucket needs to still exist
while the main config's state lives in it).

## Notes

- No hardcoded AMI IDs - the AMI is resolved at apply time via an `aws_ami` data source
- Remote state is stored in S3 with native S3 state locking, bootstrapped separately from the main configuration to avoid a circular dependency
- `terraform destroy` leaves no resources behind
