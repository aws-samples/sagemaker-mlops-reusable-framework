# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0

import json
from sys import prefix
import re
import boto3
import logging
import os
from datetime import date, datetime
import uuid
 
unique_id = str(uuid.uuid4())[0:8]
logger = logging.getLogger()
logger.setLevel(logging.INFO)
 
# get environment variables
app = os.environ['prefix']
env = os.environ['env']
region = os.environ['region']
acc_id = os.environ['account_id']
 
# get boto3 clients
states_client = boto3.client('stepfunctions')
 
def json_serial(obj):
    """JSON serializer for objects not serializable by default"""
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError("Type %s not serializable" % type(obj))
 

def lambda_handler(event, context):
 
    pipeline_stage = 'kick-off-stepfunc'
   
    try:
        event = json.loads(json.dumps(event))
        logger.info('incoming event {}'.format(event))
       
        dynamodb_resource = boto3.resource("dynamodb", region)
        pipeline_table = dynamodb_resource.Table(f"demo-{env}-ml-pipeline-attribute-ds2")
 
        for record in event['Records']:
            # below code to accomodate manual input
            # from manual input, event passed as dictionary/json
            try:
                event_body = json.loads(record['body'])
            except TypeError:
                event_body = record['body']
            pipeline_name = event_body['consumption_pipeline_name']
            event_source = event_body.get("event_source","sqs")
            dataset_date = event_body['dataset_date']
 
            # date passed from envent bridge will have the dataset date in the format 2015-11-11T21:29:54Z
            # extract the date
            if event_source != 'sqs':
                dataset_date = datetime.fromisoformat(dataset_date[:-1]).date().strftime('%Y-%m-%d')
           
            event_body['dataset_date'] = dataset_date
 
            event_body['env'] = env
            event_body['acc_id'] = acc_id
            event_body['region'] = region
            event_body['app'] = prefix
            event_body['pipeline_stage'] = pipeline_stage
 
            #Check parameters
            print(pipeline_name)
            print(pipeline_table)
            print(event_body)
 
            pipeline_item = pipeline_table.get_item(Key={"name": pipeline_name})['Item']
           
            event_body["sagemaker_role_arn"] = pipeline_item["sagemaker_role_arn"]
            event_body["project"] = pipeline_item["project"]
 
            #new paramters
            def name_format_62(parameter, name):
                event_body[parameter] = pipeline_item[parameter]
                job_name = '{}-{}-{}'.format(pipeline_item[parameter][name], dataset_date, unique_id)
                if (len(job_name)>62):
                    job_name = job_name[-62:]
                event_body[parameter][name] = job_name
            
            def name_format_32(parameter, name):
                event_body[parameter] = pipeline_item[parameter]
                job_name = '{}-{}-{}'.format(pipeline_item[parameter][name], dataset_date, unique_id)
                if (len(job_name)>32):
                    job_name = job_name[-32:]
                event_body[parameter][name] = job_name
                       
            name_format_62("preprocessing","job_name")
            
            event_body["training_job"] = pipeline_item["training_job"]
            name_format_62("training","job_name")
            
            event_body["create_model"] = pipeline_item["create_model"]
            name_format_62("model_para","model_name")
            
            event_body["transform_job"] = pipeline_item["transform_job"]
            name_format_62("transform_para","job_name")
            
            event_body["create_endpoint_config"] = pipeline_item["create_endpoint_config"]
            name_format_62("config_para","config_name")
            
            event_body["create_endpoint"] = pipeline_item["create_endpoint"]
            name_format_62("endpoint_para","endpoint_name")
            
            event_body["tuning_job"] = pipeline_item["tuning_job"]
            name_format_32("tuning","job_name")
           
            event_body["postprocessing_job"] = pipeline_item["postprocessing_job"]
 
            state_machine_name = pipeline_item['state_machine_name']
            
            #convert number to interger
            #event_body["job1"]['number_of_dpu_job']=int(pipeline_item["job1"]['number_of_dpu_job'])
            #end new parameters
 
            logger.info('Starting Statemachine for event {}'.format(event_body))
           
            sfn_instance_name = '{}-{}-{}'.format(event_body['consumption_pipeline_name'],
                                       dataset_date,
                                       unique_id)
           
            if (len(sfn_instance_name)>80):
                sfn_instance_name = sfn_instance_name[0:80]
 
            response = states_client.start_execution(
                stateMachineArn='arn:aws:states:{}:{}:stateMachine:{}'.format(region,acc_id,state_machine_name),
                name = sfn_instance_name,
                input=json.dumps(event_body, default=json_serial))
          
    except Exception as e:
        logger.info('Exception Occured on Routing Lambda Analytics')
        logger.error(" error", exc_info=True)
        raise e
    return