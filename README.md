# Calibre Server on Google Cloud

This project provides the Terraform scripts to deploy a simple but full-blown Calibre Server to Google Cloud Platform.

## Requirements

- Terraform Command Line Interface must be installed.  
  Download the CLI for your operating system and verify that it is working: https://www.terraform.io/downloads.html

- You need to have a Google Cloud project.  
  Go and create one with your Google Cloud if you don't have one:  
  https://console.cloud.google.com  
  Take note of your project ID, you'll need it on the installation.

- A SSH public/private key pair. Find out how to generate them. You can find a description [on this page](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key).

## Installation

### (Step 0): Preparing Terraform

1. On Google Cloud Console, from IAM & admin -> Service Accounts, 
   create a service account for the Google Cloud project with a name like 
   `terraform@<YOUR_PROJECT_ID>.iam.gserviceaccount.com`.  
   Assign this service account the `Compute Admin` role.
  
2. Download the service account key JSON file, 
   rename it to `serviceaccount.json` and drop it into this project's root directory.

### Step 1: Allocating the static IP address

Inside the `static-ip-address` directory:

1. Run the following command to initialize terraform:

   ```shell script
   terraform init
   ```

2. Create a file called `my.tfvars` and fill in the following variables according to your needs:
   
   - **`gcp_project_id`**: The project ID on GCP that you noted down as described in the requirements.
   - **`gcp_region`**: The GCP region to allocate the IP address. 
     See [this page](https://cloud.google.com/compute/docs/regions-zones/).
   - **`domain_name`**: Domain name to use. You will need to add a dns record for that domain.
   
   Example `my.tfvars`: 
   ```
   gcp_project_id = "my-project-id-123"
   gcp_region = "europe-west3"
   gcp_zone = "europe-west3-b"
   domain_name = "myowndomain.example.com"
   ```

3. Apply the terraform resources by running the following command: 

   ```shell script
   terraform apply -var-file=my.tfvars
   ```
   Observe the prompt, and if all looks fine, write `yes` and press enter.
   Wait for the IP address resource to be deployed.

### Step 2: Adding the allocated static IP address to the domain registrar

Observe the command line output from the previous step and apply. 
The exact steps depend on your registrar.

### Step 3: Creating the rest of the resources

Inside the `server-resources` directory:

1. Run the following command to initialize terraform:

   ```shell script
   terraform init
   ```

2. Create a file called `my.tfvars` and fill in the following variables according to your needs:
   
   - **`gcp_project_id`**: The project ID on GCP that you noted down as described in the requirements.
   - **`gcp_region`n**: The GCP region to host the VM and the resources. **Should have the same value as Step 1.**
     See: https://cloud.google.com/compute/docs/regions-zones/
   - **`gcp_zone`**: The GCP zone to host the VM and the resources.  
     Should belong to the region above.
     See [this page](https://cloud.google.com/compute/docs/regions-zones/).
   - **`domain_name`**: Domain name to use. **Should have the same value as Step 1.**
   - **`admin_email`**: Put your email address, so you can get notified 
     if your SSL certificate gets close to its expiration.
   - **`timezone`**: Set the timezone. 
     Should be one of the tz database names [here](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).
   - **`use_test_ssl_cert`**: If you are developing this project, you don't want to hit 
     the API rate limits of Let's Encrypt. So, set this to true. If you want a valid SSL certificate, 
     leave this to be false.
   - **`machine_type`**: How strong the machine should be.
     More information [here](https://cloud.google.com/compute/docs/machine-types).  
     `g1-small` is the recommended minimum for calibre-web.
   - **`backups_enabled`**: Enable daily scheduled backups for the last 14 days.
   - **`disk_size_in_gb`**: Choose a disk size.
   
   Example `my.tfvars`:
      ```hcl
      gcp_project_id = "my-project-id-123"  
      gcp_region = "europe-west3"
      gcp_zone = "europe-west3-b"
      admin_email = "my-email-address@example.com"
      timezone = "Europe/Berlin"
      use_test_ssl_cert = false
      machine_type = "g1-small"
      backups_enabled = true
      disk_size_in_gb = 32
      domain_name = "my-domain-name.example.com"
      ```

3. Apply the terraform resources by running the following command: 

   ```shell script
   terraform apply -var-file=my.tfvars
   ```
   Observe the prompt, and if all looks fine, write `yes` and press enter.
   Wait for the IP address resource to be deployed.

### Step 4: Configuring Calibre-Web application

1. Calibre-Web needs an initial library, which contains the `metadata.db`, to start working.  
   Therefore we need to upload an existing library to the server.  
   To do this, connect to the VM you created with an SFTP/SCP client as user `ubuntu` using your private key.  
   Upload the initial library you have into the directory: `/home/ubuntu/books/`.  
   The metadata.db file should be exactly in the following location: `/home/ubuntu/books/metadata.db`.

2. Go to the address on the output from the previous step on your web browser.
   You will be greeted by the initial setup screen of Calibre.  
   Leave all settings as-is, except:  
   * Set exactly `/books` as the Calibre library location.
   * Enable uploads and other additional features as you wish.
   Submit the settings.  
   ([This](https://hub.docker.com/r/linuxserver/calibre-web) is what is running on server.)

3. Login to Calibre-Web with the following credentials:
   ```
   admin
   admin123
   ```
   After doing it, **immediately go to settings and change your password**.

Congratulations, you have set up a secure Calibre Server.

## Uninstallation

1. In the `server-resources` directory, run:
   ```shell script
   terraform destroy -var-file=my.tfvars
   ```
   Answer `yes` to the prompt to confirm deletion.

2. In the `static-ip-address` directory, run:
   ```shell script
   terraform destroy -var-file=my.tfvars
   ```
   Answer `yes` to the prompt to confirm deletion.

3. Delete the DNS record for Calibre-Web from your registrar.

4. Optionally, manually delete the disk snapshots that were taken if backups were enabled from [here](https://console.cloud.google.com/compute/snapshots?tab=snapshots).
