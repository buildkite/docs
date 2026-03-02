# Buildkite agents on Microsoft Azure

The Buildkite agent can be run on Microsoft Azure by installing the agent on your self-managed virtual machines, or by running agent jobs within a Kubernetes cluster using Azure Kubernetes Service (AKS). This page covers common installation and setup recommendations for different scenarios of using the Buildkite agent on Azure.

## Using the Buildkite Agent Stack for Kubernetes on Azure

The Buildkite agent's jobs can be run within a Kubernetes cluster on Azure using [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/products/kubernetes-service).

To start, you will need your own Kubernetes cluster running on AKS. Learn more in the [AKS documentation](https://learn.microsoft.com/azure/aks/).

Once your Kubernetes cluster is running on AKS, you can then set up the [Buildkite Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s) to run in this cluster. Learn more about how to set up the Agent Stack for Kubernetes in the [Agent Stack for Kubernetes installation documentation](/docs/agent/self-hosted/agent-stack-k8s/installation).

## Installing the agent on your own Azure instances

To run the Buildkite agent on your own [Azure virtual machine](https://azure.microsoft.com/products/virtual-machines), use whichever installer matches your instance operating system.

For example, to install on an Ubuntu-based virtual machine:

1. Launch a virtual machine using the latest Ubuntu LTS image (create via the portal or `az vm create`)
1. Connect using SSH (via the portal or `az ssh vm`)
1. Follow the [setup instructions for Ubuntu](/docs/agent/self-hosted/install/ubuntu)

For other Linux distributions, see:

- [Debian](/docs/agent/self-hosted/install/debian)
- [Red Hat/CentOS](/docs/agent/self-hosted/install/redhat)
