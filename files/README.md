# files

This folder is used to store static files that will be committed to the git repo, some of
which are used by Ansible.

## Files

* **plugins.txt** is a listing of all the Jenkins plugins to install in your Jenkins master.
You need to create this file yourself.
The first time you configure this system, I recommend you use follow the directions on
https://github.com/Forcepoint/fp-pta-ansible-docker-jenkins#plugins

* **san.cnf** is a certificate configuration file which you can use with openssl to generate a
key and CSR for your certificate. You should modify this file to reflect your company's
particulars and the website it is to serve up. 
You can then this file with an openssl command to generate the private key and CSR files.

        openssl req -new -newkey rsa:2048 -nodes -keyout ptacontroller.company.com.key -out ptacontroller.company.com.csr -config san.cnf

* **ptacontroller.company.com.key** is the private key that corresponds to your certificate which
the openssl command generated. This file should be vaulted and committed to this repo.
DO NOT COMMIT THIS UNVAULTED. The ansible roles docker-jenkins, docker-artifactory, and
docker-gitlab all look for a like named file for the host.

* **ptacontroller.company.com.csr** is the certificate request that your openssl command generated.
You submit the contents of this file to your CA to generate your certificate.

* **ptacontroller.company.com.pem** is the web certificate for your application. You obtain this file
from your CA. This file should be vaulted and committed to this repo. The ansible roles docker-jenkins, docker-artifactory, and
docker-gitlab all look for a like named file for the host.

## Walkthroughs

### Certificate Expiry

How to get the expiry date for a certificate...

    openssl x509 -enddate -noout -in ptacontroller.company.com.pem

### Ansible Vault

The PTAController VM acts as the place which runs all of your ansible playbooks. Naturally this
means that if you vault something, the vault password file has to be available on the disk.
Ansible documents how to use ansible vault here https://docs.ansible.com/ansible/latest/user_guide/vault.html

Here is an example command for encrypting a file... 

    ansible-vault encrypt --vault-password-file=/mnt/extra/service/vault_password.txt ptacontroller.company.com.key

### Internal Microsoft CA

If your company happens to host their own internal Microsoft CA, this is a quick walk-through
for obtaining your own certificate.
1. Navigate to the Microsoft CA webpage EX: https://ca.company.com/certsrv/certrqxt.asp
1. Copy/paste the contents of the CSR file you generated earlier.
1. Select Web Certificate.
1. Submit.
1. Select "DER Encoded" and download the certificate.
    1. I've found the encoding selection to be less than reliable. 
    Open the cer file and verify that it starts with `-----BEGIN CERTIFICATE-----`. 
    If not, download the file in the "other" format.
1. Place the cer file in the files folder, and rename it to ptacontroller.company.com.pem.
1. Copy the KEY and PEM files to PTAController, encrypt them with ansible vault, 
then copy them back off.
1. Commit those files to the git repo once encrypted, NOT BEFORE.
