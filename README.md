# PTA Controller

The PTAController host is a VM that was created by Terraform and configured with ansible.
All your PTA terraform processes are intended to run from this Jenkins instance, 
except for the one to create this VM (chicken-and-egg problem).
Once you have setup the extra disk below, you can safely taint this VM and recreate it again as
all the pertinent information is stored on the secondary disk which persists.

For information about PTA and how to use it please visit https://github.com/Forcepoint/fp-pta-overview/blob/master/README.md

## First Run

Follow these steps the very first time you setup the PTAController. This assumes you have Artifactory configured
as the backend. If you do not, adjust the main.tf appropriately and be prepared to get that terraform state
backed up into Artifactory once you do have Artifactory up and running.

1. Modify main.tf appropriately for your vsphere instance. 

1. Modify jenkins.yml appropriately for how you want to configure your Jenkins instance.
Review the specifics of creating a jenkins master from the ansible role https://github.com/Forcepoint/fp-pta-ansible-docker-jenkins

1. Run the following commands to run terraform...
   
       set ARTIFACTORY_USERNAME=FLAST
       set ARTIFACTORY_PASSWORD=SuperSecretPass1
       terraform init -upgrade
       terraform apply

1. Log into the VM as the service user.
1. Run the role `extra-disk` with a mount path of `/mnt/extra` to configure the secondary disk.
   
        mkdir extra-disk
        cd extra-disk
        mkdir roles
        cd roles
        git clone https://github.com/Forcepoint/fp-pta-ansible-extra-disk.git extra-disk
        cd ..
        echo 'pta-controller ansible_connection=local' > hosts
        echo '- name: setup extra disk' > main.yml
        echo '  hosts: pta-controller' >> main.yml
        echo '  vars:' >> main.yml
        echo '    extra_disk_mount_path: /mnt/extra' >> main.yml
        echo '  roles:' >> main.yml
        echo '  - role: extra-disk' >> main.yml
        sudo pip install virtualenv
        virtualenv virt_ansible
        source virt_ansible/bin/activate
        pip install ansible
        ansible-playbook main.yml -i hosts
        deactivate
        cd ..
        rm -rf extra-disk

1. Run these commands to get the needed SSH keys on the box. They were created as part of the
   original packer process for the VM this came from.
   Be aware that if you do transfer/copy the files from a windows machine 
   that you don't mess up the line endings.
       
        sudo mkdir /mnt/extra/service
        sudo chown service:service /mnt/extra/service
        chmod 700 /mnt/extra/service
        <ENSURE YOU ENABLE INSERT BEFORE PASTING>
        vim /mnt/extra/service/id_rsa
        vim /mnt/extra/service/id_rsa.pub
        chmod 400 /mnt/extra/service/id_rsa
        chmod 400 /mnt/extra/service/id_rsa.pub
        ln -s /mnt/extra/service/id_rsa /home/service/.ssh/id_rsa
        ln -s /mnt/extra/service/id_rsa.pub /home/service/.ssh/id_rsa.pub
       
1. Create the vault password file on the secondary disk.

        <ENSURE YOU ENABLE INSERT BEFORE PASTING>
        vim /mnt/extra/service/vault_password.txt
        chmod 400 /mnt/extra/service/vault_password.txt
   
1. Follow `files\README.md` to create the pem and key files for the Jenkins server.
   You'll need to get them encrypted before you commit them to the repo.

1. Get this repository on the box however you can. 

1. Run ansible against main.yml to do the basic setup.
    
1. Run ansible against jenkins.yml as well.

1. Create the job in PTAController Jenkins to configure this VM.

1. Create all of the needed credential objects in PTAController Jenkins.

1. At the bottom of the Jenkinsfile, ensure you change the email address to your PTA 
administrator's address so they get failure notifications.

## Process for Reprovisioning the VM

This assumes you have Artifactory setup as the terraform backend setup and your Git server is up and running.

1. On another machine, run Terraform...

       set ARTIFACTORY_USERNAME=FLAST
       set ARTIFACTORY_PASSWORD=SuperSecretPass1
       terraform init -upgrade
       terraform apply

1. SCP this entire folder onto the new VM.
1. Remote onto the VM as the _**service**_ user.
1. CD into that folder, and then run the following...

       sudo pip install virtualenv
       
1. Look at the Jenkinsfile. Run each of those commands one after the other.
1. Export these environment variables appropriately. 
   Note that the PTAController uses the service user for it's Jenkins connection
   
       export JENKINS_MASTER_USERNAME=
       export JENKINS_MASTER_PASSWORD=
       export JENKINS_NODE_USERNAME=service
       export JENKINS_NODE_PASSWORD=

1. Finally, run this command...

       ansible-playbook -i hosts --vault-password-file /mnt/extra/service/vault_password.txt jenkins.yml

## Jenkins

Once you've got your PTA Controller Jenkins system setup, you'll want to run this job through
Jenkins itself, at least, the part that doesn't reconfigure Jenkins itself.

* Be sure you create all of the credential objects referred to in the Jenkinsfile.

* At the bottom of the Jenkinsfile, ensure you change the email address to your PTA 
administrator's address so they get failure notifications.
