# SAviTraits_database
This database (SAviTraits 1.0) provides a compilation of species-specific dietary preferences and their known intra-annual variation for the world’s 10,672 species of birds. SAviTraits 1.0 uses dietary categories described by EltonTraits 1.0 (Wilman et al., 2014). Information on dietary preferences was obtained from the Cornell's Lab of Ornithology Birds of the World (BOW) online database (Billerman et al. 2022). Textual descriptions of species’ dietary preferences were translated into semi-quantitative information denoting the proportion of dietary categories utilized by each species. More details available in Murphy et al. (2023).

Additional metadata for each database file:

SAviTraits_1-0_1.csv database file.
Species_Scientific_Name:	Scientific species name, using eBird/Clements Checklist v2022 taxonomic authority (used by SAviTraits 1.0);
Diet_Cat: Diet category;
Diet_Sub_Cat: Diet subcategory;
Jan - Dec: 	Species’ diet in each month, January through December;
Diet_Variability: Binary indicator of whether diet varies across seasons: Yes, No;
Recorded_By: Name of primary transcriber of diet data; RJM: Reymond J. Miyajima; NAS: Natalie A. Sebunia; MML: Molly M. Lynch;
Diet_Comments: Additional comments regarding diet;
Other_Comments: Any additional comments.

SAviTraits_1-0_2.csv database file:
BOW_Code: The reference code for the species on the BOW online handbook;
Species_Scientific_Name: Scientific species name, using eBird/Clements Checklist v2022 taxonomic authority (used by SAviTraits 1.0);
Species_Common_Name:	The common name listed on the BOW online handbook;
Total_Citation_Num: The total number of citations listed in a given species entry;
Diet_Information: Logical (TRUE/FALSE) indicating whether there was any information on diet for that species;
Diet_Entry_Length: The number of words, excluding citations,  in the dietary description. Where “No information available” was listed, the entry length was assigned zero;
Diet_Citation_Num: The number of literary citations listed in the dietary description;
Percentile_Total_Citation_Num: Percentile a given species falls into given the total number of citations that accompanied that species description; quantified as rank(x/(n+1)), where x is the observation and n is the total number of species;
Percentile_Diet_Entry_Length: Percentile a given species falls into given the length of its diet description in words; quantified as rank(x/(n+1)), where x is the observation and n is the total number of species;
Percentile_Diet_Citation_Num: Percentile a given species falls into given the number of citations explicitly cited within the “Diet and Foraging” section of the species description; quantified as rank(x/(n+1)), where x is the observation and n is the total number of species;
Certainty: The level of confidence in a species’ dietary designation; calculated as the mean of Percentile_Total_Citation_Num, Percentile_Diet_Citation_Num, and Percentile_Diet_Entry_Length.

SAviTraits_1-0_2_citations.rds database file:
BOW_Code: The reference code for the species on the BOW online handbook;
Species_Scientific_Name: Scientific species name, using eBird/Clements Checklist v2022 taxonomic authority (used by SAviTraits 1.0);
Species_Common_Name:	The common name listed on the BOW online handbook;
Total_Citation_Num: The total number of citations listed in a given species entry;
Diet_Information: Logical (TRUE/FALSE) indicating whether there was any information on diet for that species;
Diet_Entry_Length: The number of words, excluding citations,  in the dietary description. Where “No information available” was listed, the entry length was assigned zero;
Diet_Citation_Num: The number of literary citations listed in the dietary description;
All_Citations: Complete list of citations that accompanied the species description;
Diet_Description: The dietary description verbatim as it appeared in BOW at the time of the creation of SAviTraits 1.0;
Diet_Citations: Complete list of citations explicitly cited within the “Diet and Foraging” section of the species description.

SAviTraits_1-0_3.csv database file:
eBird_Clements_v2022: Latin species name following the eBird/Clements Checklist v2022 taxonomic authority (used by SAviTraits 1.0);
eBird_Clements_v2021: Latin species name following the eBird/Clements Checklist v2021 taxonomic authority;
BirdLife_v3: Latin species name following the BirdLife v3 taxonomic authority (used by EltonTraits 1.0; Wilman et al. 2014);
BirdLife_v7: Latin species name following the BirdLife v7 taxonomic authority;
IOC_v13.1: Latin species name following the IOC World Bird List v13.1 .

