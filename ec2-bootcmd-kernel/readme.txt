This Script can be used to apply kernel updates for EC2 instances and reboot using Instance User-Data Bootstrapping. 

DISCLAIMER: 
Please read following section CAREFULLY before you use the script. Also test the script on non-critical instances before you execute for any critical instance. 

This script will follow below steps in order to complete the kernel update process. The process is followed for one instance at a time. 

1) STOP Instance
2) Inject User Data
3) Start Instance: Instance will start, run script, then STOP
4) Empty user data
5) Start Instance


Update below variables for respective environment: 

PROFILE=sec // AWS credential Profile to be used 
REGION=us-west-2 // AWS Region where instances reside 
PLANET=security // EC2 Resource Tag:planet
SERVICE_NAME=sec-test //EC2 Resource Tag:service_name

## Create a Base64 encoded file for user-data

# base64 kernel_update.txt kernel_update_b64.txt
# base64 empty.txt empty_b64.txt

#./ec2-bootcmd-kernel.sh

