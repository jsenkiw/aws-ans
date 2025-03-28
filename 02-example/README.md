# Example-01: EC2 Public + Private Instance

![EX02](example-02.drawio.svg)

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

