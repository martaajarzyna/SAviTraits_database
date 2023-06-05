###### SAviTraits 1.0 --------------------------------------------------------
## this code provides basic functions to explore the TemporalAvoDiet 1.0 database
packages<-c('tidyverse', 'dplyr', 'plyr', 'matrixStats', 'rvest', 'httr', 'viridis',
            'raster', 'maps', 'mapdata', 'rworldmap', 'ape', 'adephylo', 'picante',
            'rgeos')

lapply(packages, require, character.only=TRUE)

## read in the main database file
database <- read_csv('database-files-v1.0/SAviTraits_1-0_1.csv')

`%notin%`<-Negate(`%in%`)


###### check for errors --------------------------------------------------------
## total number of species
speciesNames<-unique(database$Species_Scientific_Name)
length(speciesNames) ## should be 10672

## check for any NAs in the data columns
sum(is.na(database[,4:15])) ## should be zero

## check all species have 12 rows
unique(table(database$Species_Scientific_Name)) ## should return the number 10, nothing else

## check for correct column sums
colCounts_bySpecies<-aggregate(database[,4:15], list(database$Species_Scientific_Name), function(x){sum(x)})
mistakes<-colCounts_bySpecies[apply(colCounts_bySpecies[,-1], 1, function(x){any(x<100)}),] ## rows that contain value other than 100
nrow(mistakes) #should be 0

## percentage of records with seasonal variation ---------------------------
database$diet_var<-apply(database, 1, function(x){var(x[4:15])})  ## add column indicating the variance of each diet category over 12 months
all<-tapply(database$diet_var, database$Species_Scientific_Name, sum)
length(all[all>0])/length(all)  ## proportion of species that have seasonal variation


###### diet metrics ------------------------------------------------------------

# Here are examples of different options for summarizing dietary breadth.

### warning ####

## make sure column numbers correspond to correct columns in the 'database.' If columns are
## added or deleted from the database then these numbers need to be changed. Below, the
## month columns are index repeatedly using col_index. Make sure columns 4:15 refer to 
## columns labelled "Jan" through "Dec".

col_index<-4:15

## number of diet categories utilized in any month
diet_breadth <-vector(length=length(speciesNames), mode="list") 

for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 100
  data_spec<-database[database$Species_Scientific_Name==speciesNames[i],]
  data_spec_2<-data_spec[c(1:10),col_index]
  diet_breadth[[i]]<-sum(ifelse(rowSums(data_spec_2)>0,1,0))
  print(i)
  }
          
diet_breadth<-unlist(diet_breadth)


## sum of variance across diet categories utilized
diet_seasonality<-vector(length=length(speciesNames), mode="list")  

          for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 100
            data_spec<-database[database$Species_Scientific_Name==speciesNames[i],]
            data_spec_2<-data_spec[c(1:10),col_index]
            diet_seasonality[[i]]<-sum(rowVars(as.matrix(data_spec_2)))
            print(i)
          }

diet_seasonality<-unlist(diet_seasonality)


## maximum variance across sub categories utilized
diet_seasonality_max<-vector(length=length(speciesNames), mode="list")  

for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 100
  data_spec<-database[database$Species_Scientific_Name==speciesNames[i],]
  data_spec_2<-data_spec[c(1:10),col_index]
  diet_seasonality_max[[i]]<-max(rowVars(as.matrix(data_spec_2)))
  print(i)
}

diet_seasonality_max<-unlist(diet_seasonality_max)


diet_df<-cbind.data.frame(speciesNames, diet_breadth, diet_seasonality, diet_seasonality_max)
diet_df<-as.data.frame(diet_df)
colnames(diet_df)[1]<-"Species_Scientific_Name"

## save all diet metrics in dataframe 
write_csv(diet_df, 'diet_df.csv')


###### join metrics of effort and certainty  ---------------------------------------------------
database_cert<-read.csv('database-files-v1.0/SAviTraits_1-0_2.csv')
speciesList<-join(data.frame("Species_Scientific_Name"=speciesNames), database_cert, by="Species_Scientific_Name")

## data on citation number (total and diet), diet description length (and their percentiles) and estimate level of confidence (certainty) 
## can be used to weigh diet breadth or seasonality
## it can be informative to do so because species that are better studied (i.e., have more citations or longer diet descriptions)
## are also potentially more likely to have information on seasonality of their diet
## we thus suggest exploring temporal variability in diet through the lens of these proxies for effort

