#Regime Identification for Chicago Bulls, data fetched from Seasons 1983-84 to 2020-21
rm(list=ls())
library(bnlearn)

setwd("~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls")
gamelog_chicago_entire<-read.csv('Augmented_Chicago_Bulls_8384_2021.csv')
gamelog_chicago_entire<-gamelog_chicago_entire[,-c(1)]

#Converting Integer variables into Double; bnlearn package requirement
column_integer<-which(sapply(gamelog_chicago_entire,is.integer))
gamelog_chicago_entire[,column_integer]<-sapply(gamelog_chicago_entire[,column_integer],as.numeric)

features_of_interest<-c('Team_Prospect','HomeGame')
#SHAP_features<-c('WinsInLast15','Tm3PAr','OppAST','BLKPer','Pace',
#                 'WinsInLast10','Opp3PA','TmFTPer','ORBPer','Opp3PPer',
#                 'STLPer','OppTOVPer','OppFT_d_FGA','ASTPer','ORtg',
#                 'DRtg','TRBPer','OppFTPer','OppBLK','TmeFGPer')

SHAP_features<-c('WinsInLast15','Tm3PAr',
                 'WinsInLast10','Opp3PA','ORBPer',
                 'STLPer','OppTOVPer','ASTPer','ORtg','TRBPer')


#gamelog_chicago_entire[,features_of_interest]<-sapply(gamelog_chicago_entire[,features_of_interest],as.factor)

# Discretising Numerical Variables
df_discretized<-bnlearn::discretize(gamelog_chicago_entire[,c(SHAP_features)],breaks=5)
df_chicago<-cbind(df_discretized,gamelog_chicago_entire[,features_of_interest])

#df_chicago$Opponent_PlayOff<-as.factor(df_chicago$Opponent_PlayOff)
df_chicago$HomeGame<-as.factor(df_chicago$HomeGame)
df_chicago$Team_Prospect<-as.factor(df_chicago$Team_Prospect)
df_chicago$Date<-gamelog_chicago_entire$Date

source('~/Desktop/GBN-Regime-in-Basketball/script/Regime Identification/Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = df_chicago[,-c(13)],k=4,n_iteration = 10000)
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




bn1<-hc(df_chicago[1:355,-c(13)],
        score = 'bde',
        restart = 1000,perturb = 1000)
bnlearn::score(bn1,df_chicago[1:355,-c(13)])
graphviz.plot(bn1)


bn2<-hc(df_chicago[356:850,-c(13)],score = 'bde',
        restart = 1000,perturb=1000)
bnlearn::score(bn2,df_chicago[356:850,-c(13)])
graphviz.plot(bn2,layout='')


bn3<-hc(df_chicago[851:1258,-c(13)],
        score = 'bde',
        restart = 1000)
bnlearn::score(bn3,df_chicago[851:1258,-c(13)])
graphviz.plot(bn3)


bn4<-hc(df_chicago[1259:1918,-c(13)],
        score = 'bde',
        restart = 1000)
bnlearn::score(bn4,df_chicago[1259:1918,-c(13)])
graphviz.plot(bn4)


bn5<-hc(df_chicago[1919:2701,-c(13)],
       score = 'bde',
       restart = 1000)
bnlearn::score(bn5,df_chicago[1919:2701,-c(13)])
graphviz.plot(bn5)

bn6<-hc(df_chicago[2702:dim(df_chicago)[1],-c(13)],
        score = 'bde',
        restart = 1000)
bnlearn::score(bn6,df_chicago[2702:dim(df_chicago)[1],-c(13)])
graphviz.plot(bn6)


bn_entire<-hc(df_chicago[,-c(13)],
              score = 'bde',
              restart = 1000)
bnlearn::score(bn_entire,df_chicago[,-c(13)])
graphviz.plot(bn_entire)



#bn3<-rsmax2(gamelog_discrete_chicago)
#bnlearn::score(bn3,gamelog_discrete_chicago)
#graphviz.plot(bn3)

#bn4<-mmhc(gamelog_discrete_chicago)
#bnlearn::score(bn4,gamelog_discrete_chicago)
#graphviz.plot(bn4)

#bn5<-h2pc(gamelog_discrete_chicago)
#bnlearn::score(bn5,gamelog_discrete_chicago)
#graphviz.plot(bn5)



# source('Identify_hc.R')
# start_time<-Sys.time()
# Identify_Positions_hc(data = gamelog_discrete_chicago,k=3,n_iteration = 2)
# end_time<-Sys.time()
# cat('time taken: ',end_time-start_time)
# 
# teams_in_playoff=playoff_appearance$Teams[1]
# for (i in 2:length(playoff_appearance$Teams)) {
#   teams_in_playoff=paste(teams_in_playoff,playoff_appearance$Teams[i],sep = ',')
#   
# }
# split_teams=unlist(strsplit(teams_in_playoff,','))
# table(split_teams)


# champions=read.csv('NBA_Champions.csv')


n<-dim(df_chicago)[1]

regime_list1<-list(1:431,432:953,954:1281,1282:1667,1668:2660,2661:n)
regime_list2<-list(1:417,418:1239,1240:1697,1698:2450,2451:2700,2701:n)

regime_list3<-list(1:206,207:918,919:1220,1221:1707,1708:2692,2693:n)

regime_list4<-list(1:438,439:1341,1342:1784,1785:2647,2647:n)
regime_list5<-list(1:767,768:961,962:1233,1234:1707,1708:2699,2700:n)
regime_list6<-list(1:296,297:475,476:1238,1239:1707,1708:2690,2691:n)
#rseven<-list(156  389  987 1709 2156 2624

r_list1<-list(1:397,398:986,987:1683,1684:2735,2736:n)
r_list2<-list(1:466,467:1195,1196:1881,1882:2717,2718:n)
r_list3<-list(1:336,337:906,907:1579,1580:2627,2628:n)
r_list4<-list(1:469,470:1230,1231:1731,1732:2583,2584:n)
r_list5<-list(1:418,419:1252,1253:1650,1651:2775,2776:n)
r_list6<-list(1:351,352:955,956:1732,1733:2698,2699:n)

regime_list<-r_list1
total_lik<-c()
BNS<-list(length=length(regime_list))

for (i in 1:length(regime_list)) {
  
  bn<-hc(x= df_chicago[regime_list[[i]],-c(13)],score = 'bde')
  #Bayesian Dirichilet Equivalent score
  BNS[[i]]<-bn
  start_date=df_chicago$Date[regime_list[[i]][1]]
  end_date=df_chicago$Date[regime_list[[i]][length(regime_list[[i]])]]
  graphviz.plot(bn,main= paste('Regime from ',start_date,' to ',end_date,sep=" "))
  cat('\n regime',i,'\t BDe',bnlearn::score(bn, df_chicago[regime_list[[i]],-c(13)], type = "bde"))
  total_lik<-c(total_lik,bnlearn::score(bn, df_chicago[regime_list[[i]],-c(13)],type = "bde"))
  
}
sum(total_lik)
for(i in  1:length(regime_list)){
  cat('\ni:',i,score(BNS[[1]],df_chicago[regime_list[[i]],-c(13)], type = "bde"))
}

Unified<-hc(x=df_chicago[,-c(13)],type = 'bde')
for (i in  1:length(regime_list)) {
  cat('\ni:',i,score(Unified,df_chicago[regime_list[[i]],-c(13)], type = "bde"))
}

