# Example-3: Public + Private Subnets

![EX03](example-03.drawio.svg)

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
