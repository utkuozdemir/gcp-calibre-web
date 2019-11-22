# Calibre Server on Google Cloud

This project provides the Terraform scripts to deploy a simple but full-blown Calibre Server to Google Cloud Platform.

## Requirements

- Terraform Command Line Interface must be installed.  
  Download the CLI for your operating system and verify that it is working: https://www.terraform.io/downloads.html

- You need to have a Google Cloud project.  
  Go and create one with your Google Cloud if you don't have one:  
  https://console.cloud.google.com  
  Take note of your project ID, you'll need it on the installation.

- A SSH public/private key pair. Find out how to generate them. A description is the following:  
  https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key

## Installation

1. On Google Cloud Console, from IAM & admin -> Service Accounts, 
   create a service account for the Google Cloud project with a name like 
   `terraform@<YOUR_PROJECT_ID>.iam.gserviceaccount.com`.  
   Assign this service account the `Compute Admin` role.
  
2. Download the service account key JSON file, 
   rename it to `serviceaccount.json` and drop it into this project's root.

3. Drop the public/private key to the `keys/` directory with the following names respectively: `id_rsa.pub` and `id_rsa`

4. Create a file called `my.tfvars` under the project root. 
   Fill in the file with all the variables below according to your needs:
   ```hcl-terraform
   # put your email address, so you can get notified if 
   # your SSL certificate gets close to its expiration
   admin_email = "<YOUR_EMAIL@ADDRESS.COM>"
   # set the timezone. 
   # See the tz database names here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
   timezone = "Europe/Berlin"
   # if you are developing this project,
   # you don't want to hit the API rate limits of Let's Encrypt.
   # so, set this to true. If you want a valid SSL certificate, 
   # leave this to be false
   use_test_ssl_cert = false
   # the project ID on GCP that you noted down
   # as described in the requirements
   gcp_project_id = my-project-id-123
   # the GCP zone to host the VM and the resources
   # should belong to the region above
   # see: https://cloud.google.com/compute/docs/regions-zones/
   region = "europe-west3"
   # the GCP zone to host the VM and the resources
   # should belong to the region above
   # see: https://cloud.google.com/compute/docs/regions-zones/
   zone = "europe-west3-b"
   # how strong the machine should be.
   # more information here: https://cloud.google.com/compute/docs/machine-types
   # g1-small is the recommended minimum
   machine_type = "g1-small"
   # enable daily scheduled backups for the last 14 days
   backups_enabled = true
   # choose a disk size of your choice
   disk_size_in_gb = 32
   # use https://xip.io to get a domain name
   # (therefore an SSL certificate) for free
   use_xip_io_for_domain_name = true
   # only comment out and provide your own domain name if 
   # use_xip_io_for_domain_name is set to false
   # custom_domain_name = "myowndomain.example.com"
   ```

5. Apply Terraform resources. In project root, run:  

   ```shell script
   # terraform apply -var-file=my.tfvars
   ```
   Observe the prompt, and if all looks fine, write `yes` and press enter.
   Wait for all the resources to be deployed.

6. (Optional) If you provided your custom domain name using `custom_domain_name`, 
   take the `public_ip` from the output, and add a DNS record 
   from your custom domain name to this IP address.

7. Go to the `address` on the output on your web browser.
   You will be greeted by the initial setup screen of Calibre.  
   Leave all settings as-is, except:  
   * Set exactly `/books` as the Calibre library location.
   * Enable uploads and other additional features as you wish.
   Submit the settings.  
   (This is what is running on server: https://hub.docker.com/r/linuxserver/calibre-web/)

8. Login to Calibre-Web with the following credentials:
   ```
   admin
   admin123
   ```
   After doing it, *immediately go to settings and change your password*.

Congratulations, you have set up a secure Calibre Server.

## Uninstallation

1. In the project root, run:
   ```shell script
   # terraform destroy -var-file=my.tfvars
   ```
   Answer "yes" to the prompt to confirm deletion.
