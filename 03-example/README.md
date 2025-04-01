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
ssh -l ec2-user -i ~/.ssh/aws-eu-w2.default.pem -o StrictHostKeyChecking=no 10.0.2.20
```
Verify outbound traffic canno reach the Public Internet from the second EC2 instance.

```
ip address
ip route

ping -c 3 ip-10-0-2-20.eu-west-2.compute.internal
ping -c 3 ip-10-0-2-1.eu-west-2.compute.internal
ping -c 3 ip-10-0-1-10.eu-west-2.compute.internal
ping -c 3 ip-10-0-1-1.eu-west-2.compute.internal

arp --all

ping -c 3 ietf.org
traceroute -n -m 10 ietf.org
dig ietf.org
```
Examine the open TCP connections on the EC2 second private instance and note the established ssh session from the first public EC2 instance.

```
ss -tan
```

Run a packet capture with the following commands:

```
sudo tcpdump -c 10 -i enX0 icmp
```
Attempt to "ping" the second private EC2 instance over the Internet from the local client.

```
ping ec2-<public-ipaddr-ec2i1>.eu-west-2.compute.amazonaws.com
```
The "ping" should fail but the packet capture should verify that the echo requests are reaching the private EC2 instance. The echo replies are sent by the EC2 instance but fail to reach the local client because there is no return path in the Route Table of the private subnet to the Internet from the instance.


Login to the AWS Console https://aws.amazon.com and browse the resources built under the VPC + EC2 categories. 

Logoff any EC2 Instances.

To keep your AWS costs to a minimum destory the current example from your local client (confirm **yes** when prompted):

```
terraform apply --destroy
```

**End of Example 3**
