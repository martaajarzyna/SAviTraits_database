###### SAviTraits 1.0 --------------------------------------------------------
## this code provides basic fucntions to explore the TemporalAvoDiet 1.0 database
packages<-c('tidyverse', 'dplyr', 'plyr', 'matrixStats', 'rvest', 'httr', 'viridis',
            'raster', 'maps', 'mapdata', 'rworldmap', 'ape', 'adephylo', 'picante',
            'rgeos')

lapply(packages, require, character.only=TRUE)

## read in the main database file
database <- read_csv('database-files-v1.0/SAviTraits_1-0_1.csv')

`%notin%`<-Negate(`%in%`)


###### check for errors --------------------------------------------------------
## total number of species
speciesNames<-unique(database$Species)
length(speciesNames) ## should be 10715

## check for any NAs in the data columns
sum(is.na(database[,3:14])) ## should be zero

## check all species have 12 rows
unique(table(database$Species)) ## should return the number 12, nothing else

## check for correct column sums
colCounts_bySpecies<-aggregate(database[,4:15], list(database$Species), function(x){sum(x[-c(2,8)])})
mistakes<-colCounts_bySpecies[apply(colCounts_bySpecies[,-1], 1, function(x){any(x<9.98)}),] ## rows that contain value other than 10
nrow(mistakes)  ## should be zero, indicating all rows sum to 10 for each species

## percentage of records with seasonal variation ---------------------------
database$diet_var<-apply(database, 1, function(x){var(x[4:15])})  ## add column indicating the variance of each diet category over 12 months
all<-tapply(database$diet_var, database$Species, sum)
length(all[all>0])/length(all)  ## proportion of species that have seasonal variation


###### diet metrics ------------------------------------------------------------

# Here are examples of different options for summarizing dietary breadth.
# Note that there are main and sub diet categories, and different diet_matrics
# can be made accordingly. For example, 'Diet_VAll' and 'Diet_PlantAll' are 
# considered 'main' categories, while 'Diet_Vect' and 'Diet_Fruit' are considered 
# sub categories.

### warning ####

## make sure column numbers correspond to correct columns in the 'database.' If columns are
## added or deleted from the database then these numbers need to be changed. Below, the
## month columns are index repeatedly using col_index. Make sure columns 3:14 refer to 
## columns labelled "Jan" through "Dec".

col_index<-4:15

## these take a little while to run

## number of main diet categories utilized in any month
diet_breadth_main<-vector(length=length(speciesNames), mode="list")  

for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 10
  data_spec <- database %>% dplyr::filter(Species==speciesNames[i]) 
  data_spec_2 <- data_spec[c(1,2,7,8),col_index]
  diet_breadth_main[[i]]<-sum(ifelse(rowSums(data_spec_2)>0,1,0))
  print(i)
  }
        
diet_breadth_main<-unlist(diet_breadth_main)


## number of sub categories utilized in any month
diet_breadth_sub<-vector(length=length(speciesNames), mode="list") 

for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 10
  data_spec<-database[database$Species==speciesNames[i],]
  data_spec_2<-data_spec[c(1,3,4,5,6,7,9,10,11,12),col_index]
  diet_breadth_sub[[i]]<-sum(ifelse(rowSums(data_spec_2)>0,1,0))
  print(i)
  }
          
diet_breadth_sub<-unlist(diet_breadth_sub)


## sum of variance across main categories utilized
diet_seasonality_main<-vector(length=length(speciesNames), mode="list")  

for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 10
  data_spec<-database[database$Species==speciesNames[i],]
  data_spec_2<-data_spec[c(1,2,7,8),col_index]
  diet_seasonality_main[[i]]<-sum(rowVars(as.matrix(data_spec_2)))
  print(i)
}

diet_seasonality_main<-unlist(diet_seasonality_main)


## sum of variance across sub categories utilized
diet_seasonality_sub<-vector(length=length(speciesNames), mode="list")  

          for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 10
            data_spec<-database[database$Species==speciesNames[i],]
            data_spec_2<-data_spec[c(1,3,4,5,6,7,9,10,11,12),col_index]
            diet_seasonality_sub[[i]]<-sum(rowVars(as.matrix(data_spec_2)))
            print(i)
          }

diet_seasonality_sub<-unlist(diet_seasonality_sub)


## sum of variance across main categories utilized
diet_seasonality_main_max<-vector(length=length(speciesNames), mode="list")  
for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 10
  data_spec<-database[database$Species==speciesNames[i],]
  data_spec_2<-data_spec[c(1,2,7,8),col_index]
  diet_seasonality_main_max[[i]]<-max(rowVars(as.matrix(data_spec_2)))
  print(i)
}

diet_seasonality_main_max<-unlist(diet_seasonality_main_max)


## sum of variance across sub categories utilized
diet_seasonality_sub_max<-vector(length=length(speciesNames), mode="list")  

for(i in 1:length(speciesNames)){   ### here we are looping through each species and summing the specific rows that should add to 10
  data_spec<-database[database$Species==speciesNames[i],]
  data_spec_2<-data_spec[c(1,3,4,5,6,7,9,10,11,12),col_index]
  diet_seasonality_sub_max[[i]]<-max(rowVars(as.matrix(data_spec_2)))
  print(i)
}

diet_seasonality_sub_max<-unlist(diet_seasonality_sub_max)


diet_df<-cbind.data.frame(speciesNames, diet_breadth_main, diet_breadth_sub, diet_seasonality_main, 
                          diet_seasonality_sub, diet_seasonality_main_max, diet_seasonality_sub_max)
diet_df<-as.data.frame(diet_df)
colnames(diet_df)[1]<-"Species"

## save all diet metrics in dataframe 
write_csv(diet_df, 'diet_df.csv')


###### join citation number and diet description length  ---------------------------------------------------
BOW_species_df_final<-read.csv('database-files-v1.0/SAviTraits_1-0_2.csv')
speciesList<-join(data.frame("Species"=speciesNames), BOW_species_df_final, by="Species")

## data on citation number or diet description length can be used to weigh diet breadth or seasonality
## it can be informative to do so because species that are better studied (i.e., have more citations or longer diet descriptons)
## are also potentially  more likely to have information on seasonality of their diet
## we thus suggest exploring temporal variability in diet through the lense of the length of their diet descriptions

