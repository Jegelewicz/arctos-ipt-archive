# arctos-ipt-archive
Working with archived data from the GBIF ipt, collaborators are working on ways to provide important historical information to data providers.

## Prerequisites
In order to generate review reports, you need to work on the commandline (eek!) or Terminal. For Mac, open a terminal by using spotlight (search), type "Terminal". 

Following, you can start installing the required software as described below.


 * brew for helping to install stuff - https://brew.sh/
 * git for working with versioned files on the commandline ```brew install git``` see also https://git-scm.com/
 * mlr for working with tables ```brew install miller``` see https://miller.readthedocs.io/en/latest/installing-miller/
 * pv for estimating sizes of files ```brew install pv```
 * Preston for working with biodiversity data ```brew install globalbioticinteractions/globi/preston``` See also https://globalbioticinteractions.org/preston for install instructions

## Check Versions 

After installing the software, run the following commands on the commandline and verify that they produce official looking version numbers. 

```
git --version
preston --version
mlr --version
pv --version
```
