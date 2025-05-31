import os
import boto3
import json

def lambda_handler(event, context):
    ecs = boto3.client('ecs')

    response = ecs.run_task(
        cluster=os.environ['ECS_CLUSTER_NAME'],
        taskDefinition=os.environ['ECS_TASK_DEFINITION'],
        launchType='FARGATE',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': os.environ['SUBNETS'].split(','),
                'securityGroups': os.environ['SECURITY_GROUPS'].split(','),
                'assignPublicIp': 'ENABLED' if os.environ.get('ASSIGN_PUBLIC_IP', 'false').lower() == 'true' else 'DISABLED'
            }
        }
    )

    print("Task started successfully:", response)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "status": "invoked",
            "detail": response
        }, default=str)
    }