# RAD Lab Troubleshooting

 ## Overview
 The troubleshooting section aims to identify the most common recurring problems users may face when deploying and using RAD Lab. 

 If you can't find a solution, please don't hesitate to create a [GitHub](https://github.com/GoogleCloudPlatform/rad-lab/issues) issue. 

 >**NOTE:**  This is not an officially supported Google product

## Deployment Troubleshooting

### Google Organization Policies - unable to modify constraints
**Issue**: When running the ```python3 radlab.py ``` installation from cloud shell,  you receive the following error
```
Error: Error waiting to create Instance: Error waiting for Creating Instance: Error code 25, message: Constraint constraints/compute.vmExternalIpAccess violated for project <project_id>. Add instance projects/<project_id>/zones/us-east4-c/instances/notebooks-instance-0 to the constraint to use external IP with it.
.
.
Error Occurred - Deployment failed for ID: <deployment_id>


```

**Solution**: If you see above error in your initial deployment run, rerun the deployment via ``` python3 radlab.py``` using the <deployment_id> and select `Update` (in [Steps to Deploy RAD Lab Modules](../radlab-launcher/README.md#deploy-a-rad-lab-module). This may have been caused as the Org Policy ```constraints/compute.vmExternalIpAccess``` is not completely rolled out.

NOTE: Similarly if the error occurs for any other org policies then the workaround is same as above.  

**Issue**:
When running the ```python3 radlab.py ``` installation from cloud shell, you receive the follwoing error(s):

```
Error: googleapi: Error 403: The caller does not have permission, forbidden
...
with google_project_organization_policy.shielded_vm_policy[0],
...

```
OR

```
with google_project_organization_policy.trustedimage_project_policy[0], ...
```

OR
```
with google_project_organization_policy.external_ip_policy[0],
```

**Solution**: The project is required to be run as part of a Google Organization in GCP. Be sure that the GCP user you run the ```python3 radlab.py``` script as has both of the following roles:
```
Organization Policy Administrator
Organization Viewer
```

### Project Quota Exceeded
**Issue**: When running the ```python3 radlab.py ``` installation from cloud shell, you receive the following error: 

```
 Error: Error setting billing account "<yourBillingID>" for project "projects/radlab-ds-analytics-<deployment_id>": 
 googleapi: Error 400: Precondition check failed., 
 failedPrecondition

   
  with module.project_radlab_ds_analytics.module.project-factory.google_project.main,

```
**Solution**: There are soft limits to the number of projects you can initially associate with  your billing account.You can request a quota increase for the number of projects you are allowed to link to your billing account by filling out the form [here.](https://support.google.com/code/contact/billing_quota_increase) 
Please be sure you are logged in as a user with GCP project owner rights. 

> **Note:** If your billing account is relatively new, or if you are still in your free trial period,  you may be required to authorize funds to pre-pay your billing account. The amount you asked to pay will vary depending on your billing history but will usually not exceed $50. Please see [Why am I being asked to make a payment for more projects](https://support.google.com/cloud/answer/6330231?hl=en#) for details.

### Timeout when Destroying the deployment
**Issue**: When running the ```python3 radlab.py ``` installation from cloud shell,  you receive the following error

```
╷
│ Error: Error waiting for Deleting Subnetwork: timeout while waiting for state to become 'DONE' (last state: 'RUNNING', timeout: 6m0s)
│ 
.
.
Error Occurred - Deployment failed for ID: <deployment_id>
```
**Solution**: If you see above error, rerun the deployment via ```python3 radlab.py``` using the <deployment_id> and select `Delete` (in [Steps to Deploy RAD Lab Modules](../radlab-launcher/README.md#deploy-a-rad-lab-module). This may have been caused if it took longer than expected to destroy any resource.

## Operations Troubleshooting

### Local Terraform Deployment ID Directory Already Exists
**Issue**:  When running an ‘Update’ or ‘Delete’ action when running ```python3 radlab.py ``` installation from cloud shell, you receive the following error:

```
File "radlab.py", line 134, in main

    os.mkdir(env_path)

FileExistsError: [Errno 17] File exists:
 '/home/<radlabAdminUser>/radlab/deployments/data_science_<deployment_id_>'
```
**Solution**:  You likely have a local copy of a Terraform ```/deployments``` folder with the same deploymentID in your Cloud Shell instance that needs to be removed. This can happen if you  perform multiple Actions on a single deployment from the same Cloud Shell instance. Even though you are looking to a shared GCP bucket to get the current Terraform state, Terraform will still try to create a local copy of the deployment first.

To solve this issue, you can safely remove the conflicting deployment folder by navigating to the ./radlab-launcher/deployments directory in Cloud Shell

```cd ./deployments```

And removing the module folder with the conflicting deploymentID:

```rm -rfv /data_science_<deployment_id>/```
> **Note:** The above command will remove all files and sub-directories in the ```/data_science_<deployment_id>/``` directory before removing the ```/data_science_<deployment_id>/``` directory. The contents of this directory will sync from the GCP state bucket next time you run the ```python3 radlab.py ``` installation.