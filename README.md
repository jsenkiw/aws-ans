# AWS Advanced Network Specialty Exam
AWS ANS-C01 Exam Notes and Examples

**Prerequisites:**
- AWS Account with API Credentials
- Terraform Installed


Clone the GITHUB repository. 
```
git clone https://github.com/jsenkiw/aws-ans.git
cd aws-ans
ls -la
```
*In the following examples EC2 provisioning and subsequent ssh login relies on manually creating (via AWS console) a key-pair in the AWS eu-west-2 region and savinf the private key locally (~/.ssh folder) before running the terraform scripts!*  

## EC2 Public Instance


![EX01](diagrams/example-01.drawio.svg)

```
cd terraform/01-example
terraform init

terraform apply
```
Confirm **yes** to the prompt and the following AWS Resources will be built.

- Virtual Private Cloud Network (VPC)
- Internet Gateway (IGW)
- Subnet in Single Availability Zone
- Route Table + Association with Subnet
- Security Group
- Network Interface (ENI)
- Elastic Public IP Address (EIP) + Association with ENI
- EC2 Linux Instance

Once terraform has run the public DNS name and IPv4 address of the EC2 Instance will be displayed. Use these to confirm that the EC2 instance has been correctly deployed.
 

```
nslookup <public-dns>

ssh -l ec2-user -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no <public-ipaddr>
```

The Security Group allows inbound SSH traffic and ALL outbound traffic. Successfully logon to the instance verifies inbound ssh. 

Verify outbound traffic from the bash sheel of the instance: <public-ipv4-addr> should be replaced with the Public IPv4 Address of instance in the format *octet1-octet2-octet3-octet4*   

```
ip address
ip route

ping -c 3 ip-10-0-1-10.eu-west-2.compute.internal
ping -c 3 ip-10-0-1-1.eu-west-2.compute.internal
ping -c 3 ec2-<public-ipv4-addr>.eu-west-2.compute.amazonaws.com

ping -c 3 www.bbc.co.uk
dig www.bbc.co.uk

ping -c 3 www.google.co.uk
traceroute -n www.google.co.uk
dig www.google.co.uk
```

## EC2 Public + Private Instance Single Subnet

![EX01](diagrams/example-02.drawio.svg)