'Structure Learning for Detroit Piston gamelogs,seasons: from 1980-81 to 2020-21


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



basic=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Detroit_basic_gamelog_8081_2021.csv')
colnames(basic)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                   'TmFG','TmFGA','TmFGper','Tm3P','Tm3PA','Tm3Pper','TmFT','TmFTA','TmFTper',
                   'TmORB','TmTRB','TmAST','TmSTL','TmBLK','TmTOV','TmPF',
                   'OppFG','OppFGA','OppFGper','Opp3P','Opp3PA','Opp3Pper','OppFT','OppFTA','OppFTper',
                   'OppORB','OppTRB','OppAST','OppSTL','OppBLK','OppTOV','OppPF')


advanced=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Detroit_advanced_gamelog_8081_2021.csv')
colnames(advanced)<-c('Date','Sep','Opp','WL','TmScore','OppScore',
                      'ORtg','DRtg','Pace','FTr','3PAr','TSper','TRBper','ASTper','STLper','BLKper',
                      'OffeFGper','OffTOVper','OffORBper','OffFT_d_FGA',
                      'DefeFGper','DefTOVper','DefDRBper','DefFT_d_FGA')
detroit_gamelog=merge(basic,advanced,by = c('Date','Sep','Opp','WL','TmScore','OppScore'))

#Experiment I


#Modeling BN using 25 variables from basic and advance gamelog stat

## Pre-processing 

dataset1=subset(detroit_gamelog,select=c('Date','Sep','Opp','WL',
                                         'TmFGper','Tm3Pper','TmFTper',
                                         'OppFGper','Opp3Pper','OppFTper',
                                         'FTr','TSper','TRBper','ASTper','STLper','BLKper',
                                         'OffeFGper','OffTOVper','OffORBper','OffFT_d_FGA',
                                         'DefeFGper','DefTOVper','DefDRBper','DefFT_d_FGA'))

#omiting the rows with missing values,https://statisticsglobe.com/r-remove-data-frame-rows-with-some-or-all-na

#subsetting from season 1982-83
dataset2<-dataset1[which(dataset1$Date=='1982-10-29'):dim(dataset1)[1],]

gamelog_stat_detroit<-dataset2 %>% drop_na()


#deciding if the game was played at home or away
gamelog_stat_detroit$HomeAway<- ifelse(gamelog_stat_detroit$Sep=='@','Away','Home')
gamelog_stat_detroit <-gamelog_stat_detroit[,-c(2)] 

#converting percentages to a number between 0 and 1
gamelog_stat_detroit[,c('TRBper','ASTper','STLper',
                        'BLKper','OffTOVper',
                        'OffORBper','DefTOVper',
                        'DefDRBper')]<-gamelog_stat_detroit[,c('TRBper',
                                                               'ASTper','STLper',
                                                               'BLKper','OffTOVper',
                                                               'OffORBper','DefTOVper',
                                                               'DefDRBper')]/100


#gamelog_stat_detroit$TRBper<-gamelog_stat_detroit$TRBper/100
#gamelog_stat_detroit$ASTper<-gamelog_stat_detroit$ASTper/100

#gamelog_stat_detroit$OffTOVper<-gamelog_stat_detroit$OffTOVper/100
#gamelog_stat_detroit$OffDRBper<-gamelog_stat_detroit$OffDRBper/100
#gamelog_stat_detroit$DefTOVper<-gamelog_stat_detroit$DefTOVper/100
#gamelog_stat_detroit$DefDRBper<-gamelog_stat_detroit$DefDRBper/100




################## Pre processing for Teams which appeared in playoffs#################3

#finding out number of matches in the dataset
n=dim(gamelog_stat_detroit)[1]
playoff_appearance=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/PlayoffAppearance.csv')
all_intervals=interval(playoff_appearance$StartDate,playoff_appearance$EndDate)
for (i in 1:n) {
  
  #finding which row (season) the game belongs to in playoff_appearace table
  playoff_row_index=which(ymd(gamelog_stat_detroit$Date[i]) %within% all_intervals)
  
  #checkign if the opposite team was part of playoff during that season
  gamelog_stat_detroit$PlayOff[i]= grepl(gamelog_stat_detroit$Opp[i], playoff_appearance$Teams[playoff_row_index])
  
}
write.csv(gamelog_stat_detroit,'PreProcessed_Detroit_Gamelog.csv',row.names = FALSE)



#11 variables (four factor*2, Outcome,PlayOff,HomeAway)
gamelog_discrete_detroit<-discretize(gamelog_stat_detroit[,-c(1:15,24:25)], breaks = 5)
#gamelog_discrete_detroit$Opp<-factor(gamelog_stat_detroit$Opp)
gamelog_discrete_detroit$WL<-factor(gamelog_stat_detroit$WL)
gamelog_discrete_detroit$PlayOff<-factor(gamelog_stat_detroit$PlayOff)
gamelog_discrete_detroit$HomeAway<-factor(gamelog_stat_detroit$HomeAway)

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

#bn_overall<-hc(gamelog_discrete_detroit,score = 'bde',restart = 1000,blacklist = blacklisted_arcs1,maxp=8)
#bnlearn::score(bn_overall,gamelog_discrete_detroit)
#graphviz.plot(bn_overall)

#bn1<-hc(gamelog_discrete_detroit[1:1282,],score = 'bde',blacklist = blacklisted_arcs1,restart = 1000,maxp=8)
#bnlearn::score(bn1,gamelog_discrete_detroit)
#graphviz.plot(bn1)

#bn2<-hc(gamelog_discrete_detroit[1283:2105,],score = 'bde',restart = 1000,blacklist = blacklisted_arcs1,maxp=8)
#bnlearn::score(bn2,gamelog_discrete_detroit)
#graphviz.plot(bn2)


#bn3<-hc(gamelog_discrete_detroit[2106:2775,],score = 'bde',restart = 1000,blacklist = blacklisted_arcs1,maxp=8)
#bnlearn::score(bn3,gamelog_discrete_detroit)
#graphviz.plot(bn3)


#bn4<-hc(gamelog_discrete_detroit[2776:dim(gamelog_discrete_detroit)[1],],blacklist = blacklisted_arcs1,score = 'bde',restart = 1000,maxp=8)
#bnlearn::score(bn4,gamelog_discrete_detroit)
#graphviz.plot(bn4)





source('~/Desktop/GBN-Regime-in-Basketball/script/Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = gamelog_discrete_detroit,k=5,n_iteration = 2000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)

teams_in_playoff=playoff_appearance$Teams[1]
for (i in 2:length(playoff_appearance$Teams)) {
  teams_in_playoff=paste(teams_in_playoff,playoff_appearance$Teams[i],sep = ',')
  
}
split_teams=unlist(strsplit(teams_in_playoff,','))
table(split_teams)


champions=read.csv('NBA_Champions.csv')



