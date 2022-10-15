library(abn)
library(mcmcabn)
setwd("~/Desktop/GBN-Regime-in-Basketball/data")
chicago_processed_gamelog=read.csv('PreProcessed_Chicago_Gamelog.csv')
#number of data points
nObs<-dim(chicago_processed_gamelog)[1]

#Converting Game Outcome, HomeAway and Opponent Playoff Appearance (binary variables) to factor datatype

chicago_processed_gamelog$WL<-factor(chicago_processed_gamelog$WL)
chicago_processed_gamelog$PlayOff<-factor(chicago_processed_gamelog$PlayOff)
chicago_processed_gamelog$HomeAway<-factor(chicago_processed_gamelog$HomeAway)

#Setting up distribution list
distribution_alpha<-list(WL="binomial",TmFGper="gaussian",Tm3Pper="gaussian",TmFTper="gaussian",
                    OppFGper="gaussian",Opp3Pper="gaussian",OppFTper="gaussian",FTr="gaussian",TSper="gaussian",
                    TRBper="gaussian",ASTper="gaussian",STLper="gaussian",BLKper="gaussian",
                    OffeFGper="gaussian",OffTOVper="gaussian",OffORBper="gaussian",
                    OffFT_d_FGA="gaussian",DefeFGper="gaussian",DefTOVper="gaussian",DefDRBper="gaussian",
                    DefFT_d_FGA="gaussian",HomeAway="binomial",PlayOff="binomial")

cached_alpha<-buildScoreCache(data.df=as.data.frame(chicago_processed_gamelog[,3:25]),
                        data.dists=distribution_alpha,max.parents = 1)

#Banned matrix
df<-as.data.frame(chicago_processed_gamelog[,3:25])
banned<-matrix(0,ncol(df),ncol(df))
rownames(banned)<-colnames(df)
colnames(banned)<-colnames(df)

#Retained matrix
retained<-matrix(0,ncol(df),ncol(df))
rownames(retained)<-colnames(df)
colnames(retained)<-colnames(df)

#Banning 

#Banning the arc from Match Outcome to any other node, since outcome of game might not affect other nodes
banned[-1,c('WL')]<-1
#None of the nodes except HomeAway should affect if the game is played at Home or Away
banned[c('HomeAway'),-22]<-1
#None of the nodes except PlayOff(if the opponent played in PlayOff) should have causal link to PlayOff
banned[c('PlayOff'),1:22]<-1

##Retaining the arc from HomeAway and Opponent Playoff appearance to Game Outcome

#Playing at Home or Away has causal link with game outcome
retained[c('WL'),c('HomeAway')]<-1
#If opponet team appeared in PlayOff has causal link with game outcome
retained[c('WL'),c('PlayOff')]<-1


#Exact Search and finding optimal value for max.parents parameter


NetworkScore<-function(p){
  
  #creating cache for the network, for maximum p arents, for 23 variables
  cached_network<-buildScoreCache(data.df=as.data.frame(chicago_processed_gamelog[,3:25]),
                                  data.dists=distribution_alpha, max.parents = p)
  #most probable and fitting function from abn
  mp_dag<-mostProbable(score.cache = cached_network)
  dag_23vars<-fitAbn(object=mp_dag,dag.banned=banned,dag.retained=retained,create.graph = T)
  return(dag_23vars$mlik)
  
}

mp_dag<-mostProbable(score.cache = cached_alpha)
dag<-fitAbn(object=mp_dag,dag.banned=banned,dag.retained=retained,create.graph = T)
plot(dag)

