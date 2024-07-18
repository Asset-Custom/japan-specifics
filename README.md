# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

# Analyze sources
Run this to get a quick status about Security error :
```
sf scanner:run --format=csv --outfile=CodeAnalyzerGeneral.csv  --target="./force-app/main/default" --projectdir="./"  --category="Security"
```

Run this to get a deeper status about Security error (long excecution):
```
sf scanner:run:dfa --format=csv --outfile=CodeAnalyzerDFA.csv  --target="./force-app/main/default" --projectdir="./" --category="Security"
```
# Equinox Corporate +
## Deployment process
use the script ./deploy-source-to-dev.sh
This script will deploy all source code from repository to the $TARGET_ENV. This script will also replace all occurences of $USERNAME_ADMIN with a technical user.
This user is used mainly into dashboards and report

## Retreive process
use the script ./retreive-source-from-prod-org.sh
This script will retreive all source code declared into the repository from the $TARGET_ENV.

If this command output some "...not found" in the report at the end, you will have to clean souce code and all other sandboxes from this content.
If you retreive source from prod org 'equinox-corporate.lightning.my.salesforce.com', don't bother about cleaning sandboxes issued from this, as you can just refresh them from Setup or DevOps Center
## Clean org from deleted items
copy/paste content of error report containing all not_founs

## Clean repository from deleted items
copy/paste 

## Questel environmnent
### PROD 
URL : https://equinox-corporate.lightning.force.com/

### devWS
URL : https://equinox-corporate--devws.sandbox.lightning.force.com/

### INT
URL : https://equinox-corporate--int.sandbox.lightning.force.com/

### UAT
URL : https://equinox-corporate--uat.sandbox.lightning.force.com/

### PREPROD
URL : https://equinox-corporate--preprod.sandbox.lightning.force.com/

### Package
exclude approvalProcesses before this
to create a beta version set BETA=beta

```
PACKAGE_ID=$(sfdx force package ${BETA} version create --package EquinoxCorporate --installation-key test12345 --wait 30 --skip-validation  --target-dev-hub questel-ec-devs | egrep -o "p0=(.*)" | sed "s/p0=//")
REPORT_CMD=$(sfdx force package ${BETA} install --no-prompt --package ${PACKAGE_ID} --installation-key test12345  --target-org=ec-testnpi |tail -1)
watch ${REPORT_CMD}
```

### Packages history 
 - 0.1.0: "0Ho8e000000wk2YCAQ" => not working
 - 0.1.0-2: "04t8e0000011OYhAAM"  => not working
 - 0.1.0-3: "04t8e0000011OYmAAM"  => not working
 - 0.1.0-4: "04t8e0000011OYrAAM"  => not working (Package contains Approval process that are not allowed)
 - 0.1.0-5: "04t8e0000011OYwAAM"  => not working (Package contains some standard resources that refers to missing SiteSample resources)
...
 - 0.1.0-17": "04t8e0000011Oe7AAE" => not working (ORA-01403: no data found ORA-06512: at "GRUMPY.CAPEXPAGE")
 - 0.1.0-18": "04t8e0000011OeCAAU" => not working (ORA-01403: no data found ORA-06512: at "GRUMPY.CAPEXPAGE")


 ### Install an existing version on new scratch org

```
$ sfdx force:org:create -f config/project-scratch-def.json --setalias scratch11 --durationdays 1 --setdefaultusername --json --loglevel debug
```


```
$ ./install-packages-to-org.sh 
1) ec-testnpi           4) india-int           7) india-trialroot    10) queste-devquest3   13) questel-ec-devs    16) questel-pbo        19) scratch1           22) scratch3           25) scratch8
2) india-dev            5) india-npierot       8) konecranes         11) questel-devquest1  14) questel-ec-tso     17) questel-preprod    20) scratch10          23) scratch6
3) india-ec-dev         6) india-prod          9) npierot-dev        12) questel-devquest2  15) questel-intque     18) questel-qalque     21) scratch2           24) scratch7
#? 20^C
```

