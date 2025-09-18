#!/bin/bash
#
# generate review for a DwC Archive
#

set -x

# this is a specific version of UWBM Mammals for now
dwca_id="hash://sha256/97d6e90fa1a811e5a253ae25b51fa5b99d74356f997a27bded2aa08db4a1b5b7"
dwc_id_md5="hash://md5/53f31a089339194f333d2e3995dbb05e"
eml_id='zip:hash://sha256/97d6e90fa1a811e5a253ae25b51fa5b99d74356f997a27bded2aa08db4a1b5b7!/eml.xml'

list_records() {
  preston ls\
 | grep hasVersion\
 | grep "${dwca_id}"\
 | preston dwc-stream
}

list_taxa() {
  list_records\
 | jq --raw-output '.["http://rs.tdwg.org/dwc/terms/scientificName"]'
}

list_event_dates() {
  list_records\
 | jq --raw-output '.["http://rs.tdwg.org/dwc/terms/eventDate"]'\
 | tr '/' '\n'\
 | grep -Eo "^[0-9]{4}.*"\
 | sort\
 | uniq
}

list_country() {
  list_records\
 | jq --raw-output '.["http://rs.tdwg.org/dwc/terms/country"]'
}

list_stateProvince() {
  list_records\
 | jq --raw-output '.["http://rs.tdwg.org/dwc/terms/stateProvince"]'
}

list_basisOfRecord() {
  list_records\
 | jq --raw-output '.["http://rs.tdwg.org/dwc/terms/basisOfRecord"]'
}

citation="$(preston ls | preston cite)"
datasetName=$(preston cat "$eml_id" | xmllint --xpath '//dataset/title/text()' -)
datasetLicense=$(preston cat "$eml_id" | xmllint --xpath '//dataset/licensed/licenseName/text()' -)
datasetPubDate=$(preston cat "$eml_id" | xmllint --xpath '//dataset/pubDate/text()' -)
datasetRecordCount=$(list_records | wc -l)
datasetVolume=$(preston cat $dwca_id | pv -f -b 2>&1 1>/dev/null | tr '\r' '\n' | grep -E '[0-9]' | tail -n1)
datasetTaxonCount=$(list_taxa | sort | uniq | wc -l)
datasetTaxonMostFrequent=$(list_taxa | sort | uniq -c | sort -nr | head -1 | sed -E 's/^\s+[0-9]+//g')
datasetTaxonFrequencyTable=$(cat <(echo scientificName) <(list_taxa) | mlr --itsvlite --omd count-distinct -f scientificName then sort -nr count | head -n22)
datasetCountryCount=$(list_country | sort | uniq | wc -l)
datasetCountryFrequencyTable=$(cat <(echo country) <(list_country) | mlr --itsvlite --omd count-distinct -f country then sort -nr count | head -n12)
datasetStateCount=$(list_stateProvince | sort | uniq | wc -l)
datasetStateFrequencyTable=$(cat <(echo stateProvince) <(list_stateProvince) | mlr --itsvlite --omd count-distinct -f stateProvince then sort -nr count | head -n12)
datasetTypeFrequencyTable=$(cat <(echo basisOfRecord) <(list_basisOfRecord) | mlr --itsvlite --omd count-distinct -f basisOfRecord then sort -nr count)

