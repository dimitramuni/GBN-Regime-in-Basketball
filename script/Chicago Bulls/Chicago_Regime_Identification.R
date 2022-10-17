#Regime Identification for Chicago Bulls, data fetched from Seasons 1983-84 to 2020-21
library(bnlearn)

setwd("~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls")
gamelog_chicago_entire<-read.csv('Augmented_Chicago_Bulls_8384_2021.csv')
gamelog_chicago_entire<-gamelog_chicago_entire[,-c(1)]

#Converting Integer variables into Double; bnlearn package requirement
column_integer<-which(sapply(gamelog_chicago_entire,is.integer))
gamelog_chicago_entire[,column_integer]<-sapply(gamelog_chicago_entire[,column_integer],as.numeric)

features_of_interest<-c('Team_Prospect','HomeGame','Opponent_PlayOff')
#SHAP_features<-c('WinsInLast15','Tm3PAr','OppAST','BLKPer','Pace',
#                 'WinsInLast10','Opp3PA','TmFTPer','ORBPer','Opp3PPer','STLPer',
#                 'OppTOVPer','OppFT_d_FGA','ASTPer','ORtg','DRtg','TRBPer',
#                 'OppFTPer','OppBLK','TmeFGPer')

SHAP_features<-c('WinsInLast15','Tm3PAr','BLKPer','Pace',
                'Opp3PA','TmFTPer','ORBPer','Opp3PPer','STLPer',
                'OppTOVPer','OppFT_d_FGA','ASTPer','TRBPer')

#gamelog_chicago_entire[,features_of_interest]<-sapply(gamelog_chicago_entire[,features_of_interest],as.factor)

# Discretising Numerical Variables
df_discretized<-bnlearn::discretize(gamelog_chicago_entire[,c(SHAP_features)],breaks=5)
df_chicago<-cbind(df_discretized,gamelog_chicago_entire[,features_of_interest])

df_chicago$Opponent_PlayOff<-as.factor(df_chicago$Opponent_PlayOff)
df_chicago$HomeGame<-as.factor(df_chicago$HomeGame)
df_chicago$Team_Prospect<-as.factor(df_chicago$Team_Prospect)

df_chicago$Date<-gamelog_chicago_entire$Date

source('~/Desktop/GBN-Regime-in-Basketball/script/Regime Identification/Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = df_chicago[,-c(17)],k=5,n_iteration = 20000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)

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

bn_overall<-hc(gamelog_discrete_chicago,
               score = 'bde',
               restart = 1000,
               blacklist = blacklisted_arcs1,
               maxp=8)
bnlearn::score(bn_overall,gamelog_discrete_chicago)
graphviz.plot(bn_overall)

bn1<-hc(df_chicago[1:355,-c(17)],
        score = 'bde',
        restart = 1000)
bnlearn::score(bn1,df_chicago[1:355,-c(17)])
graphviz.plot(bn1)

bn2<-hc(df_chicago[356:850,-c(17)],score = 'bde',
        restart = 1000)
bnlearn::score(bn2,df_chicago[356:850,-c(17)])
graphviz.plot(bn2)


bn3<-hc(df_chicago[851:1258,-c(17)],
        score = 'bde',
        restart = 1000)
bnlearn::score(bn3,df_chicago[851:1258,-c(17)])
graphviz.plot(bn3)


bn4<-hc(df_chicago[1259:1918,-c(17)],
        score = 'bde',
        restart = 1000)
bnlearn::score(bn4,df_chicago[1259:1918,-c(17)])
graphviz.plot(bn4)


bn5<-hc(df_chicago[1919:2701,-c(17)],
       score = 'bde',
       restart = 1000,
       maxp=8)
bnlearn::score(bn5,df_chicago[1919:2701,-c(17)])
graphviz.plot(bn5)



#bn3<-rsmax2(gamelog_discrete_chicago)
#bnlearn::score(bn3,gamelog_discrete_chicago)
#graphviz.plot(bn3)

#bn4<-mmhc(gamelog_discrete_chicago)
#bnlearn::score(bn4,gamelog_discrete_chicago)
#graphviz.plot(bn4)

#bn5<-h2pc(gamelog_discrete_chicago)
#bnlearn::score(bn5,gamelog_discrete_chicago)
#graphviz.plot(bn5)



source('Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = gamelog_discrete_chicago,k=3,n_iteration = 2)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)

teams_in_playoff=playoff_appearance$Teams[1]
for (i in 2:length(playoff_appearance$Teams)) {
  teams_in_playoff=paste(teams_in_playoff,playoff_appearance$Teams[i],sep = ',')
  
}
split_teams=unlist(strsplit(teams_in_playoff,','))
table(split_teams)


champions=read.csv('NBA_Champions.csv')



regime_list<-list(1:1283,1284:2113,2114:2773,2774:3090)

for (i in 1:length(regime_list)) {
  
  bn<-hc(x= gamelog_discrete_chicago[regime_list[[i]],],score = 'bde',blacklist = blacklisted_arcs1)
  #Bayesian Dirichilet Equivalent score
  cat('\n regime',i,'\t BDe',bnlearn::score(bn, gamelog_discrete_chicago[regime_list[[i]],], type = "bde"))
  
}