```
$ ./install-ec-package-on-org.sh 
Please select the org hosting the package EquinoxCorporate : 
1) ec-testnpi           4) india-int           7) india-trialroot    10) queste-devquest3   13) questel-ec-devs    16) questel-pbo        19) scratch1           22) scratch3           25) scratch8
2) india-dev            5) india-npierot       8) konecranes         11) questel-devquest1  14) questel-ec-tso     17) questel-preprod    20) scratch10          23) scratch6
3) india-ec-dev         6) india-prod          9) npierot-dev        12) questel-devquest2  15) questel-intque     18) questel-qalque     21) scratch2           24) scratch7
#? 16
Please select the version of EquinoxCorporate (0Ho4N000000blLjSAI) to install : 
1) 0.8.0.15
2) 0.8.0.16
3) 0.8.0.17
4) 0.8.0.18
#? 4
sfdx package version list --target-dev-hub questel-pbo --packages 0Ho4N000000blLjSAI --json| jq -r --arg version 0.8.0.18 '.result[] | select(.Version == $version) | .SubscriberPackageVersionId'
Found version id : 04t4N000000cf9rQAA
1) ec-testnpi           4) india-int           7) india-trialroot    10) queste-devquest3   13) questel-ec-devs    16) questel-pbo        19) scratch1           22) scratch3           25) scratch8
2) india-dev            5) india-npierot       8) konecranes         11) questel-devquest1  14) questel-ec-tso     17) questel-preprod    20) scratch10          23) scratch6
3) india-ec-dev         6) india-prod          9) npierot-dev        12) questel-devquest2  15) questel-intque     18) questel-qalque     21) scratch2           24) scratch7
#? 20
Install package version  (04t4N000000cf9rQAA) on target org  scratch10 : sfdx package install --wait 15 -s AllUsers --no-prompt --package 04t4N000000cf9rQAA --installation-key test12345  --target-org=scratch10
Waiting 15 minutes for package install to complete.... ⣻ 11 minutes remaining until timeout. Install status: IN_PROGRESS
```


 ### Create a new version in interactive-mode

 ```
$ ./create-ec-package-version.sh 
Please choose your PBO hosting the package name :
1) ec-testnpi           5) india-npierot       9) npierot-dev        13) questel-ec-devs    17) questel-preprod    21) scratch2           25) scratch8
2) india-dev            6) india-prod         10) queste-devquest3   14) questel-ec-tso     18) questel-qalque     22) scratch3
3) india-ec-dev         7) india-trialroot    11) questel-devquest1  15) questel-intque     19) scratch1           23) scratch6
4) india-int            8) konecranes         12) questel-devquest2  16) questel-pbo        20) scratch10          24) scratch7
#? 16
PBO org : questel-pbo
PACKAGE_ID  : 0Ho4N000000blLjSAI
Is it a beta version? Y
This will create a beta version
./create-ec-package-version.sh: line 40: break: only meaningful in a `for', `while', or `until' loop
Skip validation flag : --skip-validation
create version with this cmd : sfdx package version create -d force-app --installation-key test12345 --target-dev-hub questel-pbo --verbose --skip-validation
Version create.... Create version status: Queued
Newly created version ID : 08c4N000000fxfPQAQ. Watch cmd : sfdx package:version:create:report -i 08c4N000000fxfPQAQ --target-dev-hub questel-pbo
$ ./install-ec-package-on-org.sh 
Please select the org hosting the package EquinoxCorporate : 
1) ec-testnpi           5) india-npierot       9) npierot-dev        13) questel-ec-devs    17) questel-preprod    21) scratch2           25) scratch8
2) india-dev            6) india-prod         10) queste-devquest3   14) questel-ec-tso     18) questel-qalque     22) scratch3
3) india-ec-dev         7) india-trialroot    11) questel-devquest1  15) questel-intque     19) scratch1           23) scratch6
4) india-int            8) konecranes         12) questel-devquest2  16) questel-pbo        20) scratch10          24) scratch7
#? 16
Please select the version of EquinoxCorporate (0Ho4N000000blLjSAI) to install : 
1) 0.8.0.15
2) 0.8.0.16
3) 0.8.0.17
4) 0.8.0.18
5) 0.8.0.19
#? 5
[...]
```

### Create a new version in batch-mode
```
$ export PBO_ORG=questel-pbo
$ export TARGET_ORG=scratch10
$ export SKIP_VALIDATION=--skip-validation
$ ./create-ec-package-version.sh 
PBO org : questel-pbo
PACKAGE_ID  : 0Ho4N000000blLjSAI
Skip validation flag : --skip-validation
create version with this cmd : sfdx package version create -d force-app --installation-key test12345 --target-dev-hub questel-pbo --verbose --skip-validation
Version create.... ⡿
```# EC+ flow-orchestration
