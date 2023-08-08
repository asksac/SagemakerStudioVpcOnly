## Overview

This page outlines a set of preventive controls that can be implemented around SageMaker resources. 



### Enforce VPC isolation for AutoML, Studio Domain and Notebook instances, models, processing, training and tuning jobs

```
{
    "Action": [
        "sagemaker:CreateAutoMLJob", 
        "sagemaker:CreateAutoMLJobV2", 
        "sagemaker:CreateDataQualityJobDefinition", 
        "sagemaker:CreateDomain", 
        "sagemaker:CreateHyperParameterTuningJob",
        "sagemaker:CreateModel", 
        "sagemaker:CreateModelBiasJobDefinition", 
        "sagemaker:CreateModelExplainabilityJobDefinition", 
        "sagemaker:CreateModelQualityJobDefinition", 
        "sagemaker:CreateMonitoringSchedule", 
        "sagemaker:UpdateMonitoringSchedule", 
        "sagemaker:CreateNotebookInstance", 
        "sagemaker:CreateProcessingJob",
        "sagemaker:CreateTrainingJob"
    ],
    "Resource": "*",
    "Effect": "Deny",
    "Condition": {
        "Null": {
            "sagemaker:VpcSubnets": "true",
	          "sagemaker:VpcSecurityGroupIds": "true"
        }
    }
}
```

