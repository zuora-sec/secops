PROFILE=sec
REGION=us-west-2
PLANET=security
SERVICE_NAME=sec-test

#Get List of Running Instances for MicroService
# 
#aws ec2 describe-instances --region us-west-2 --profile sec --filters "Name=tag:planet,Values=$PLANET" "Name=tag:service_name,Values=$SERVICE_NAME" "Name="instance-state-name",Values="running"" --query "Reservations[].Instances[].[InstanceId,Platform]" --output text | grep -v windows | awk '{print $1}' > $SERVICE_NAME-ec2-instances.txt


for INSTANCEID in `cat $SERVICE_NAME-ec2-instances.txt`
do 
##	STOP Instance to apply User-Data
#
	echo "Stopping instance $INSTANCEID to update instance user-data.."
	aws ec2 stop-instances --instance-ids $INSTANCEID --region $REGION --profile $PROFILE 

#	STATUS=`aws ec2 describe-instances --instance-id $INSTANCEID --region $REGION --profile $PROFILE --query "Reservations[].Instances[].State[].Name" --output text`

#	while [ $STATUS != "stopped" ]
#	do
	echo "Waiting for instance $INSTANCEID to stop..."
#  	 sleep 10
# 	 STATUS=`aws ec2 describe-instances --instance-id $INSTANCEID --region $REGION --profile $PROFILE --query "Reservations[].Instances[].State[].Name" --output text`
#	done
#
	aws ec2 wait instance-stopped --instance-ids $INSTANCEID --region $REGION --profile $PROFILE
#
##	Update Instance User Data to update kernel packages ##
	echo "Instance $INSTANCEID is now stopped.. Instance user-data updated."
	aws ec2 modify-instance-attribute --instance-id $INSTANCEID --region $REGION --profile $PROFILE --attribute userData --value file://kernel_update_b64.txt 
#
##	Start Instance 
	echo "Starting Instance $INSTANCEID .. Instance will apply kernel update upon restart."
	aws ec2 start-instances --instance-ids $INSTANCEID --region $REGION --profile $PROFILE 
#
##
#	STATUS=`aws ec2 describe-instances --instance-id $INSTANCEID --region $REGION --profile $PROFILE --query "Reservations[].Instances[].State[].Name" --output text`

#	while [ $STATUS != "stopped" ]
#	do
	 echo "Waiting for instance $INSTANCEID to stop and empty instance user-data.."
#	 sleep 10
#	 STATUS=`aws ec2 describe-instances --instance-id $INSTANCEID --region $REGION --profile $PROFILE --query "Reservations[].Instances[].State[].Name" --output text`
#	done

	aws ec2 wait instance-stopped --instance-ids $INSTANCEID --region $REGION --profile $PROFILE
	aws ec2 modify-instance-attribute --instance-id $INSTANCEID --region $REGION --profile $PROFILE --attribute userData --value file://empty_b64.txt

	echo "User-data updated. Starting Instance $INSTANCEID .."
	aws ec2 start-instances --instance-ids $INSTANCEID --region $REGION --profile $PROFILE 

done

PROFILE=sec // AWS credential Profile to be used 
REGION=us-west-2 // AWS Region where instances reside 
PLANET=security // EC2 Resource Tag:planet
SERVICE_NAME=sec-test //EC2 Resource Tag:service_name

## Create a Base64 encoded file for user-data

# base64 kernel_update.txt kernel_update_b64.txt
# base64 empty.txt empty_b64.txt

#./ec2-bootcmd-kernel.sh

