#!/bin/bash
#
# generate review for a DwC Archive
#

set -x

# this is a specific version of UWBM Mammals for now
dwca_id="hash://sha256/97d6e90fa1a811e5a253ae25b51fa5b99d74356f997a27bded2aa08db4a1b5b7"
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

citation="$(preston ls | preston cite)"
datasetName=$(preston cat "$eml_id" | xmllint --xpath '//dataset/title/text()' -)
datasetRecordCount=$(list_records | wc -l)
datasetVolume=$(preston cat $dwca_id | pv -f -b 2>&1 1>/dev/null | tr '\r' '\n' | grep -E '[0-9]' | tail -n1)
datasetTaxonCount=$(list_taxa | sort | uniq | wc -l)
datasetTaxonMostFrequent=$(list_taxa | sort | uniq -c | sort -nr | head -1 | sed -E 's/^\s+[0-9]+//g')
datasetTaxonFrequencyTable=$(cat <(echo scientificName) <(list_taxa) | mlr --itsvlite --omd count-distinct -f scientificName then sort -nr count | head -n22)
datasetCountryFrequencyTable=$(cat <(echo country) <(list_country) | mlr --itsvlite --omd count-distinct -f country then sort -nr count | head -n12)
datasetStateFrequencyTable=$(cat <(echo country) <(list_stateProvince) | mlr --itsvlite --omd count-distinct -f stateProvince then sort -nr count | head -n12)

