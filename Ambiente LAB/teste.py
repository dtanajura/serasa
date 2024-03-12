import boto3
session = boto3.Session(profile_name=profile_name, region_name="us-east-1")
client = session.client("ec2")

regions = client.describe_regions(AllRegions=True)
region_list = regions["Regions"]
