'Structure Learning for Portland Trail Blazers gamelogs, seasons: from 11980-81 to 2020-21


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


basic=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Portland_basic_gamelog_8081_2021.csv')
colnames(basic)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                   'TmFG','TmFGA','TmFGper','Tm3P','Tm3PA','Tm3Pper','TmFT','TmFTA','TmFTper',
                   'TmORB','TmTRB','TmAST','TmSTL','TmBLK','TmTOV','TmPF',
                   'OppFG','OppFGA','OppFGper','Opp3P','Opp3PA','Opp3Pper','OppFT','OppFTA','OppFTper',
                   'OppORB','OppTRB','OppAST','OppSTL','OppBLK','OppTOV','OppPF')


advanced=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Portland_advanced_gamelog_8081_2021.csv')
colnames(advanced)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                      'ORtg','DRtg','Pace','FTr','3PAr','TSper','TRBper','ASTper','STLper','BLKper',
                      'OffeFGper','OffTOVper','OffORBper','OffFT_d_FGA',
                      'DefeFGper','DefTOVper','DefDRBper','DefFT_d_FGA')
portland_gamelog=merge(basic,advanced,by = c('Date','Sep','Opp','WL','TmScore','OppScore'))



#Experiment I


#Modeling BN using 25 variables from basic and advance gamelog stat

## Pre-processing 

dataset_portland=subset(portland_gamelog,select=c('Date','Sep','Opp','WL',
                                         'TmFGper','Tm3Pper','TmFTper',
                                         'OppFGper','Opp3Pper','OppFTper',
                                         'FTr','TSper','TRBper','ASTper','STLper','BLKper',
                                         'OffeFGper','OffTOVper','OffORBper','OffFT_d_FGA',
                                         'DefeFGper','DefTOVper','DefDRBper','DefFT_d_FGA'))

#omiting the rows with missing values,https://statisticsglobe.com/r-remove-data-frame-rows-with-some-or-all-na

gamelog_stat_portland<-dataset_portland %>% drop_na()


#deciding if the game was played at home or away
gamelog_stat_portland$HomeAway<- ifelse(gamelog_stat_portland$Sep=='@','Away','Home')
gamelog_stat_portland <-gamelog_stat_portland[,-c(2)] 

#converting percentages to a number between 0 and 1
gamelog_stat_portland[,c('TRBper','ASTper','STLper',
                        'BLKper','OffTOVper',
                        'OffORBper','DefTOVper',
                        'DefDRBper')]<-gamelog_stat_portland[,c('TRBper',
                                                               'ASTper','STLper',
                                                               'BLKper','OffTOVper',
                                                               'OffORBper','DefTOVper',
                                                               'DefDRBper')]/100


#gamelog_stat_portland$TRBper<-gamelog_stat_portland$TRBper/100
#gamelog_stat_portland$ASTper<-gamelog_stat_portland$ASTper/100

#gamelog_stat_portland$OffTOVper<-gamelog_stat_portland$OffTOVper/100
#gamelog_stat_portland$OffDRBper<-gamelog_stat_portland$OffDRBper/100
#gamelog_stat_portland$DefTOVper<-gamelog_stat_portland$DefTOVper/100
#gamelog_stat_portland$DefDRBper<-gamelog_stat_portland$DefDRBper/100




################## Pre processing for Teams which appeared in playoffs#################3

#finding out number of matches in the dataset
n=dim(gamelog_stat_portland)[1]
playoff_appearance=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/PlayoffAppearance.csv')
all_intervals=interval(playoff_appearance$StartDate,playoff_appearance$EndDate)
for (i in 1:n) {
  
  #finding which row (season) the game belongs to in playoff_appearace table
  playoff_row_index=which(ymd(gamelog_stat_portland$Date[i]) %within% all_intervals)
  
  #checkign if the opposite team was part of playoff during that season
  gamelog_stat_portland$PlayOff[i]= grepl(gamelog_stat_portland$Opp[i], playoff_appearance$Teams[playoff_row_index])
  
}
write.csv(gamelog_stat_portland,'~/Desktop/GBN-Regime-in-Basketball/data/PreProcessed_Portland_Gamelog.csv',row.names = FALSE)



#11 variables (four factor*2, Outcome,PlayOff,HomeAway)
gamelog_discrete_portland<-discretize(gamelog_stat_portland[,-c(1:15,24:25)], breaks = 5)
#gamelog_discrete_portland$Opp<-factor(gamelog_stat_portland$Opp)
gamelog_discrete_portland$WL<-factor(gamelog_stat_portland$WL)
gamelog_discrete_portland$PlayOff<-factor(gamelog_stat_portland$PlayOff)
gamelog_discrete_portland$HomeAway<-factor(gamelog_stat_portland$HomeAway)

#blacklisting certain arcs

#blacklisting arcs for 11 variables model
blacklisted_arcs1<-data.frame(from = c("WL", "WL","WL", "WL","WL", "WL","WL", "WL","WL", "WL",
                                       "OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","PlayOff",
                                       "OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","HomeAway"), 
                              to = c("OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","PlayOff", "HomeAway",
                                     "HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway",
                                     "PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff"))

#blacklisting arcs for 23 variables model
blacklisted_arcs2<-data.frame(from = c("WL", "WL","WL", "WL","WL", "WL","WL", "WL","WL", "WL", "WL", "WL","WL", "WL","WL", "WL","WL", "WL","WL", "WL","WL", "WL",
                                       'TmFGper','Tm3Pper','TmFTper','OppFGper','Opp3Pper','OppFTper','FTr','TSper','TRBper','ASTper','STLper','BLKper',"OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","PlayOff",
                                       'TmFGper','Tm3Pper','TmFTper','OppFGper','Opp3Pper','OppFTper','FTr','TSper','TRBper','ASTper','STLper','BLKper',"OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","HomeAway"), 
                              to = c('TmFGper','Tm3Pper','TmFTper','OppFGper','Opp3Pper','OppFTper','FTr','TSper','TRBper','ASTper','STLper','BLKper',"OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","PlayOff", "HomeAway",
                                     "HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway",
                                     "PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff"))



setwd("~/Desktop/GBN-Regime-in-Basketball/script")
bn1<-hc(gamelog_discrete_portland[1:1228,],score = 'bde',blacklist = blacklisted_arcs2)
bnlearn::score(bn1,gamelog_discrete_portland)
graphviz.plot(bn1)

bn2<-hc(gamelog_discrete_portland[1229:2549,],score='bde',blacklist = blacklisted_arcs2)
bnlearn::score(bn2,gamelog_discrete_portland)
graphviz.plot(bn2)

bn3<-hc(gamelog_discrete_portland[2550:dim(gamelog_discrete_portland)[1],],score='bde',blacklist = blacklisted_arcs2)
bnlearn::score(bn3,gamelog_discrete_portland)
graphviz.plot(bn3)

#bn3<-rsmax2(gamelog_discrete_portland)
#bnlearn::score(bn3,gamelog_discrete_portland)
#graphviz.plot(bn3)

#bn4<-mmhc(gamelog_discrete_portland)
#bnlearn::score(bn4,gamelog_discrete_portland)
#graphviz.plot(bn4)

#bn5<-h2pc(gamelog_discrete_portland)
#bnlearn::score(bn5,gamelog_discrete_portland)
#graphviz.plot(bn5)



source('Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = gamelog_discrete_portland,k=3,n_iteration = 100000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)