generate_report() {
  cat <<_EOF_
---
title: Versioned Archive and Review of Collection Statistics found within ${datasetName} 
author: 
  - _insert Administrative point of contact_; _insert Administrative point of contact address_; _insert Administrative point of contact email_[^11] 
  - Mayfield-Meyer, Teresa J.; Albuquerque, New Mexico, USA; jegelewicz66@yahoo.com; https://orcid.org/0000-0002-1970-7044
  - Poelen, Jorrit; Minneapolis, Minnesota, USA; jhpoelen@jhpoelen.nl; https://orcid.org/0000-0003-3138-4118
  - Nomer, Elton and Preston, three naive review bots; review@globalbioticinteractions.org; https://globalbioticinteractions.org/contribute; https://github.com/AgentschapPlantentuinMeise/ashForestInteractions/issues
identifier:
  - "urn:lsid:gbif.org:dataset:830eb5d0-f762-11e1-a439-00145eb45e9a"
  - https://gbif.org/dataset/830eb5d0-f762-11e1-a439-00145eb45e9a
  - https://ipt.vertnet.org/archive.do?r=uwbm_mammals 
  - "https://linker.bio/urn:uuid:830eb5d0-f762-11e1-a439-00145eb45e9a"
  - https://ipt.vertnet.org/archive.do?r=uwbm_mammals 
abstract: |
  Natural history collections are part of our global heritage and a priceless resource for research and education. Information about the contents of Natural History Collections may be captured in datasets and published digitally via the Global Biodiversity Information Facility (GBIF) Integrated Publishing Toolkit (IPT)as Darwin Core Archives (DwC-A). We present a review and archiving process for such an openly accessible digital dataset of known origin and discuss its outcome. The dataset under review, named ${datasetName}, has fingerprint %DATASET_ID%, is ${datasetVolume} in size and contains ${datasetRecordCount} occurrences with ${datasetTaxonCount} unique taxon names (e.g., ${datasetTaxonMostFrequent}). This report includes summaries of collection statistics, taxonomic context, geographic context, temporal context, geologic context, and an archived version of the dataset from which the reviews are derived. 

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

"Natural history collections are part of our global heritage and a priceless resource for research and education."[^7] Information about the contents of Natural History Collections may be captured in datasets and published digitally via the Global Biodiversity Information Facility (GBIF) Integrated Publishing Toolkit (IPT)[^8] as Darwin Core Archives (DwC-A)[^9]. We present a review and archiving process for such an openly accessible digital dataset of known origin and discuss its outcome. The dataset under review is named ${datasetName}, has fingerprint ${dwca_id}, and is ${datasetVolume} in size. 

## Data Review and Archive 

Data review and archiving can be a time-consuming process, especially when done manually. This review report aims to help facilitate both activities. It automates the archiving of datasets, including Darwin Core Archives, and is a citable backup of a version of the dataset. 

This review includes summary statistics about, and observations about, the dataset under review: 

> ${citation} 

For additional metadata related to this dataset, please visit _insert_ and inspect associated metadata files including, but not limited to, _README.md_, _eml.xml_, and/or _globi.json_. 

_should this really just be a link to the GBIF metadata?_ 

_Possible to get the Latimer Core required terms from the metadata? - https://ltc.tdwg.org/quick-reference/_ 

# Methods 

The review is performed through programmatic scripts that leverage tools like Preston [@Preston], Elton [@Elton], Nomer [@Nomer], combined with third-party tools like grep, mlr, tail and head. 

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

The review process can be described in the form of the script below ^[Note that you have to first get the data (e.g., via elton pull AgentschapPlantentuinMeise/ashForestInteractions) before being able to generate reviews (e.g., elton review AgentschapPlantentuinMeise/ashForestInteractions), extract interaction claims (e.g., elton interactions AgentschapPlantentuinMeise/ashForestInteractions), or list taxonomic names (e.g., elton names AgentschapPlantentuinMeise/ashForestInteractions)]. 

~~~
# get versioned copy of the dataset (size approx. 2.94MiB) under review 
elton pull AgentschapPlantentuinMeise/ashForestInteractions

# generate review notes
elton review AgentschapPlantentuinMeise/ashForestInteractions\
 > review.tsv
~~~

or visually, in a process diagram.

You can find a copy of the full review script at [_insert_]. See also [GitHub](_insert_). 

# Results

In the following sections, the results of the review are summarized [^1]. Then, links to the detailed review reports are provided. 

## Review Summary 

In this review, collection statistics are modeled as Darwin Core[^4] or Latimer Core[^5] terms. 

The dataset under review, named ${datasetName}, is ${datasetVolume} in size and contains ${datasetRecordCount} occurence records with ${datasetTaxonCount} unique taxon names (e.g., %DATASET_TAXON_MOST_FREQUENT%).

An exhaustive list of occurences can be found in gzipped [csv](indexed-interactions.csv.gz), [tsv](indexed-interactions.tsv.gz) and [parquet](indexed-interactions.parquet) archives. The exhaustive list was used to create the following data summaries below.

### Collection Statistics 

| name | value | 
| --- | --- |
| number of unique occurrences | ${datasetRecordCount} |
| number of occurrences added since last review | _insert_ |
| number of occurrences removed since last review | _insert_ |  

_Can we provide a last 12 months growth graph using previous reports? wish list - maybe once we have confirmed this is a good idea_ 

### Taxonomic Context 

| name | value |
| --- | --- | 
| **Number of unique taxonNames:** | ${datasetTaxonCount} | 
| **Number of taxonName added since last review:** | _insert_ | 
| **Number of taxonName removed since last review:** |  _insert_ | 

: Most Frequently Mentioned Taxon Names (up to 20 most frequent)
${datasetTaxonFrequencyTable}

### Geographic Context

${datasetCountryFrequencyTable}
: Most Frequently Mentioned Countries (up to 10 most frequent)

Most represented States (up to 10 most frequent)
${datasetStateFrequencyTable}

### Temporal Context

**Earliest eventDate:** $(list_event_dates | head -1)  
**Latest eventDate:** $(list_event_dates | tail -1)  

### Geologic Context 

**earliestEonOrLowestEonothem:** _insert_  
**latestEonOrLowestEonothem:** _insert_  

**earliestEraOrLowestErathem:** _insert_  
**latestEraOrLowestErathem:** _insert_  

**earliestPeriodOrLowestSystem:** _insert_  
**latestPeriodOrLowestSystem:** _insert_  

**earliestEpochOrLowestSeries:** _insert_  
**latestEpochOrLowestSeries:** _insert_  

**earliestAgeOrLowestStage:** _insert_  
**latestAgeOrLowestStage:** _insert_  

## Files

The following files are produced in this review: 

 filename | description
 --- | ---  
 ... | ...

## Archived Dataset

Note that [_data.zip_](data.zip) file in this archive contains the complete, unmodified archived dataset under review. 

You can download the indexed dataset under review at [indexed-interactions.csv.gz](indexed-interactions.csv.gz). A tab-separated file can be found at [indexed-interactions.tsv.gz](indexed-interactions.tsv.gz) 

Learn more about the structure of this download at _insert_), by opening a [GitHub issue](_insert_).

Another way to discover the dataset under review is by searching for it on the [_insert_](_insert_).

## Additional Reviews

Elton, Nomer, and other tools may have difficulties interpreting existing species interaction datasets. Or, they may misbehave, or otherwise show unexpected behavior. As part of the review process, detailed review notes are kept that document possibly misbehaving, or confused, review bots. An sample of review notes associated with this review can be found below.

