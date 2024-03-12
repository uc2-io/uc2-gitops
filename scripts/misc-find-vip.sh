#!/bin/bash
# set -x

#################################################################
# Figure out which node in the cluster is hosting API/Ingress VIP
#################################################################

if [ $# -ne 1 ]
then
  echo -e "Usage:\n$0 <vip>"
  exit
fi

VIP=$1

for node in $(oc get nodes --no-headers=true -o custom-columns=:.metadata.name)
do
  echo "Searching for VIP $VIP on node $node..."
  NODE_IPS=$(oc debug -q node/$node -- chroot /host sh -c "ip -br -4 a")

  if [[ $NODE_IPS =~ $VIP ]]
  then
    echo "Found on node $node!"
    echo -e "Output of \"ip -br -4 a\" from node $node:\n$NODE_IPS" | grep --color=always -E "$VIP|$"
    exit
  fi
done
