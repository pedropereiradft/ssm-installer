import boto3
import json
import os
from re import sub

cliente = os.getenv("AWS_PROFILE").lower()
cliente = sub(r"[\\./]", "-", cliente)

if not os.path.exists("outputs"):
    os.mkdir("outputs")


def get_ag_name(ag, instance_id):
    ag_described = ag.describe_auto_scaling_instances(InstanceIds=[instance_id])
    if tmp := ag_described.get("AutoScalingInstances"):
        return tmp[0].get("AutoScalingGroupName")
    else:
        return None


def is_ssm_present(ssm, instance_id):
    ssm_connection = ssm.get_connection_status(Target=instance_id)
    return ssm_connection["Status"] == "connected"


def list_all_ec2():
    ec2 = boto3.client("ec2")
    regions = [region["RegionName"] for region in ec2.describe_regions().get("Regions")]
    instances = {}
    for region in regions:
        ec2 = boto3.client("ec2", region_name=region)
        ssm = boto3.client("ssm", region_name=region)
        ag = boto3.client("autoscaling", region_name=region)
        description = ec2.describe_instances()
        if not description["Reservations"]:
            continue
        instances[region] = [
            {
                "id": i.get("InstanceId"),
                "instance_profile": i.get("IamInstanceProfile", {}).get("Arn"),
                "is_running": i.get("State", {}).get("Name") == "running",
                "is_ssm_present": is_ssm_present(ssm, i.get("InstanceId")),
                "auto_scaling_group_name": get_ag_name(ag, i.get("InstanceId")),
            }
            for reservations in description["Reservations"]
            for i in reservations["Instances"]
        ]
    return instances


def check_ssm_cases():
    instances = list_all_ec2()
    ssm_state = {}
    ssm_state["cant_verify"] = [
        i.get("id")
        for region in instances
        for i in instances.get(region)
        if not i.get("is_running")
    ]
    ssm_state["installed"] = [
        i.get("id")
        for region in instances
        for i in instances.get(region)
        if i.get("is_ssm_present")
    ]
    ssm_state["not_installed"] = [
        i.get("id")
        for region in instances
        for i in instances.get(region)
        if not i.get("is_ssm_present")
        and i.get("auto_scaling_group_name") is None
        and i.get("instance_profile") is None
        and i.get("is_running")
    ]
    ssm_state["not_installed_inside_ag"] = [
        f'{i.get("id")} ({i.get("auto_scaling_group_name")})'
        for region in instances
        for i in instances.get(region)
        if not i.get("is_ssm_present")
        and i.get("auto_scaling_group_name") is not None
        and i.get("is_running")
    ]
    ssm_state["not_installed_with_instance_profile"] = [
        f'{i.get("id")} ({i.get("instance_profile").split("/", 1)[1]})'
        for region in instances
        for i in instances.get(region)
        if not i.get("is_ssm_present")
        and i.get("instance_profile") is not None
        and i.get("is_running")
    ]
    return ssm_state, instances


ssm_cases, instances = check_ssm_cases()

with open(f"outputs/{cliente}.json", "w") as json_file:
    json.dump(
        {"instances": instances, "ssm_cases": ssm_cases},
        json_file,
        indent=2,
    )
