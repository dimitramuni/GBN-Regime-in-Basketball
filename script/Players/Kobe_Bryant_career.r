#Structure Learning for Basketball Player's regime 
#References: i) https://lib.dr.iastate.edu/cgi/viewcontent.cgi?article=7962&context=etd
#           ii) https://www.basketball-reference.com/

library(bnlearn)
library(gRain)
library(Rgraphviz)
library(graph)
library(grid)
library(snow)
library(tidyverse)
library(lubridate)
gamelog_kobe<-read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Player-Gamelogs/KobeB_regular_gamelog.csv')

#Data Cleaning 
gamelog_kobe$HomeAway<- ifelse(gamelog_kobe$Sep=='@','Away','Home')
gamelog_kobe$GS<- ifelse(gamelog_kobe$GS==1,TRUE,FALSE)
parameters<-c('Date','Opp','Result','GS','MP','FG','FGA','FGper','TwoP','TwoPA','TwoPper','ThreeP','ThreePA','ThreePper','FT','FTA',
              'FTper','TSper','ORB','DRB','TRB','AST','STL','BLK','TOV','PF','PTS','GmSC','BPM','HomeAway')
#Including the games with alteast 15 mintues of gameplay
reduced1<-gamelog_kobe[which(gamelog_kobe$MP>=15),colnames(gamelog_kobe) %in% parameters]
#filling the NA values with 0 
reduced1[is.na(reduced1)]<-0
#scaling and discretisation

para_to_scale<-c('FG','FGA','TwoP','TwoPA','ThreeP','ThreePA','FT','FTA','FTper','TSper','ORB','DRB','TRB','AST','STL','BLK','TOV','PF','PTS','BPM')
reduced2<-as.data.frame(scale(reduced1[,para_to_scale]))
reduced3<-discretize(reduced2,method='interval',breaks = 5)
reduced3$GS<-as.factor(reduced1$GS)
reduced3$HomeAway<-as.factor(reduced1$HomeAway)

gamelog_kobe_discret<-reduced3[,c('GS','HomeAway','ORB','DRB','AST','STL','BLK','BPM','TSper','ThreePA','FGA','TwoPA')]


write.csv(gamelog_kobe_discrete,file = 'data/Player-Gamelogs/gamelog_kobe_preprocessed.csv')

source('~/Desktop/GBN-Regime-in-Basketball/script/Identify_hc.R')


start_time<-Sys.time()
Identify_Positions_hc(data =gamelog_kobe_discret,k=4,n_iteration = 10000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)


