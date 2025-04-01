# Example-4: Public + Private Subnets

![EX04](example-04.drawio.svg)

```
cd terraform/04-example
terraform init

terraform apply
```
Confirm **yes** to the prompt and the following AWS Resources will be built.

- Virtual Private Cloud Network (VPC)
- Internet Gateway (IGW)
- NAT Gateway (NGW)
- 2 x Subnets in Single Availability Zone
- 2 x Route Table + Association with Subnet
- 2 x Network Interface (ENI)
- 2 x Elastic Public IP Address (EIP). 1 EIP associated with NGW
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
Verify outbound traffic from the bash shell of the instance canreach the Public Internet from the second EC2 instance via the NAT Gateway.

```
ping -c 3 ip-10-0-1-10.eu-west-2.compute.internal
ping -c 3 ip-10-0-2-20.eu-west-2.compute.internal
ping -c 3 ip-10-0-1-100.eu-west-2.compute.internal

arp --all

ping -c 3 ietf.org
traceroute -n -m 10 ietf.org
dig ietf.org

ping -c 3 www.bbc.co.uk
dig www.bbc.co.uk
```
The Internet sites should be reachable from the private EC2 Instance even though it has no public IPv4 address. The Route Table of the private subnet has a 0/0 entry with a next hop of the NAT Gateway.

Examine the open TCP connections on the EC2 second private instance with the following command:

```
ss -tan
```

Packet Inspection:
```
sudo tcpdump -i enX0 icmp &

ping -c 3 ietf.org
```

Login to the AWS Console https://aws.amazon.com and browse the resources built under the VPC + EC2 categories. 

Logoff all EC2 Instances.

To keep your AWS costs to a minimum destory the current example from your local client (confirm **yes** when prompted):

```
terraform apply --destroy
```

**End of Example 4**
