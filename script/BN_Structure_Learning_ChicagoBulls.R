'Structure Learning for Chicago Bulls gamelogs,seasons: from 11980-81 to 2020-21


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

basic=read.csv('Chicago_basic_gamelog_8081_2021.csv')
colnames(basic)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
     'TmFG','TmFGA','TmFGper','Tm3P','Tm3PA','Tm3Pper','TmFT','TmFTA','TmFTper',
     'TmORB','TmTRB','TmAST','TmSTL','TmBLK','TmTOV','TmPF',
     'OppFG','OppFGA','OppFGper','Opp3P','Opp3PA','Opp3Pper','OppFT','OppFTA','OppFTper',
     'OppORB','OppTRB','OppAST','OppSTL','OppBLK','OppTOV','OppPF')


advanced=read.csv('Chicago_advanced_gamelog_8081_2021.csv')
colnames(advanced)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                      'ORtg','DRtg','Pace','FTr','3PAr','TSper','TRBper','ASTper','STLper','BLKper',
                      'OffeFGper','OffTOVper','OffDRBper','OffFT/FGA',
                      'DefeFGper','DefTOVper','DefDRBper','DefFT/FGA')
chicago_gamelog=merge(basic,advanced,by = c('Date','Sep','Opp','WL','TmScore','OppScore'))

#Experiment I


'Modeling BN using four factors (offensive and defensive),Game Outcome, Opponent'

## Pre-processing 

dataset1=subset(chicago_gamelog,select=c('Date','Opp','WL',
                                         'TmFGper','Tm3Pper','TmFTper',
                                         'OppFGper','Opp3Pper','OppFTper',
                                         'FTr','TSper','TRBper','ASTper','STLper','BLKper',
                                         'OffeFGper','OffTOVper','OffDRBper','OffFT/FGA',
                                        'DefeFGper','DefTOVper','DefDRBper','DefFT/FGA'))

#omiting the rows with missing values,https://statisticsglobe.com/r-remove-data-frame-rows-with-some-or-all-na

gamelog_stat_chicago<-dataset1 %>% drop_na()
#converting percentages to a number between 0 and 1


gamelog_stat_chicago[,c('TRBper','ASTper','STLper',
                        'BLKper','OffTOVper',
                        'OffDRBper','DefTOVper',
                        'DefDRBper')]<-gamelog_stat_chicago[,c('TRBper',
                                                               'ASTper','STLper',
                                                               'BLKper','OffTOVper',
                                                               'OffDRBper','DefTOVper',
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





gamelog_discrete_chicago<-discretize(gamelog_stat_chicago[,-c(1,2,3,24)], breaks = 10)
#gamelog_discrete_chicago$Opp<-factor(gamelog_stat_chicago$Opp)
gamelog_discrete_chicago$WL<-factor(gamelog_stat_chicago$WL)
gamelog_discrete_chicago$OppPlayoff<-factor(gamelog_stat_chicago$PlayOff)




setwd("~/Desktop/GBN-Regime-in-Basketball/script")
bn1<-hc(gamelog_discrete_chicago,score = 'bde')
bnlearn::score(bn1,gamelog_discrete_chicago)
graphviz.plot(bn1)

bn2<-tabu(gamelog_discrete_chicago,score='bde')
bnlearn::score(bn2,gamelog_discrete_chicago)
graphviz.plot(bn2)


#bn3<-rsmax2(gamelog_discrete_chicago)
#bnlearn::score(bn3,gamelog_discrete_chicago)
#graphviz.plot(bn3)

#bn4<-mmhc(gamelog_discrete_chicago)
#bnlearn::score(bn4,gamelog_discrete_chicago)
#graphviz.plot(bn4)

#bn5<-h2pc(gamelog_discrete_chicago)
#bnlearn::score(bn5,gamelog_discrete_chicago)
#graphviz.plot(bn5)

source('Identify2.R')
start_time<-Sys.time()
Identify_Positions2(data = gamelog_discrete_chicago,k=3,n_iteration = 10000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)


