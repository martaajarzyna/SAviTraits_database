#This script scrapes the BotW website for all species diet descriptions and citations

#Original code was written by Stephen Joesph Murphy, but has been re-written by André M. Bellvé.

# Libraries ---------------------------------------------------------------

#Data manipulation
library(dplyr)
library(readr)
library(stringr)

#Web scraping
library(rvest)
library(httr)
library(XML)
library(xml2)

#Time keeping
library(tictoc)
library(beepr)

#Login to BotW ------------------------------------------------------------
login <- "https://secure.birds.cornell.edu/cassso/login?service=https%3A%2F%2Fbirdsoftheworld.org%2Flogin%2Fcas"

#Intialising session information
pgsession <- session(login)

#Extracting html login form
pgform <- html_form(pgsession)[[1]]

#Filling out html form
filled_form <- html_form_set(pgform, 
                             username = , 
                             password = ) ## enter your login details

#Submitting html form for login
session_submit(pgsession, 
               filled_form)

#Intialising session for the species list
pathURL <- session_jump_to(pgsession, 
                           "https://birdsoftheworld.org/bow/specieslist")

#Reading species list page
webpage <- read_html(pathURL)


# Scraping BotW data  ---------------------------------------------------------
## Species taxonomy scrape ---------------------------------------
#Pulling taxonomy node information from each species page 
taxonomyNodes <- webpage %>% 
  html_elements("#content > div:nth-child(1) > div:nth-child(1) > ul:nth-child(2)") %>% 
  html_elements("li") %>%
  html_elements("ul") %>%
  html_elements("li") %>%
  html_elements("ul") %>% 
  html_elements("li")

#Extracting the species code strings as a character vector
BOW_codes <- taxonomyNodes %>%
  html_elements('a') %>%
  html_attr("href") %>% 
  str_remove("/bow/species/") %>% 
  str_remove("/cur/introduction")

#Extracting their common names
BOW_commonNames <- taxonomyNodes %>% 
  html_elements(".Heading-main") %>% 
  html_text()

#Extracting their scientific names
BOW_sciNames <- taxonomyNodes %>% 
  html_elements(".Heading-sub") %>% 
  html_text()

#Binding all columns into a dataframe
BOW_species_df <- bind_cols("BOW_Code" = BOW_codes, 
                            "Scientific" = BOW_sciNames, 
                            "Common_Name" = BOW_commonNames)

#Data check
#None of these html elements return a non-NA value.
any(!complete.cases(BOW_species_df))


## Citation Data ------------------------------------------------

#Empty list for counting the number of citations for each entry and a list to record them
citation_num <- vector(length = nrow(BOW_species_df))
all_citations <- vector(length = nrow(BOW_species_df))

#For loop to extract the citation count - This takes quite a while to run!

tic("citation count loop")

for(i in seq_along(citation_num)){
  
  citation_num[i]  <- session_jump_to(pgsession,
                                      paste0("https://birdsoftheworld.org/bow/species/",
                                             BOW_species_df[i, ]$BOW_Code,
                                             "/cur/references")) %>%
    read_html()  %>%
    html_elements(".u-md-size5of6") %>%
    html_elements("ul") %>%
    html_elements("li")%>%
    length()
  
  if(citation_num[i] != 0){
    
    #Counting the number of citations (INCL. ADDITIONAL REFERENCES!!!)
    all_citations[i] <- session_jump_to(pgsession,
                                        paste0("https://birdsoftheworld.org/bow/species/",
                                               BOW_species_df[i, ]$BOW_Code,
                                               "/cur/references")) %>%
      read_html()  %>%
      html_elements(".u-md-size5of6") %>%
      html_elements("ul") %>%
      html_elements("li") %>%
      html_text2() %>% 
      str_flatten(" \n \n")
  }else{
    all_citations[i] <- NA
  }
  
  #Keeping count
  print(paste0(i, "/", nrow(BOW_species_df)))
}

toc()
beep()

#This took 7687 seconds to run

#Adding this to the df... better to add directly to the df...
BOW_species_df <- bind_cols(BOW_species_df,
                            "total_num_citations" = citation_num,
                            "all_citations" = all_citations)

#Saving this output to avoid re-running
write.csv(BOW_species_df, "./output/bow_species_data.csv")

## Diet Data ------------------------------------------------------

#Creating extra diet description columns
BOW_species_df$diet_information <- NA
BOW_species_df$diet_description <- NA
BOW_species_df$diet_entry_length <- NA
BOW_species_df$diet_citation_num <- NA
BOW_species_df$diet_citations <- NA
BOW_species_df$all_citations <- NA


