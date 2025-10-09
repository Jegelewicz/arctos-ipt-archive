# arctos-ipt-archive
Working with archived data from the GBIF ipt, collaborators are working on ways to provide important historical information to data providers.

## Prerequisites
In order to generate review reports, you need to work on the commandline (eek!) or Terminal. For Mac, open a terminal by using spotlight (search), type "Terminal". 

Following, you can start installing the required software as described below.


 * brew for helping to install stuff - https://brew.sh/
 * git for working with versioned files on the commandline ```brew install git``` see also https://git-scm.com/
 * mlr for working with tables ```brew install miller``` see https://miller.readthedocs.io/en/latest/installing-miller/
 * pv for estimating sizes of files ```brew install pv```
 * pandoc for generating reports in pdf/html etc. ```brew install pandoc```
 * xmllint for working with EML xml files ```brew install xmlstarlet```
 * jq for working with json files ```brew install jq```
 * pdflatex for working ```brew install basictex```
 * Preston for working with biodiversity data ```brew install globalbioticinteractions/globi/preston``` See also https://globalbioticinteractions.org/preston for install instructions

## Check Versions 

After installing the software, run the following commands on the commandline and verify that they produce official looking version numbers. 

```
git --version
preston --version
mlr --version
pv --version
xmllint --version
pdflatex --version
jq --version
pandoc --version
```

## Clone this repository

```
git clone https://github.com/Jegelewicz/arctos-ipt-archive
```

to get a recent version use

```
git pull --rebase
```

in the repository directory (e.g., ```arctos-ipt-archive```).

## Useful Commands

### Generate default report

```
./generate_report.sh > report.pdf
```

### Open the report

```
open report.pdf
```

### Generate Custom Report from Known DwC-A Content

You can also generate non-default reports of DwC-A if you know their sha256 hash

For instance, you can run a report for the Burke Museum dated June 2024 by running

```
./generate_report.sh\
 hash://sha256/5521cd12c64ce586376b463fcb1720b672ba87eb7dd581d90e524fa1c52e256b\
 > report-uwbm-2024-06.pdf
``` 

### Generate Custom Report from DwC-A Endpoint

First, track the content associated with a dwc-a endpoint using:

```
preston track\
 "https://ipt.vertnet.org/archive.do?r=uwbm_mammals"
```

observe the hash in the last line 

```
https://ipt.vertnet.org/archive.do?r=uwbm_mammals> <http://purl.org/pav/hasVersion> <hash://sha256/05b9bcff33b906c436a53f13aaea34ab9ed5c3901836126f112e497cfea44229> <urn:uuid:b30f94de-8497-4ac7-a7b2-cbcb431b42bd> .
```

and pick the hash value to start generating the report

```
./generate_report.sh\
 hash://sha256/05b9bcff33b906c436a53f13aaea34ab9ed5c3901836126f112e497cfea44229\
 > reportX.pdf
```

### Get data from preston

```
preston cat hash://sha256/97d6e90fa1a811e5a253ae25b51fa5b99d74356f997a27bded2aa08db4a1b5b7 > uwbm.zip
```

You need to know the hash!

### Open a Data File

```
open uwbm.zip
```

### Get JSON in a pretty format

```
% preston ls | preston dwc-stream | head -1 | jq .
```
