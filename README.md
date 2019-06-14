# kubeadm-terraform

## Before you begin, some things to take into consideration

- This example uses flannel as the CNI. If you would like to change it to something else, please edit the script `../modules/storage_azure/files/cni_setup.sh`.
- We are using Ubuntu 18.04. It should work with other distro's, but cloud-init commands will need to be adjusted accordingly. 16.04 should work without any modifications to anything other than the `storage_image_reference`.
- We are following a stacked etcd configuration. If you desire the etcd nodes to be a separate cluster, you will need to make adjustments.
- This setup works well for **3** masters, but will need to be tweaked slightly if you desire more. **I do not recommend you use less than 3**.
- Lastly, all **4** modules need to be used in conjunction. The master and worker modules heavily rely on the network and storage modules to build the foundational layers. I split each piece into a different module so they could more easily be iterated upon and understood.

## How to build a new cluster

**NOTE: You need to be on a whitelisted IP to build a new cluster and to interact with it.**

1. Ensure your `terraform.tfvars` file is up to date and has the correct azure credentials. You can obtain this from 1password. If you are creating a new environment, be sure that the `variables.tf` file here and `terraform.tfvars` file have the appropriate values for that environment.

2. Change the workspace. If you are deploying a "dev" cluster, then you need to be in the "dev" workspace. `terraform workspace new dev`.

3. Run `terraform plan`. If it looks good, run `terraform apply`.

4. If you run into an issue where the storage account cannot be created due to the virtual network in an "updating" state, re-run `terraform apply` again. The network will be ready at that point.

5. In the `output` directory you will have an SSH key to get into the masters. SSH into the first master as the airmap user (the IP's are outputted on success, or you can run `terraform output`). The kubeconfig will be `/etc/kubernetes/admin.conf` on the first master. You can copy that file to /tmp directory, chmod 777 it, and then scp it to your local machine. **You will need to change the server name of the kubeconfig file on your local machine to the value of the `masters_loadbalancer_fqdn`**.

6. Export your kubeconfig, then run `kubectl get nodes`. This should return a list of nodes, if it does not something is wrong and you should revisit step 5. If it looks good, you will need to apply the PSP YAML's to start spinning up the kube-proxy, DNS, flannel, api-server, controller, and scheduler pods in the kube-system namespace. After this, flux should be installed on the cluster as well so YAML's can be dumped into the Github repo that was created during the terraform run and applied to the cluster.

7. Off to the races.

## How does it work?

- The `main.tf` file calls several modules, one to build the storage location, one to build the network, one to build the masters configuration, and lastly, one that builds the workers.
- The masters are formed inside of an availability set, and are given a private and public IP address (public is for SSHing from a whitelisted IP). They are also situated behind an external and internal loadbalancer that will proxy all incoming requests to the API Servers.
- Master 0 runs the initial kubeadm commands to generate the certificates and tokens which will allow the rest of the control plane nodes to join the cluster, as well as the worker nodes. It does this by completely bootstrapping itself, copying the join commands to blob storage, and then creating a lockfile on the other 2 masters to initialize their bootstrap sequences. The other 2 control plane nodes run a script that is just waiting for that lockfile to exist so they can start their bootstrapping process.
- After the cluster is created, the workers will start to join the cluster...
- The workers are built in a Virtual Machine Scale Set, which allows them to utilize the node autoscaler to scale up and down depending on resource requirements.
- A cloud provider configuration file is rendered with the client ID and secret and placed on all of the nodes to enable components such as loadbalancers and pvcs to be created within the resource group.

## Items to note

- SSH keys do not need to be manually generated (yay!). Terraform will generate them for us per workspace, and place it in the `output` directory here. If the file is removed, and terraform is re-run on your local, it will notice the key is missing and recreate it for you.
