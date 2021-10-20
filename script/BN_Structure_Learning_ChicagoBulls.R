'Structure Learning for Chicago Bulls gamelogs, seasons: 1999-00,2000-01,2001-02


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

basic=read.csv('data/Chicago_basic_gamelog_8081_2021.csv')
colnames(basic)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
     'TmFG','TmFGA','TmFGper','Tm3P','Tm3PA','Tm3Pper','TmFT','TmFTA','TmFTper',
     'TmORB','TmTRB','TmAST','TmSTL','TmBLK','TmTOV','TmPF',
     'OppFG','OppFGA','OppFGper','Opp3P','Opp3PA','Opp3Pper','OppFT','OppFTA','OppFTper',
     'OppORB','OppTRB','OppAST','OppSTL','OppBLK','OppTOV','OppPF')


advanced=read.csv('data/Chicago_advanced_gamelog_8081_2021.csv')
colnames(advanced)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                      'ORtg','DRtg','Pace','FTr','3PAr','TSper','TRBper','ASTper','STLper','BLKper',
                      'OffeFGper','OffTOVper','OffDRBper','OffFT/FGA',
                      'DefeFGper','DefTOVper','DefDRBper','DefFT/FGA')
chicago_gamelog=merge(basic,advanced,by = c('Date','Sep','Opp','WL','TmScore','OppScore'))

#Experiment I

'Modeling BN using four factors (offensive and defensive),Game Outcome, Opponent'

## Pre-processing 

dataset1=subset(chicago_gamelog,select=c('Date','Opp','WL','OffeFGper','OffTOVper','OffDRBper','OffFT/FGA',
                                        'DefeFGper','DefTOVper','DefDRBper','DefFT/FGA'))

#omiting the rows with missing values,https://statisticsglobe.com/r-remove-data-frame-rows-with-some-or-all-na

gamelog_stat<-dataset1 %>% drop_na()
#converting percentages to a number between 0 and 1
gamelog_stat$OffTOVper<-gamelog_stat$OffTOVper/100
gamelog_stat$OffDRBper<-gamelog_stat$OffDRBper/100
gamelog_stat$DefTOVper<-gamelog_stat$DefTOVper/100
gamelog_stat$DefDRBper<-gamelog_stat$DefDRBper/100

gamelog_discrete<-discretize(gamelog_stat[,-c(1,2,3)], breaks = 10)
gamelog_discrete$Opp<-factor(gamelog_stat$Opp)
gamelog_discrete$WL<-factor(gamelog_stat$WL)
bn1<-hc(gamelog_discrete,score = 'bde')
bnlearn::score(bn1,gamelog_discrete)


graphviz.plot(bn1)

bn2<-gs(gamelog_discrete)
graphviz.plot(bn2)

Identify_Positions2(data = gamelog_discrete,k=3,n_iteration = 1000)