generate_report() {
  cat <<_EOF_
---
title: Versioned Archive and Review of Collection Statistics found within ${datasetName} 
author: 
  - "Mayfield-Meyer, Teresa J.; https://orcid.org/0000-0002-1970-7044" 
  - "Poelen, Jorrit; https://orcid.org/0000-0003-3138-4118" 
identifier:
  - "urn:lsid:gbif.org:dataset:830eb5d0-f762-11e1-a439-00145eb45e9a" 
  - https://gbif.org/dataset/830eb5d0-f762-11e1-a439-00145eb45e9a 
  - https://ipt.vertnet.org/archive.do?r=uwbm_mammals 
  - "https://linker.bio/urn:uuid:830eb5d0-f762-11e1-a439-00145eb45e9a" 
  - https://ipt.vertnet.org/archive.do?r=uwbm_mammals  
abstract: |
  Natural history collections are part of our global heritage and a priceless resource for research and education. Information about the contents of Natural History Collections may be captured in datasets and published digitally via the Global Biodiversity Information Facility (GBIF) Integrated Publishing Toolkit (IPT) as Darwin Core Archives (DwC-A). We present a review and archiving process for such an openly accessible digital dataset of known origin and discuss its outcome. The dataset under review, named ${datasetName}, has fingerprint ${dwca_id}, is ${datasetVolume} in size and contains ${datasetRecordCount} occurrences with ${datasetTaxonCount} unique taxon names (e.g., ${datasetTaxonMostFrequent}). This report includes summaries of collection statistics, taxonomic context, geographic context, temporal context, and an archived version of the dataset from which the reviews are derived. 

bibliography: biblio.bib 
keywords: 
  - biodiversity informatics 
  - museum collections 
  - automated manuscripts 
  - taxonomic names 
  - biology 
reference-section-title: References 
---

# Introduction 

"Natural history collections are part of our global heritage and a priceless resource for research and education."[^7] Information about the contents of Natural History Collections may be captured in datasets and published digitally via the Global Biodiversity Information Facility (GBIF) Integrated Publishing Toolkit (IPT)[^8] as Darwin Core Archives (DwC-A)[^9]. We present a review and archiving process for such an openly accessible digital dataset of known origin and discuss its outcome. 

## Data Review and Archive 

Data review and archiving can be a time-consuming process, especially when done manually. This review report aims to help facilitate both activities. It automates the archiving of Darwin Core Archives, and is a citable backup of a version of the dataset. The dataset under review is named ${datasetName}, was published on ${datasetpubDate}, has fingerprint ${dwca_id}, and is ${datasetVolume} in size with a ${datasetLicense} data license.

For additional metadata related to this dataset, please visit _insert_ and inspect associated metadata files including, but not limited to, _README.md_, _eml.xml_, and/or _globi.json_. 

# Methods 

The review is performed through programmatic scripts that leverage tools like Preston [@Preston], Elton [@Elton], and Nomer [@Nomer] combined with third-party tools like grep, mlr, tail and head. 

## Tools used in this review process
 | tool name | version | 
 | --- | --- | 
 | [preston](https://github.com/bio-guoda/preston) | 0.10.1 |  
 | [elton](https://github.com/globalbioticinteractions/elton) | 0.15.13 | 
 | [nomer](https://github.com/globalbioticinteractions/nomer) | 0.5.17 |  
 | [mlr](https://miller.readthedocs.io/en/6.8.0/) | 6.0.0 |  
 | [jq](https://jqlang.org/) | 1.6 |  
 | [yq](https://mikefarah.gitbook.io/yq) | 4.25.3 |  
 | [pandoc](https://pandoc.org/) | 3.1.6.1 |  
 | [duckdb](https://duckdb.org/) | 1.3.1 |  

The full review script can be found at [_insert_]. See also [GitHub](https://github.com/Jegelewicz/arctos-ipt-archive/blob/main/generate_report.sh). 

# Results

In the following sections, the results of the review are summarized. The results in this review should be considered friendly notes from an unsophisticated robot. Please keep that in mind when considering the review results. Links to the detailed review reports are also provided. 

## Review Summary 

In this review, collection statistics are modeled as Darwin Core[^4] or Latimer Core[^5] terms. 

The dataset under review, named ${datasetName}[^3], is ${datasetVolume} in size and contains ${datasetRecordCount} occurence records with ${datasetTaxonCount} unique taxon names (e.g., ${datasetTaxonMostFrequent}).

An exhaustive list of occurences can be found in gzipped [csv](occurence.csv), [tsv](occurence.tsv) and [parquet](occurence.parquet) archives. The exhaustive list was used to create the following data summaries below.

### Collection Statistics 

The dataset includes ${datasetRecordCount} unique occurrences with _insert_ occurrences added since last review and _insert_ occurrences removed since last review. The related occurences are supported by the following basis of record types:  

${datasetTypeFrequencyTable}
: **Occurence Data Basis of Record Counts**  

### Taxonomic Context 

The dataset includes ${datasetTaxonCount} unique taxonomic names with _insert_ names added since last review and _insert_ names removed since last review. An exhaustive list of unique taxon names can be found in [Unique Taxa](indexed-names.csv.gz). The 20 most frequently encountered names are listed below:

${datasetTaxonFrequencyTable}
: **Most Frequently Mentioned Taxon Names (up to 20 most frequent)**

### Geographic Context

The dataset includes occurences from ${datasetCountryCount} unique countries. An exhaustive list of unique countries can be found in [Unique Country](countries.csv). The 10 most frequently encountered countries are listed below:

${datasetCountryFrequencyTable}
: **Most Frequently Mentioned Countries (up to 10 most frequent)**

The dataset includes occurences from ${datasetStateCount} unique states. An exhaustive list of unique states can be found in [Unique State](states.csv). The 10 most frequently encountered states are listed below:

${datasetStateFrequencyTable}
: **Most Frequently Mentioned States (up to 10 most frequent)**

### Temporal Context

The dataset includes occurences from $(list_event_dates | head -1) to $(list_event_dates | tail -1). 

<!--- ### Geologic Context 

**earliestEonOrLowestEonothem:** _insert_  
**latestEonOrLowestEonothem:** _insert_  

**earliestEraOrLowestErathem:** _insert_  
**latestEraOrLowestErathem:** _insert_  

**earliestPeriodOrLowestSystem:** _insert_  
**latestPeriodOrLowestSystem:** _insert_  

**earliestEpochOrLowestSeries:** _insert_  
**latestEpochOrLowestSeries:** _insert_  

**earliestAgeOrLowestStage:** _insert_  
**latestAgeOrLowestStage:** _insert_  --->

## Files

The following files are produced in this review: 

| filename | description | 
| --- | --- | 
| biblio.bib |	list of bibliographic reference of this review | 
| check-dataset.sh |	data review workflow/process as expressed in a bash script | 
| data.zip |	a versioned archive of the data under review | 
| HEAD |	the digital signature of the data under review | 
| review.docx |	review in MS Word format | 
| review.html |	review in HTML format | 
| review.md |	review in Pandoc markdown format | 
| review.pdf |	review in PDF format | 
| occurence.csv | the dwc occurence file as obtained from the GBIF IPT in comma-separated values format | 
| occurence.tsv | the dwc occurence file as obtained from the GBIF IPT in tab-separated values format | 
| occurence.parquet | the dwc occurence file as obtained from the GBIF IPT in Apache Parquet format | 
| taxa.csv |	a list of taxonomic names and their frequencey the dataset under review in comma-separated values format | 
| taxa.html |	taxonomic names found in the dataset under review in gzipped html format | 
| taxa.tsv |	taxonomic names found in the dataset under review in gzipped tab-separated values format | 
| taxa.parquet |	taxonomic names found in the dataset under review in Apache Parquet format | 
| countries.csv | a list of unique countries and their frequency found in the dataset in comma-separated values format | 
| states.csv | a list of unique states and their frequency found in the dataset in comma-separated values format | 
| process.svg |	diagram summarizing the data review processing workflow | 
| prov.nq |	origin of the dataset under review as expressed in rdf/nquads | 
| zenodo.json |	metadata of this review expressed in Zenodo record metadata | 

## Archived Dataset

Note that [_data.zip_](data.zip) file in this archive contains the complete, unmodified archived dataset under review. 

Learn more about the structure of this download at _insert_), by opening a [GitHub issue](_insert_).

Another way to discover the dataset under review is by searching for it on the [_insert_](_insert_).

# Discussion

This review and archive provides a means of creating a citable version of a dataset that changes frequently. This may be useful for dataset managers, including natural history collection data managers, as a backup archive of a shared Darwin Core Archive. It also serves as an automated means of creating a trackable citation for the dataset and information about its contents.

This review aims to provide a perspective on the dataset to aid in understanding digitization progress and data quality management. However, it is important to note that this review does *not* assess the quality of the dataset. Instead, it serves as an indication of the open-ness[^2] and FAIRness[^10] of the dataset. In order to perform this review, the data was openly available, **F**indable, **A**ccessible, **I**nteroperable and **R**eusable. The current Open-FAIR assessment is qualitative, and a more quantitative approach can be implemented with specified measurement units. 

This report also showcases the reuse of machine-actionable (meta)data, something highly recommended by the FAIR Data Principles[^10]. Making (meta)data machine-actionable enables more precise procesing by computers, enabling even naive review bots like Nomer and Elton to interpret the data effectively. This capability is crucial for not just automating the generation of reports, but also for facilitating seamless data exchanges and promoting interoperability. 

# Acknowledgements

We thank the many humans that created us and those who created and maintained the data, software and other intellectual resources that were used for producing this review. In addition, we are grateful for the natural resources providing the basis for these human and bot activities.  

# Author contributions

_GBIF Administrative Contact contact details as provided to GBIF. _get from GBIF API - https://www.gbif.org/dataset/830eb5d0-f762-11e1-a439-00145eb45e9a#contacts: Administrative point of contact insert_ provided the original data reviewed in this report.

Nomer was responsible for name alignments. Elton carried out dataset extraction, and generated the review notes. Preston tracked, versioned, and packaged, the dataset under review.

Teresa J. Mayfield-Meyer developed the text and results content for the reports produced in this review.

Jorrit Poelen developed the scripts used to create results values for the reports produced in this review.

# References

[^2]: According to http://opendefinition.org/: "Open data is data that can be freely used, re-used and redistributed by anyone - subject only, at most, to the requirement to attribute and sharealike."
[^3]: Bradley J (2025). UWBM Mammalogy Collection (Arctos). University of Washington Burke Museum. Occurrence dataset https://doi.org/10.15468/qziy3w accessed via GBIF.org on 2025-09-05. _from GBIF API_
[^4]: Darwin Core Maintenance Group. 2021. Darwin Core Quick Reference Guide. Biodiversity Information Standards (TDWG). https://dwc.tdwg.org/terms/
[^5]: Biodiversity Information Standards (TDWG). (n.d.). Latimer Core Documentation. Latimer Core. https://ltc.tdwg.org/ 
[^6]: The VertNet IPT. VertNet. (2025). https://www.vertnet.org/share/ipt/ 
[^7]: What SPNHC does. The Society for the Preservation of Natural History Collections. (2025). https://spnhc.org/what-spnhc-does/ 
[^8]: Global Biodiversity Information Facility. (n.d.). IPT. https://www.gbif.org/ipt 
[^9]: Global Biodiversity Information Facility. (n.d.). Darwin Core Archives – How-To Guide. Darwin Core Archives – How-to Guide :: GBIF IPT User Manual. https://ipt.gbif.org/manual/en/ipt/latest/dwca-guide#what-is-darwin-core-archive-dwc-a 
[^10]: @Wilkinson_2016; @trekels_maarten_2023_8176978 
[^11]: _insert GBIF dataset publisher. Metadata last modified. website title. website address._  
_EOF_
}

generate_report\
  | pandoc --from markdown --to pdf

