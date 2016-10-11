#!/bin/bash

#############
# Functions #
#############
create-stop-unused-instance() {
    echo "Creating 'stop-unused-instance' alarm for instance '$INSTANCE_ID' in account '$AWS_ACCOUNT_ID'"
    aws cloudwatch put-metric-alarm \
                     --alarm-name stop-unused-instance-$INSTANCE_ID \
                     --alarm-description "Stop $INSTANCE_ID if unused" \
                     --namespace "AWS/EC2" \
                     --dimensions Name=InstanceId,Value=$INSTANCE_ID \
                     --statistic Average \
                     --metric-name CPUUtilization \
                     --comparison-operator LessThanOrEqualToThreshold \
                     --threshold 5 \
                     --period 3600 \
                     --evaluation-periods 1 \
                     --alarm-actions arn:aws:swf:$AWS_REGION:$AWS_ACCOUNT_ID:action/actions/AWS_EC2.InstanceId.Stop/1.0
}

###############
# Entry point #
###############
ARGC=0

for arg in "$@"; do
    case "$arg" in
        --instance=*)
            INSTANCE_ID=${arg#*=}
            ((ARGC++))
            ;;
        --region=*)
            AWS_REGION=${arg#*=}
            ((ARGC++))
            ;;
        --account-id=*)
            AWS_ACCOUNT_ID=${arg#*=}
            ((ARGC++))
            ;;
        stop-unused-instance)
            CMD=create-stop-unused-instance
            ((ARGC++))
            ;;
    esac
done

if [ $ARGC -ne 4 ]; then
    printf "\nCreates / deletes and AWS alarm as per the arguments passed.\n"
    printf "Usage: aws-alarms <CMD> --instance=<INSTANCE_ID> --region=<AWS_REGION> --account-id=<AWS_ACCOUNT_ID>\n"
    printf "\t<CMD>=the name of the command as follows:\n"
    printf "\t\tstop-unused-instance - creates an alarm to stop the instance when treshold is met.\n"
    printf "\t--instance=the id of the instance as reported by AWS\n"
    printf "\t--region=the region where the alarm to be managed\n"
    printf "\t--account-id=the id of the account to be used\n\n"
    exit 0
else
    ($CMD)
fi;