| reviewDate | reviewCommentType | reviewComment |
| --- | --- | --- |
| 2025-07-24T09:03:02Z | note | found unsupported interaction type with id: [http://purl.obolibrary.org/obo/RO_0002559] and name: [causally influenced by] |
| 2025-07-24T09:03:02Z | note | found unsupported interaction type with id: [http://purl.obolibrary.org/obo/RO_0002559] and name: [causally influenced by] |
| 2025-07-24T09:03:02Z | note | found unsupported interaction type with id: [http://purl.obolibrary.org/obo/RO_0002559] and name: [causally influenced by] |
| 2025-07-24T09:03:02Z | note | found unsupported interaction type with id: [http://purl.obolibrary.org/obo/RO_0002559] and name: [causally influenced by] |
: First few lines in the review notes.

In addition, you can find the most frequently occurring notes in the table below.

| reviewComment | count |
| --- | --- |
| found unsupported interaction type with id: [http://purl.obolibrary.org/obo/RO_0002226] and name: [develops in] | 30 |
| found unsupported interaction type with id: [http://purl.obolibrary.org/obo/RO_0002559] and name: [causally influenced by] | 21 |
: Most frequently occurring review notes, if any.

For additional information on review notes, please have a look at the first 500 [Review Notes](review-sample.html) in html format or the download full gzipped [csv](review.csv.gz) or [tsv](review.tsv.gz) archives.

_do we need any of the GloBI stuff?_
## GloBI Review Badge

As part of the review, a review badge is generated. This review badge can be included in webpages to indicate the review status of the dataset under review. 

Note that if the badge is green, no review notes were generated. If the badge is yellow, the review bots may need some help with interpreting the species interaction data.

# Discussion

This review and archive provides a means of creating a citable version of a dataset that changes frequently. This may be useful for dataset managers, including natural history collection data managers, as a backup archive of a shared Darwin Core archive. It also serves as a means of creating a trackable citation for the dataset in an automated way, while also including some information about the contents of the dataset.

This review aims to provide a perspective on the dataset to aid in understanding digitization progress and data quality management. However, it is important to note that this review does *not* assess the quality of the dataset. Instead, it serves as an indication of the open-ness[^2] and FAIRness[^10] of the dataset: to perform this review, the data was likely openly available, **F**indable, **A**ccessible, **I**nteroperable and **R**eusable. The current Open-FAIR assessment is qualitative, and a more quantitative approach can be implemented with specified measurement units. 

This report also showcases the reuse of machine-actionable (meta)data, something highly recommended by the FAIR Data Principles[^10]. Making (meta)data machine-actionable enables more precise procesing by computers, enabling even naive review bots like Nomer and Elton to interpret the data effectively. This capability is crucial for not just automating the generation of reports, but also for facilitating seamless data exchanges, promoting interoperability. 

# Acknowledgements

We thank the many humans that created us and those who created and maintained the data, software and other intellectual resources that were used for producing this review. In addition, we are grateful for the natural resources providing the basis for these human and bot activities. Also, thanks to https://github.com/zygoballus for helping improve the layout of the review tables. 

# Author contributions

_GBIF Administrative Contact contact details as provided to GBIF. _get from GBIF API - https://www.gbif.org/dataset/830eb5d0-f762-11e1-a439-00145eb45e9a#contacts: Administrative point of contact insert_ provided the original data reviewed in this report.

Nomer was responsible for name alignments. Elton carried out dataset extraction, and generated the review notes. Preston tracked, versioned, and packaged, the dataset under review.

Teresa J. Mayfield-Meyer developed the text and results content for the reports produced in this review.

Jorrit Poelen developed the scripts used to create results values for the reports produced in this review.

# References
_the first two are sorta references, but also not - I think we should clean them up_

[^1]: Disclaimer: The results in this review should be considered friendly, yet naive, notes from an unsophisticated robot. Please keep that in mind when considering the review results. 
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
 | sed -e "s|%CITATION%|$citation|g"\
 | sed -e "s|%DATASET_NAME%|$datasetName|g"\
 | sed -e "s|%DATASET_ID%|$dwca_id|g"\
 | sed -e "s|%DATASET_RECORD_COUNT%|$datasetRecordCount|g"\
 | sed -e "s|%DATASET_TAXON_COUNT%|$datasetTaxonCount|g"\
 | sed -e "s|%DATASET_TAXON_MOST_FREQUENT%|$datasetTaxonMostFrequent|g"\
 | sed -e "s|%DATASET_VOLUME%|$datasetVolume|g"\
 | pandoc --from markdown --to pdf

