#!/bin/bash
# set -x

##############################################
# Dump files defined in MachineConfig resource
##############################################

function machine_decode {
  echo "$@" | \
    sed 's/data:,//' | \
    python -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()));"
}

function uniq_paths {
  for _i in $@
  do
    echo $(dirname "$_i")
  done | sort | uniq
}

function usage {
  echo -e "Usage:\n-d </path/to/extract/directory> (optional, default: /tmp)\n-m <MachineConfig Resource> (required)"
}

CHECK_JQ=$(command -v jq 2>&1)

if [ $? -ne 0 ]
then
  echo "jq is required, please install or make sure it is available in PATH."
  exit 1
fi

CHECK_PYTHON=$(command -v python 2>&1)

if [ $? -ne 0 ]
then
  echo "python is required, please install python or make sure it is available in PATH."
  exit 1
fi

D_FLAG=0
M_FLAG=0

DUMP_ROOT="/tmp"
MACHINE_CONFIG=""

while getopts 'd:m:h' opt
do
  case "$opt" in
    d)
      if [[ $OPTARG =~ ^- ]]
      then
        usage
        exit 1
      fi

      D_FLAG=1
      DUMP_ROOT=$OPTARG
      ;;
    m)
      if [[ $OPTARG =~ ^- ]]
      then
        usage
        exit 1
      fi

      M_FLAG=1
      MACHINE_CONFIG=$OPTARG
      ;;
    ?|h)
      usage
      exit 1
      ;;
  esac
done

# Make sure mandatory argument -m was passed
if [ $M_FLAG -eq 0 ]
then
  echo -e "Required:\n-m <MachineConfig Resource>"
  exit 1
fi

# Make sure $DUMP_ROOT exists
if [ ! -d $DUMP_ROOT ]
then
  echo "The directory passed via -d ($DUMP_ROOT) does not appear to exist..."
  exit 1
fi

CLUSTER_NAME_JSON="$(oc get infrastructure cluster -ojson 2>&1)"

# Make sure we can connect to the cluster
if [ $? -ne 0 ]
then
  echo -e "An error occured connecting to the Kubernetes API. Error:\n${CLUSTER_NAME}"
  exit 1
fi

CLUSTER_NAME=$(echo $CLUSTER_NAME_JSON | jq -r .status.infrastructureName)
MACHINE_CONFIG_OBJECT=$(oc get machineconfig $MACHINE_CONFIG -ojson 2>&1)

# Make sure MachineConfig resource exists
if [ $? -ne 0 ]
then
  echo "Unable to retrieve MachineConfig $MACHINE_CONFIG from cluster $CLUSTER_NAME..."
  exit 1
fi

_FILES=$(echo $MACHINE_CONFIG_OBJECT | jq -r .spec.config.storage.files[].path)
_PATHS=$(uniq_paths $_FILES)

# Make sure user is confortable with directories we're about to create
echo "The following directories will be created:"

for _i in $_PATHS
do
  echo "${DUMP_ROOT}/${MACHINE_CONFIG}${_i}"
done

echo "Is this correct?"

select yn in "Yes" "No"
do
  case $yn in
    Yes)
      break;;
    No)
      exit;;
  esac
done

# Create directory structure
for _i in $_PATHS
do
  _DIRECTORY="${DUMP_ROOT}/${MACHINE_CONFIG}${_i}"
  echo "Creating directory ${_DIRECTORY}..."
  mkdir -p $_DIRECTORY
done

# Dump files
for _i in $_FILES
do
  _CONTENT=$(echo $MACHINE_CONFIG_OBJECT | jq --arg file "$_i" -r '.spec.config.storage.files[] | select(.path == $file) | .contents.source')
  echo "Writing contents of ${DUMP_ROOT}/${MACHINE_CONFIG}${_i}..."
  machine_decode $_CONTENT > ${DUMP_ROOT}/${MACHINE_CONFIG}${_i}
done
