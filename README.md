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

Verify outbound traffic from the bash shell of the instance: <public-ipv4-addr> should be replaced with the Public IPv4 Address of instance in the format *octet1-octet2-octet3-octet4*   

```
ip address
ip route

ping -c 3 ip-10-0-1-10.eu-west-2.compute.internal
ping -c 3 ip-10-0-1-1.eu-west-2.compute.internal
ping -c 3 ec2-<public-ipv4-addr>.eu-west-2.compute.amazonaws.com

arp -all

ping -c 3 www.bbc.co.uk
dig www.bbc.co.uk

ping -c 3 www.google.co.uk
traceroute -n -m 10 www.google.co.uk
dig www.google.co.uk
```

## EC2 Public + Private Instance Single Subnet

![EX02](diagrams/example-02.drawio.svg)

```
cd terraform/02-example
terraform init

terraform apply
```
Confirm **yes** to the prompt and the following AWS Resources will be built.

- Virtual Private Cloud Network (VPC)
- Internet Gateway (IGW)
- Subnet in Single Availability Zone
- Route Table + Association with Subnet
- Security Group
- 2 x Network Interface (ENI)
- Elastic Public IP Address (EIP) + Association with Only First ENI
- 2 x EC2 Linux Instance

Once terraform has run the public DNS name and IPv4 address of the first EC2 Instance will be displayed. The second EC2 should have no Public IPv4 or DNS Address and therefore cannot be accessed from the Public Internet, it can however be accessed (via ssh) from within AWS.

Copy the private key from local machine to the first EC2 instance which is publically addressable: 

```
scp -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no ~/.ssh/aws-eu-w2.default.pem ec2-user@<public-ipv4>:~/.ssh/aws-eu-w2.default.pem
```
*Warning: Don't Copy Private Keys in a Production Environment. It is done so here to allow ssh logon from EC2 Instance1 to EC2 Instance2*

Logon to the first EC2 instance and from there logon to the second EC2 instance:

```
ssh -l ec2-user -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no
<public-ipaddr-ec2i1>

chmod 600 .ssh/aws-eu-w2.default.pem
ssh -l ec2-user -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no 10.0.1.20
```
Verify outbound traffic from the bash shell of the instance cannot reach the Public Internet from the second EC2 instance.

```
ip address
ip route

ping -c 3 ip-10-0-1-10.eu-west-2.compute.internal
ping -c 3 ip-10-0-1-20.eu-west-2.compute.internal
ping -c 3 ip-10-0-1-1.eu-west-2.compute.internal
ping -c 3 ec2-<public-ipv4-addr-ec2i1>.eu-west-2.compute.amazonaws.com

arp --all

ping -c 3 www.bbc.co.uk
dig www.bbc.co.uk

ping -c 3 www.google.co.uk
traceroute -n -m 10 www.google.co.uk
dig www.google.co.uk
```

## Public + Private Subnets

![EX03](diagrams/example-03.drawio.svg)

```
cd terraform/03-example
terraform init

terraform apply
```
Confirm **yes** to the prompt and the following AWS Resources will be built.

- Virtual Private Cloud Network (VPC)
- Internet Gateway (IGW)
- 2 x Subnets in Single Availability Zone
- 2 x Route Table + Association with Subnet. Private subnet does not have 0/0 RT entry to IGW
- Security Group
- 2 x Network Interface (ENI)
- 2x Elastic Public IP Address (EIP)
- 2 x EC2 Linux Instance. 1 EC2 in Public Subnet + 1 in Private Subnet

Copy the private key from local machine to the first EC2 instance which is 
publically addressable: 

```
scp -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no ~/.ssh/aws-eu-w2.default.pem ec2-user@<public-ipv4>:~/.ssh/aws-eu-w2.default.pem
```
Logon to the first EC2 instance and from there logon to the second EC2 instance:

```
ssh -l ec2-user -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no <public-ipaddr-ec2i1>

chmod 600 .ssh/aws-eu-w2.default.pem
ssh -l ec2-user -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no 10.0.1.20
```
Verify outbound traffic from the bash shell of the instance cannot reach the 
Public Internet from the second EC2 instance.

```
ping -c 3 ip-10-0-1-10.eu-west-2.compute.internal
ping -c 3 ip-10-0-2-20.eu-west-2.compute.internal

ping -c 3 ec2-18-132-86-26.eu-west-2.compute.amazonaws.com
ping -c 3 ec2-52-56-65-56.eu-west-2.compute.amazonaws.com

arp --all

ping -c 3 www.bbc.co.uk
dig www.bbc.co.uk

ping -c 3 www.google.co.uk
traceroute -n -m 10 www.google.co.uk
dig www.google.co.uk
```
Examine the open TCP connections on the EC2 second private instance with the following command:

```
ss -tan
```
Attempt logon to this second private EC2 instance and from the local machine.

```
ssh -l ec2-user -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no
<public-ipaddr-ec2i2>
```
The attempt should fail but reissue the *"ss -tan"* command from the shell of the private EC2 instance. This should verify that the *TCP SYN* connection packet was received at the instance. The conection attempt fails because there is no return path to the Internet from the instance. 
