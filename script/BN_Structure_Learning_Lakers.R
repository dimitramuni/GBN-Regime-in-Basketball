'Structure Learning for Los Angeles Lakers gamelogs,seasons: from 1996-97 to 2015-16


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



basic=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Lakers_basic_gamelog_9697_1516.csv')
colnames(basic)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                   'TmFG','TmFGA','TmFGper','Tm3P','Tm3PA','Tm3Pper','TmFT','TmFTA','TmFTper',
                   'TmORB','TmTRB','TmAST','TmSTL','TmBLK','TmTOV','TmPF',
                   'OppFG','OppFGA','OppFGper','Opp3P','Opp3PA','Opp3Pper','OppFT','OppFTA','OppFTper',
                   'OppORB','OppTRB','OppAST','OppSTL','OppBLK','OppTOV','OppPF')


advanced=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Lakers_advanced_gamelog_9697_1516.csv')
colnames(advanced)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                      'ORtg','DRtg','Pace','FTr','3PAr','TSper','TRBper','ASTper','STLper','BLKper',
                      'OffeFGper','OffTOVper','OffORBper','OffFT_d_FGA',
                      'DefeFGper','DefTOVper','DefDRBper','DefFT_d_FGA')
lakers_gamelog=merge(basic,advanced,by = c('Date','Sep','Opp','WL','TmScore','OppScore'))

#Experiment I


#Modeling BN using 25 variables from basic and advance gamelog stat

## Pre-processing 

dataset1=subset(lakers_gamelog,select=c('Date','Sep','Opp','WL',
                                         'TmFGper','Tm3Pper','TmFTper',
                                         'OppFGper','Opp3Pper','OppFTper',
                                         'FTr','TSper','TRBper','ASTper','STLper','BLKper',
                                         'OffeFGper','OffTOVper','OffORBper','OffFT_d_FGA',
                                         'DefeFGper','DefTOVper','DefDRBper','DefFT_d_FGA'))

#omiting the rows with missing values,https://statisticsglobe.com/r-remove-data-frame-rows-with-some-or-all-na


gamelog_stat_lakers<-dataset1 %>% drop_na()


#deciding if the game was played at home or away
gamelog_stat_lakers$HomeAway<- ifelse(gamelog_stat_lakers$Sep=='@','Away','Home')
gamelog_stat_lakers<-gamelog_stat_lakers[,-c(2)] 

#converting percentages to a number between 0 and 1
gamelog_stat_lakers[,c('TRBper','ASTper','STLper',
                        'BLKper','OffTOVper',
                        'OffORBper','DefTOVper',
                        'DefDRBper')]<-gamelog_stat_lakers[,c('TRBper',
                                                               'ASTper','STLper',
                                                               'BLKper','OffTOVper',
                                                               'OffORBper','DefTOVper',
                                                               'DefDRBper')]/100


#gamelog_stat_lakers$TRBper<-gamelog_stat_lakers$TRBper/100
#gamelog_stat_lakers$ASTper<-gamelog_stat_lakers$ASTper/100

#gamelog_stat_lakers$OffTOVper<-gamelog_stat_lakers$OffTOVper/100
#gamelog_stat_lakers$OffDRBper<-gamelog_stat_lakers$OffDRBper/100
#gamelog_stat_lakers$DefTOVper<-gamelog_stat_lakers$DefTOVper/100
#gamelog_stat_lakers$DefDRBper<-gamelog_stat_lakers$DefDRBper/100




################## Pre processing for Teams which appeared in playoffs#################3

#finding out number of matches in the dataset
n=dim(gamelog_stat_lakers)[1]
playoff_appearance=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/PlayoffAppearance.csv')
all_intervals=interval(playoff_appearance$StartDate,playoff_appearance$EndDate)
for (i in 1:n) {
  
  #finding which row (season) the game belongs to in playoff_appearace table
  playoff_row_index=which(ymd(gamelog_stat_lakers$Date[i]) %within% all_intervals)
  
  #checkign if the opposite team was part of playoff during that season
  gamelog_stat_lakers$PlayOff[i]= grepl(gamelog_stat_lakers$Opp[i], playoff_appearance$Teams[playoff_row_index])
  
}
write.csv(gamelog_stat_lakers,'~/Desktop/GBN-Regime-in-Basketball/data/PreProcessed_Lakers_Gamelog.csv',row.names = FALSE)