#For loop to extract all diet information
tic("Diet Extraction")
for(i in seq_along(BOW_codes)){
  
  #Pulling open web pages for each species foodhabits (note page gets re-routed to the intro page for the species... maybe a reason original author specified foodhabits?)
  webpage_ref <- session_jump_to(pgsession,
                                 paste0("https://birdsoftheworld.org/bow/species/",
                                        BOW_species_df[i,]$BOW_Code,
                                        "/cur/foodhabits")) %>% 
    read_html()
  
  #Pulling all the sections from the page
  sections <- xml_find_all(webpage_ref, 
                           ".//section")
  
  #This code assumes that the species page will have either a section called "diet" or "food"...
  #Extracting the "diet" section
  food_section <- sections[xml_attr(sections, "aria-labelledby") == "diet"]
  
  #If there is no section called diet then checks for food
  if(length(food_section) == 0){
    food_section <- sections[xml_attr(sections, "aria-labelledby") == "food"]
  }
  
  #If there is no section called food either, then it puts in an empty entry
  if(length(food_section) == 0){
    
    BOW_species_df[i,]$diet_information <- FALSE
    BOW_species_df[i,]$diet_entry_length <- 0
    
    #Other wise it will count the length fo the entry
  } else {
    
    #Recording the diet description
    BOW_species_df[i,]$diet_description <- food_section %>% 
      html_text2() %>% 
      str_remove_all(". Close ")
    
    #Checking to see if the section has no information in it...
    BOW_species_df[i,]$diet_information <- str_detect(BOW_species_df[i,]$diet_description, 
                                                      "No information available",
                                                      negate = TRUE)
    
    #Filling in the information with 0's and NAs
    if(BOW_species_df[i,]$diet_information == FALSE){
      
      #Replacing the "No info..." with NA for consistency
      BOW_species_df[i,]$diet_description <- NA
      BOW_species_df[i,]$diet_entry_length <- 0
      BOW_species_df[i,]$diet_citation_num <- NA
      BOW_species_df[i,]$diet_citations <- NA
      
    } else {
      
      citations_text <- food_section %>% 
        html_elements("span") %>% 
        html_text2()
      
      if(length(citations_text) > 0){
        
        #Removing the non-literature citations
        citations_text <- citations_text[str_detect(citations_text, ". Close")]
        
        #Removing the double-ups
        citations_text <- citations_text[c(FALSE, TRUE)] %>% 
          str_remove(". Close")
        
        #Counting the citations for the diet description
        BOW_species_df[i,]$diet_citation_num <- length(citations_text)
        
        #Adding diet citations to the dataframe - including spacing for easy reading
        BOW_species_df[i,]$diet_citations <- str_flatten(citations_text, " \n \n")
        
        #Counting the number of words in each diet description
        full_count <- str_count(BOW_species_df[i,]$diet_description, "\\S+")
        
        #Counting the number of words in the citation text
        cite_count <- str_count(citations_text, "\\S+") %>% 
          sum() - 6 #Subtracting six to remove the \n's I put in
        
        #Calculating the correct number of citations
        BOW_species_df[i,]$diet_entry_length <- (full_count - cite_count)
        
        #An else statement to account for cases where there is an entry but there are no citations
      } else {
        
        #Counting the number of words in each diet description
        full_count <- str_count(BOW_species_df[i,]$diet_description, "\\S+")
        
        #Calculating the number of words....
        BOW_species_df[i,]$diet_entry_length <- full_count
        
        #In these cases where there is an entry with some data, but NO citations, the value is set to zero instead of NA
        BOW_species_df[i,]$diet_citation_num <- 0
      }
    }
    #Keeping count
    print(paste0(i, "/", nrow(BOW_species_df)))  
  }
}

toc()
#Diet Extraction: 12014.3 sec elapsed
beep()

#Tidying
BOW_species_df <- BOW_species_df %>%
  #Reordering columns
  select(BOW_Code, Scientific, Common_Name,
         total_num_citations, all_citations,
         diet_information, diet_description, diet_entry_length,
         diet_citation_num, diet_citations) %>% 
  #Naming for consistency in style
  rename("Total_Citation_Num" = "total_num_citations",
         "All_Citations" = "all_citations",
         "Diet_Information" = "diet_information",
         "Diet_Description" = "diet_description",
         "Diet_Entry_Length" = "diet_entry_length",
         "Diet_Citation_Num" = 'diet_citation_num',
         "Diet_Citations" = "diet_citations")

#Note: the BOW_species_df has a larger number of species than the current version of the SAViTraits database due to changes in taxonomy and the description of new species than there was at the time the diet database was created. While the taxonomy of the species in the SAViTraits_1-0_1 file reflects the taxonomy update of 2022, it does not include species which were added or split after 2020. As such, the dataframe produced by the above code has 10,906 entries, while our monthly diet database contains only 10,672. The accompanying diet text analysis file used for our reach was filtered to reflect only those species who we had a diet entry for.
