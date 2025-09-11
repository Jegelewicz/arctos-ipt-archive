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

replace report with whatever wou named the report if it was something different
 
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
