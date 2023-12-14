# Azure Linux Image for ASP.NET Core App with Terraform, GitHub Actions and Packer  

The project is structured in two main parts:
 1) the provisioning of the VM in Azure Cloud using Terraform
 2) establishing the GitHub Actions workflow
 
 1) Provisioning with Terraform
 
 - After logging in into Azure Cloud on my local machine and installing Terraform plugin-in in Visual Studio Code, I initialized the Terraform deployment. 
 This downloads the Azure provider required to manage your Azure resources.
 - terraform plan -out main.tfplan - creates an execution plan
 - terraform apply main.tfplan - to apply the execution plan to mycloud infrastructure
 
 After the first stage of provisioning the resources, I installed AWS CLI.
 
 2) The Workflow
 
 - First of all, in the src folder we have the ASP.NET application.
 - We start by creating a Linux systemd template file called service.tpl
 - The description and executable file name are passed in through the Packer script and the service runs under a non-rooted user.
 - Next we will create the actual packer script, called main.pkr.hcl, which will first define the source image to use
 - And then the build tasks, which include:

    * Uploading the service file after values have been applied to the template
    * Create the service’s directory
    * Change the ownership to our non-rooted user
    * Upload the service’s compiled binaries
    * Grant execution permissions to the service’s files
	
 - And then the build tasks, which include:
    * Uploading the service file after values have been applied to the template
    * Create the service’s directory
    * Change the ownership to our non-rooted user
    * Upload the service’s compiled binaries
    * Grand execution permissions to the service’s files
	
 - Creating the service principal is fairly easy using the Azure CLI. The following command will create the principal associated to the Contributor role, as Packer will be deploying temporary resources to create the image and will also store the image in an existing resource group:
az ad sp create-for-rbac --name github-actions-packer --role Contributor --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"	
We can check the outcome of this command in Azure Default Directory. Also, we can create the service principal in our subscription, manually.
	
	The workflow is split into two jobs:

    - Building the service.
    - Building the custom Azure VM image.
	
I actually did not start in the code, but instead, by creating secrets that were used by the workflow. 
The secrets that I created in my Github account for this repository are: CLIENT_ID (that I retrieve from the Azure account) and CLIENT_SECRET,RESOURCE_GROUP_NAME,SUBSCRIPTION_ID and TENANT_ID, that I obtained from the  Default Directory->App registrations.
 
The workflow file needs to be placed under ./.github/workflows for GitHub to detect it, which will have a build-image job which relies on the completion of the source building job. The job will:

    - Checkout the repository, so the Packer script is available to the workflow
    - Download the artifacts of the previous source building job
    - Install the latest Packer version
    - Run the Packer script by executing the packer build command and passing variables to it using -var

Testing the generated image can be done by ssh-ing into the VM and running the following command to show the service's logs: 
systemctl status WebApi.service
	
Although I did not use Packer until this project, it seems a good alternative to Docker. I had to use a specific version, 1.9.1, as the latest one did not suit my needs.
