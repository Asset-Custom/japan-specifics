#!/bin/bash
DEFAULT_PBO_ORG=$(sf force config get target-dev-hub --json |jq -r '.result[].value')
BRANCH=$(git rev-parse --abbrev-ref HEAD)
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
TAG=$(echo "${BRANCH:-main}-$TIMESTAMP")
PACKAGE_NAME="EquinoxCorporate - Japan specifics"

if [ -z "$PBO_ORG" ]; then
  read -p "Default PBO org is set to ${DEFAULT_PBO_ORG} . Do you want to continue with this? [Y/n]: " choice
  # Convert the user's choice to lowercase
  choice="${choice,,}"

  # Set the default value to "yes"
  default_choice="yes"

  # Check if the user's choice is empty (i.e., they pressed Enter)
  if [[ -z $choice ]]; then
      choice=$default_choice
  fi

  # Check the user's choice and act accordingly
  if [[ $choice == "y" || $choice == "yes" ]]; then
      PBO_ORG=$DEFAULT_PBO_ORG
      # Add your code here for what should happen if the user chooses to continue
  else
    echo "Please select the org hosting the package EquinoxCorporate : "
    select org in $(sf auth list --json  | jq ".result[].alias" | sed "s/\"//g" | sort -u); do 
      case $org in
        exit) echo "exiting"
              break ;;
          *) PBO_ORG=$org
              break ;;
    esac
    done 
  fi
fi
echo "PBO org : $PBO_ORG"

PACKAGE_ID=$(sf package list  --target-dev-hub $PBO_ORG --json | jq -r --arg name "$PACKAGE_NAME" '.result[] | select(.Name == $name) | .Id')
if [ -z "$PACKAGE_ID" ]; then

  # If package doesn-t exists on this org
  PACKAGE_ID=$(sf package create --name "$PACKAGE_NAME"  --package-type Managed --path force-app --target-dev-hub $PBO_ORG | tail -1 | sed "s/ Package Id //")
fi 

echo "PACKAGE_ID  : $PACKAGE_ID"


if [ -z "$SKIP_VALIDATION" ]; then

    read -p "Is it a beta version [Yy|Nn] ? " yn
    case $yn in
        [Yy]* ) echo "This will create a beta version";SKIP_VALIDATION=--skip-validation; break;;
        [Nn]* ) echo "This will create a release version";SKIP_VALIDATION=--code-coverage; break;;
        * ) echo "Please answer yes or no.";;
    esac
fi
echo "Skip validation flag : $SKIP_VALIDATION"


read -p "Do you want to skip ancestor check [Yy|Nn] ? " yn
case $yn in
    [Yy]* ) echo "This will create a beta version";SKIP_ANCESTOR_CHECK=--skip-ancestor-check; break;;
    [Nn]* ) echo "This will create a release version";SKIP_ANCESTOR_CHECK="";break;;
    * ) echo "Please answer yes or no.";;
esac

echo "create version with this cmd : sf package version create --branch ${BRANCH:-main} --tag $TAG  --definition-file ./config/project-scratch-def.json --path force-app --installation-key-bypass --target-dev-hub $PBO_ORG $SKIP_VALIDATION $SKIP_ANCESTOR_CHECK--verbose"
VERSION_ID=$(sf package version create --branch ${BRANCH:-main} --tag $TAG --definition-file ./config/project-scratch-def.json --path force-app --installation-key-bypass --target-dev-hub $PBO_ORG $SKIP_VALIDATION $SKIP_ANCESTOR_CHECK --verbose  | tail -1 | grep -oP "sf package:version:create:report -i \K[a-zA-Z0-9]+" )
echo "Newly created version ID : $VERSION_ID. Watch cmd : sf package:version:create:report -i ${VERSION_ID} --target-dev-hub $PBO_ORG"
watch sf package:version:create:report -i ${VERSION_ID} --target-dev-hub $PBO_ORG
