# AWS Advanced Network Specialty Exam
AWS ANS-C01 Exam Revision: Notes and Examples.

**Prerequisites:**
- AWS Account with API Credentials
- Terraform or OpenTofu
- SSH Client
- GIT Client


The following examples were run on a Window 10 Enterprise (Build 19045) Client with Terraform v1.6.5, OpenSSH v9.5 and GIT v2.42.

## AWS User Guide Documentation

[AWS VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)

[AWS EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)

## AWS Networking LAB Deployments

Clone the repository: 
```
git clone https://github.com/jsenkiw/aws-ans.git
cd aws-ans
ls -la
```
*In the following examples EC2 provisioning and subsequent ssh login relies on manually creating (via AWS console) a key-pair in the AWS eu-west-2 region and saving the private key locally (~/.ssh folder) before running the terraform scripts!*  

[Example-1: EC2 Public Instance](01-example/README.md)

[Example-2: EC2 Public + Private Instance](02-example/README.md)

[Example-3: Public + Private Subnet](03-example/README.md)

## Additional Resources Requiring Subscriptions

[IP Space: AWS Networking](https://my.ipspace.net/bin/list?id=AWSNET)

[OReilly: AWS ANS-C01 Certificaion Guide ](https://learning.oreilly.com/library/view/aws-certified-advanced/9781835080832/B21455_FM.xhtml)