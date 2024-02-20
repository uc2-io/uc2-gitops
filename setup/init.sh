#!/bin/bash
set -x

#################################################################
# Installs OpenShift GitOps Operator and Deploys Argo CD Instance
#################################################################

SCRIPT_BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "Deploying OpenShit GitOps..."
helm dependency update "${SCRIPT_BASE_DIR}/../charts/operator"
helm upgrade -i -n openshift-operators openshift-gitops-operator "${SCRIPT_BASE_DIR}/../charts/operator" -f "${SCRIPT_BASE_DIR}/values-init.yaml"

# Wait for argocds.argoproj.io CRD Deployment
echo "Waiting for crd/argocds.argoproj.io to become available..."
until kubectl wait crd/argocds.argoproj.io --for condition=established &>/dev/null; do sleep 5; done

echo "Creating OpenShift GitOps Namespace..."
helm dependency update "${SCRIPT_BASE_DIR}/../charts/namespace"
helm upgrade -i openshift-gitops-namespace "${SCRIPT_BASE_DIR}/../charts/namespace" -f "${SCRIPT_BASE_DIR}/values-init.yaml"

echo "Deploying OpenShift GitOps CD..."
helm dependency update "${SCRIPT_BASE_DIR}/../charts/argocd"
helm upgrade -i -n $(yq '.namespaces[0].name' ${SCRIPT_BASE_DIR}/values-init.yaml) openshift-gitops "${SCRIPT_BASE_DIR}/../charts/argocd"
