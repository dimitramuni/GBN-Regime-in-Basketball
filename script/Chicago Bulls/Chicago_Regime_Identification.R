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


numeric_cols<-which(sapply(gamelog_chicago_entire,is.numeric))
gamelog_chicago_entire[,numeric_cols]<-scale(gamelog_chicago_entire[,numeric_cols])
features_of_interest<-c('Team_Prospect','Home')
# SHAP_features<-c('WinsInLast15','Continuing_Players_WS','Incoming_Players_WS','Leaving_Players_WS','WinsInLast10',
# 'Tm3PAr','Pace','DRtg','OppFT_d_FGA','BLKPer','Tm3PPer','TmPF','ORBPer',
# 'OppeFGPer','TmFTPer','DRBPer','TRBPer','Tm3PA','ORtg','ASTPer')

#'WinsInLast15','Tm3PAr','OppAST','BLKPer','Pace',
#                  'WinsInLast10','Opp3PA','TmFTPer','ORBPer','Opp3PPer',
#                  'STLPer','OppTOVPer','OppFT_d_FGA','ASTPer','ORtg',
#                  'DRtg','TRBPer','OppFTPer','OppBLK','TmeFGPer')




SHAP_features<-c('WinsInLast15','Continuing_Players_WS','Incoming_Players_WS','Leaving_Players_WS','WinsInLast10',
                 'Tm3PAr','DRtg','OppFT_d_FGA','BLKPer','TmPF',
                 'OppeFGPer','TRBPer','ASTPer')

#SHAP_features<-c('DRtg','ORtg','Continuing_Players_WS','OppeFGPer','OppTOVPer',
#                 'WinsInLast15','TmTOVPer','TSPer','Incoming_Players_WS','TRBPer',
#                 'BLKPer','STLPer','Leaving_Players_WS')

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
Identify_Positions_hc(data = df_chicago[,-c(1)],k=4,n_iteration =10000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)


Loglikelihood_Calculation_hc<-function(dataset){
  
  #data=gamelog_discrete
  blacklisted_arcs1<-data.frame(from = c("WL", "WL","WL", "WL","WL", "WL","WL", "WL","WL", "WL",
                                         "OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","PlayOff",
                                         "OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","HomeAway"), 
                                to = c("OffeFGper","OffTOVper","OffORBper","OffFT_d_FGA","DefeFGper","DefTOVper","DefDRBper","DefFT_d_FGA","PlayOff", "HomeAway",
                                       "HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway","HomeAway",
                                       "PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff","PlayOff"))
  
  #Learning Bayesian Network using Hill Climbing Algorithm
  #bn<-hc(x=dataset,score = 'bde')
  bn<-hc(x=dataset,score = 'bde')
  #Bayesian Dirichilet Equivalent score
  BDE_score<-bnlearn::score(bn, dataset, type = "bde")
  return(BDE_score)
}





regimes<-split_index(df_chicago[,-c(1)],c(390,930, 1695, 2689))

sapply(regimes,Loglikelihood_Calculation_hc)


#Structure learning using Hill Climbing Algorithm #L21 and L25 partly (adding the loglikelihood)
#n2=length(D_proposal)
n<-dim(df_chicago)[1]

regime_list<-list(1:389,390:929,930:1694,1695:2688,2689:n)
bn<-list()

for (i in 1:length(regime_list)) {
  
  bn[[i]]<-hc(x= df_chicago[regime_list[[i]],-c(1)],score = 'bde')
  #Bayesian Dirichilet Equivalent score

  start_date=df_chicago$Date[regime_list[[i]][1]]
  end_date=df_chicago$Date[regime_list[[i]][length(regime_list[[i]])]]
  graphviz.plot(bn[[i]],main= paste('Regime from ',start_date,' to ',end_date,sep=" "),shape='ellipse',
                highlight = list(nodes='Team_Prospect',fill='yellow',col='brown'))
  cat('\n regime',i,'\t BDe',bnlearn::score(bn[[i]], 
                                            df_chicago[regime_list[[i]],-c(1)], type = "bde"))

  
}

BN_U<- hc(x=df_chicago[,-c(1)],score='bde')
start_date=df_chicago$Date[1]
end_date=df_chicago$Date[n]
graphviz.plot(BN_U,main= paste('Regime from ',start_date,' to ',end_date,sep=" "),shape='ellipse',
              highlight = list(nodes='Team_Prospect',fill='yellow',col='brown'))
score(BN_U,regimes[[1]])
