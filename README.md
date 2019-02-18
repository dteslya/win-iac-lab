# win-iac-lab
This project can be used to create ad-hoc Windows labs. The included sample configurations create 3 virtual machines running Windows Server 2016 (2 domain controllers and a file server), but you can easily customize and extend it.
Project workflow consists of three stages:
* creation of Windows VM templates
* deployment of VMs out of those templates 
* applying OS configurations
It uses [Packer Builder for VMware vSphere](https://github.com/jetbrains-infra/packer-builder-vsphere) by JetBrains, Terraform and Ansible.
VMware vSphere serves as a virtualization platform.

## Prerequisites
* [Packer](https://packer.io)
* [Packer Builder for VMware vSphere](https://github.com/jetbrains-infra/packer-builder-vsphere)
* [Terraform](http://terraform.io)
* [Ansible](http://ansible.com)
* [pywinrm](https://github.com/diyan/pywinrm) module (`pip install pywinrm`)
* vSphere vCenter accessible from your workstation
* DHCP server for VM template building
* [Windows Server 2016 ISO](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016)

## Setup
* Clone this repo to your workstation (git clone https://github.com/dteslya/win-iac-lab)
* Make sure Packer, Terraform and Ansible binaries are all in PATH
* Download Packer Builder plugin from [Releases](https://github.com/jetbrains-infra/packer-builder-vsphere/releases) and place it in `packer` dir
* Remove `.example` extension from all the configuration files and adjust the variables according to your environment

## Packer
Packer setup consists of 3 main components:
* `windows-server-2016.json`
* `vars.json`
* `setup` dir containing files necessary for automatic Windows installation

`windows-server-2016.json` describes the connection parameters for vSphere, VM hardware including paths to Windows ISO and vmtools, and which files to put on virtual floppy drive. Those files are:
* `autounattend.xml` windows setup answer file
* `setup.ps1` powershell script which enables WinRM access for packer
* `vmtools.cmd` batch file which installs vmware tools

`vars.json` file contains all the values of the variables defined in `windows-server-2016.json`, including vSphere user and password. These two variables are marked as sensitive in `windows-server-2016.json` so that Packer doesn't reveal them during its run.

## Terraform
I tend to use one .tf file per VM for better readability.
* `01-PDC.tf` Primary Domain Controller VM
* `02-ReplicaDC.tf` Replica Domain Controller VM
* `03-FileServer.tf` File Server VM
* `base.tf` vCenter connection parameters
* `variables.tf` all variables are defined here
* `terraform.tfvars` variables' values (I keep this file in .gitignore)

## Ansible
I put 3 plays in one playbook: each for every server role.
* `winlab.yml` playbook
* `inventory.yml` all the hosts are defined here
* `ansible.cfg` ansible reads this file by default to find inventory and vault password files
* `groupvars/all.yml` all variables are defined here. I use Ansible Vault to encrypt sensitive data such as passwords (`ansible-vault encrypt_string string_to_encrypt`)

## How to use
### Build VM template
1. cd to `packer` dir
2. run `packer build -var-file=vars.json windows-server-2016.json`

### Deploy VMs
1. cd to `terraform` dir
2. run `terraform init`
3. run `terraform plan`
4. run `terraform apply`

### Configure VMs
1. cd to `ansible` dir
2. run `ansible-playbook winlab.yml`

## Acknowledgments
This project was initially inspired by SDBrett's [MCSA Lab](https://github.com/SDBrett/mcsa_lab)