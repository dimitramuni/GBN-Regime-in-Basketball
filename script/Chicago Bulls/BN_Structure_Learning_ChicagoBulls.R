'Structure Learning for Chicago Bulls gamelogs,seasons: from 1983-84 to 2020-21


Bayesian Network for Basketball Analytics

References: i) https://lib.dr.iastate.edu/cgi/viewcontent.cgi?article=7962&context=etd
            ii) https://www.basketball-reference.com/
'
library(bnlearn)
library(gRain)
library(Rgraphviz)
library(graph)
library(grid)
library(snow)
library(tidyverse)
library(lubridate)
#merging basic and advanced stat

setwd("~/Desktop/GBN-Regime-in-Basketball/data")

basic=read.csv('Chicago_basic_gamelog_8384_2021.csv')
colnames(basic)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
     'TmFG','TmFGA','TmFGper','Tm3P','Tm3PA','Tm3Pper','TmFT','TmFTA','TmFTper',
     'TmORB','TmTRB','TmAST','TmSTL','TmBLK','TmTOV','TmPF',
     'OppFG','OppFGA','OppFGper','Opp3P','Opp3PA','Opp3Pper','OppFT','OppFTA','OppFTper',
     'OppORB','OppTRB','OppAST','OppSTL','OppBLK','OppTOV','OppPF')


advanced=read.csv('Chicago_advanced_gamelog_8384_2021.csv')
colnames(advanced)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                      'ORtg','DRtg','Pace','FTr','3PAr','TSper','TRBper','ASTper','STLper','BLKper',
                      'OffeFGper','OffTOVper','OffORBper','OffFT_d_FGA',
                      'DefeFGper','DefTOVper','DefDRBper','DefFT_d_FGA')
chicago_gamelog=merge(basic,advanced,by = c('Date','Sep','Opp','WL','TmScore','OppScore'))

#Experiment I


#Modeling BN using 25 variables from basic and advance gamelog stat

## Pre-processing 

gamelog_stat_chicago=subset(chicago_gamelog,select=c('Date','Sep','Opp','WL',
                                         'TmFGper','Tm3Pper','TmFTper',
                                         'OppFGper','Opp3Pper','OppFTper',
                                         'FTr','TSper','TRBper','ASTper','STLper','BLKper',
                                         'OffeFGper','OffTOVper','OffORBper','OffFT_d_FGA',
                                        'DefeFGper','DefTOVper','DefDRBper','DefFT_d_FGA'))

#omiting the rows with missing values,https://statisticsglobe.com/r-remove-data-frame-rows-with-some-or-all-na

#deciding if the game was played at home, True or False
gamelog_stat_chicago$HomeGame<- ifelse(gamelog_stat_chicago$Sep=='@',FALSE,TRUE)

#If the team won in the game, True or False
gamelog_stat_chicago$WL<-ifelse(gamelog_stat_chicago$WL=='W',TRUE,FALSE)

#Filling NA values with 0s for Tm3Pper and Opp3Pper
gamelog_stat_chicago$Tm3Pper[is.na(gamelog_stat_chicago$Tm3Pper)]<-0
gamelog_stat_chicago$Opp3Pper[is.na(gamelog_stat_chicago$Opp3Pper)]<-0

## dropping the Sep column
gamelog_stat_chicago <-gamelog_stat_chicago[,-c(2)] 

#Dropping all the rows with NA
gamelog_stat_chicago<-gamelog_stat_chicago %>% drop_na()





#converting percentages to a number between 0 and 1
gamelog_stat_chicago[,c('TRBper','ASTper','STLper',
                        'BLKper','OffTOVper',
                        'OffORBper','DefTOVper',
                        'DefDRBper')]<-gamelog_stat_chicago[,c('TRBper',
                                                               'ASTper','STLper',
                                                               'BLKper','OffTOVper',
                                                               'OffORBper','DefTOVper',
                                                               'DefDRBper')]/100


#gamelog_stat_chicago$TRBper<-gamelog_stat_chicago$TRBper/100
#gamelog_stat_chicago$ASTper<-gamelog_stat_chicago$ASTper/100

#gamelog_stat_chicago$OffTOVper<-gamelog_stat_chicago$OffTOVper/100
#gamelog_stat_chicago$OffDRBper<-gamelog_stat_chicago$OffDRBper/100
#gamelog_stat_chicago$DefTOVper<-gamelog_stat_chicago$DefTOVper/100
#gamelog_stat_chicago$DefDRBper<-gamelog_stat_chicago$DefDRBper/100




################## Pre processing for Teams which appeared in playoffs#################3

#finding out number of matches in the dataset
n=dim(gamelog_stat_chicago)[1]
playoff_appearance=read.csv('PlayoffAppearance.csv')
all_intervals=interval(playoff_appearance$StartDate,playoff_appearance$EndDate)
for (i in 1:n) {
  
  #finding which row (season) the game belongs to in playoff_appearace table
  playoff_row_index=which(ymd(gamelog_stat_chicago$Date[i]) %within% all_intervals)
  
  #checkign if the opposite team was part of playoff during that season
  gamelog_stat_chicago$PlayOff[i]= grepl(gamelog_stat_chicago$Opp[i], playoff_appearance$Teams[playoff_row_index])
  
}
write.csv(gamelog_stat_chicago,'PreProcessed_Chicago_Gamelog.csv',row.names = FALSE)