#11 variables model (four factor*2, Outcome,PlayOff,HomeAway)
#gamelog_discrete_lakers<-discretize(gamelog_stat_lakers[,-c(1:15,24:25)], breaks = 5)
#gamelog_discrete_lakers$Opp<-factor(gamelog_stat_lakers$Opp)

#13 variables model (STL%,BLK%,3P%(Tm/Opp),2P%(Tm/Opp),FT%(Tm/Opp),TSper,TRBper,Outcome,PlayOff,HomeAway)
gamelog_discrete_lakers<-discretize(gamelog_stat_lakers[,c('STLper','BLKper','TmFGper',
                                  'OppFGper','TmFTper','OppFTper','Tm3Pper','Opp3Pper','TSper','TRBper')],breaks=5)


gamelog_discrete_lakers$WL<-factor(gamelog_stat_lakers$WL)
gamelog_discrete_lakers$PlayOff<-factor(gamelog_stat_lakers$PlayOff)
gamelog_discrete_lakers$HomeAway<-factor(gamelog_stat_lakers$HomeAway)

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



#setwd("~/Desktop/GBN-Regime-in-Basketball/script")

#bn_overall<-hc(gamelog_discrete_lakers,score = 'bde',restart = 1000,blacklist = blacklisted_arcs1,maxp=8)
#bnlearn::score(bn_overall,gamelog_discrete_lakers)
#graphviz.plot(bn_overall)

#bn1<-hc(gamelog_discrete_lakers[1:1282,],score = 'bde',blacklist = blacklisted_arcs1,restart = 1000,maxp=8)
#bnlearn::score(bn1,gamelog_discrete_lakers)
#graphviz.plot(bn1)

#bn2<-hc(gamelog_discrete_lakers[1283:2105,],score = 'bde',restart = 1000,blacklist = blacklisted_arcs1,maxp=8)
#bnlearn::score(bn2,gamelog_discrete_lakers)
#graphviz.plot(bn2)


#bn3<-hc(gamelog_discrete_lakers[2106:2775,],score = 'bde',restart = 1000,blacklist = blacklisted_arcs1,maxp=8)
#bnlearn::score(bn3,gamelog_discrete_lakers)
#graphviz.plot(bn3)


#bn4<-hc(gamelog_discrete_lakers[2776:dim(gamelog_discrete_lakers)[1],],blacklist = blacklisted_arcs1,score = 'bde',restart = 1000,maxp=8)
#bnlearn::score(bn4,gamelog_discrete_lakers)
#graphviz.plot(bn4)





source('~/Desktop/GBN-Regime-in-Basketball/script/Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = gamelog_discrete_lakers,k=3,n_iteration = 200)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)

#teams_in_playoff=playoff_appearance$Teams[1]
#for (i in 2:length(playoff_appearance$Teams)) {
#  teams_in_playoff=paste(teams_in_playoff,playoff_appearance$Teams[i],sep = ',')

#}
#split_teams=unlist(strsplit(teams_in_playoff,','))
#table(split_teams)
#champions=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/NBA_Champions.csv')



#Learning Bayesian Network using Hill Climbing Algorithm
#bn<-hc(x=dataset,score = 'bde')


regime_list<-list(1:755,756:2451,2452:2974)

for (i in 1:length(regime_list)) {
  
  bn<-hc(x= gamelog_discrete_lakers[regime_list[[i]],],score = 'bde',blacklist = blacklisted_arcs1)
  #Bayesian Dirichilet Equivalent score
  cat('\n regime',i,'\t BDe',bnlearn::score(bn, gamelog_discrete_lakers[regime_list[[i]],], type = "bde"))
  
}


