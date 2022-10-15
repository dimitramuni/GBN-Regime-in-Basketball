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
setwd("~/Desktop/GBN-Regime-in-Basketball/script")

'Modeling BN using four factors (offensive and defensive),Game Outcome, Opponent'

## Pre-processing 
##the last regime identified by "2016-12-16"

#omiting the rows with missing values,https://statisticsglobe.com/r-remove-data-frame-rows-with-some-or-all-na

chicago_stat<-chicago_gamelog %>% drop_na()
nObs<-nrow(chicago_stat)
#converting percentages to a number between 0 and 1
last_regime_start_id<-which(chicago_stat$Date=="2016-12-16")
#dim(chicago_gamelog[which(chicago_gamelog$Date=="2016-12-16"):nrow(chicago_gamelog),])

#training
nTest_index<-which(chicago_stat$Date=="2020-12-23") 
chicago_train<-chicago_stat[last_regime_start_id:(nTest_index-1),]
chicago_test<-chicago_stat[nTest_index:nObs,]




