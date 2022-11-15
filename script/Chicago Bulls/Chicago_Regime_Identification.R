#Regime Identification for Chicago Bulls, data fetched from Seasons 1983-84 to 2020-21
rm(list=ls())
library(bnlearn)

setwd("~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls")
gamelog_chicago_entire<-read.csv('Augmented_Chicago_Bulls_8384_2021.csv')
n<-dim(gamelog_chicago_entire)[1]
window_length=20
#gamelog_chicago_entire<-gamelog_chicago_entire[,-c(1)]

#Converting Integer variables into Double; bnlearn package requirement
column_integer<-which(sapply(gamelog_chicago_entire[(window_length+1):n,],is.integer))
gamelog_chicago_entire[,column_integer]<-sapply(gamelog_chicago_entire[,column_integer],as.numeric)

gamelog_chicago_entire$Team_Prospect<-as.numeric(gamelog_chicago_entire$Team_Prospect)
features_of_interest<-c('Team_Prospect','Home')
# SHAP_features<-c('WinsInLast15','Tm3PAr','OppAST','BLKPer','Pace',
#                  'WinsInLast10','Opp3PA','TmFTPer','ORBPer','Opp3PPer',
#                  'STLPer','OppTOVPer','OppFT_d_FGA','ASTPer','ORtg',
#                  'DRtg','TRBPer','OppFTPer','OppBLK','TmeFGPer')

#SHAP_features<-c('WinsInLast15','Tm3PAr',
#               'WinsInLast10','Opp3PA','ORBPer',
#                 'STLPer','OppTOVPer','ASTPer','ORtg','TRBPer')

SHAP_features<-c('DRtg','ORtg','Continuing_Players_WS48','OppeFGPer','OppTOVPer',
                 'WinsInLast15','TmTOVPer','TSPer','Incoming_Players_WS48','TRBPer',
                 'BLKPer','STLPer','Leaving_Players_WS48')

#gamelog_chicago_entire[,features_of_interest]<-sapply(gamelog_chicago_entire[,features_of_interest],as.factor)

# Discretising Numerical Variables
df_discretized<-bnlearn::discretize(gamelog_chicago_entire[(window_length+1):n,c(SHAP_features,'Team_Prospect')],breaks=5)
df_chicago<-df_discretized

#df_chicago$Opponent_PlayOff<-as.factor(df_chicago$Opponent_PlayOff)
df_chicago$Home<-as.factor(gamelog_chicago_entire$Home[(window_length+1):n])


#df_chicago$Team_Prospect<-as.factor(df_chicago$Team_Prospect)
date_df<-data.frame(Date=gamelog_chicago_entire$Date[(window_length+1):n])
df_chicago<-cbind(date_df,df_chicago)
write.csv(df_chicago,'~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls/Processed_Chicago_Bulls.csv',row.names = FALSE)

source('~/Desktop/GBN-Regime-in-Basketball/script/Regime Identification/Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = df_chicago[,-c(1)],k=4,n_iteration = 1000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)

#blacklisting certain arcs






# 
# 
# n<-dim(df_chicago)[1]
# 
# regime_list1<-list(1:431,432:953,954:1281,1282:1667,1668:2660,2661:n)
# regime_list2<-list(1:417,418:1239,1240:1697,1698:2450,2451:2700,2701:n)
# 
# regime_list3<-list(1:206,207:918,919:1220,1221:1707,1708:2692,2693:n)
# 
# regime_list4<-list(1:438,439:1341,1342:1784,1785:2647,2647:n)
# regime_list5<-list(1:767,768:961,962:1233,1234:1707,1708:2699,2700:n)
# regime_list6<-list(1:296,297:475,476:1238,1239:1707,1708:2690,2691:n)
# #rseven<-list(156  389  987 1709 2156 2624
# 
# r_list1<-list(1:397,398:986,987:1683,1684:2735,2736:n)
# r_list2<-list(1:466,467:1195,1196:1881,1882:2717,2718:n)
# r_list3<-list(1:336,337:906,907:1579,1580:2627,2628:n)
# r_list4<-list(1:469,470:1230,1231:1731,1732:2583,2584:n)
# r_list5<-list(1:418,419:1252,1253:1650,1651:2775,2776:n)
# r_list6<-list(1:351,352:955,956:1732,1733:2698,2699:n)
# 
# regime_list<-r_list1
# total_lik<-c()
# BNS<-list(length=length(regime_list))
# 
# for (i in 1:length(regime_list)) {
#   
#   bn<-hc(x= df_chicago[regime_list[[i]],-c(13)],score = 'bde')
#   #Bayesian Dirichilet Equivalent score
#   BNS[[i]]<-bn
#   start_date=df_chicago$Date[regime_list[[i]][1]]
#   end_date=df_chicago$Date[regime_list[[i]][length(regime_list[[i]])]]
#   graphviz.plot(bn,main= paste('Regime from ',start_date,' to ',end_date,sep=" "))
#   cat('\n regime',i,'\t BDe',bnlearn::score(bn, df_chicago[regime_list[[i]],-c(13)], type = "bde"))
#   total_lik<-c(total_lik,bnlearn::score(bn, df_chicago[regime_list[[i]],-c(13)],type = "bde"))
#   
# }
# sum(total_lik)
# for(i in  1:length(regime_list)){
#   cat('\ni:',i,score(BNS[[1]],df_chicago[regime_list[[i]],-c(13)], type = "bde"))
# }
# 
# Unified<-hc(x=df_chicago[,-c(13)],type = 'bde')
# for (i in  1:length(regime_list)) {
#   cat('\ni:',i,score(Unified,df_chicago[regime_list[[i]],-c(13)], type = "bde"))
# }
# 
