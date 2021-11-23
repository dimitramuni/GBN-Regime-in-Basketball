#Using additive bayesian modeling package for some experiments
require(abn)
setwd("~/Desktop/GBN-Regime-in-Basketball/data")
chicago_processed_gamelog=read.csv('PreProcessed_Chicago_Gamelog.csv')
#number of data points
nObs<-dim(chicago_processed_gamelog)[1]

#reference : https://gilleskratzer.github.io/ABN-UseR-2021/hands_on_useR_2021.html

#Converting Game Outcome, HomeAway and Opponent Playoff Appearance (binary variables) to factor datatype

chicago_processed_gamelog$WL<-factor(chicago_processed_gamelog$WL)
chicago_processed_gamelog$PlayOff<-factor(chicago_processed_gamelog$PlayOff)
chicago_processed_gamelog$HomeAway<-factor(chicago_processed_gamelog$HomeAway)

##Experiment 1 all variables
#Setting up distribution list
distribution1<-list(WL="binomial",TmFGper="gaussian",Tm3Pper="gaussian",TmFTper="gaussian",
                   OppFGper="gaussian",Opp3Pper="gaussian",OppFTper="gaussian",FTr="gaussian",TSper="gaussian",
                   TRBper="gaussian",ASTper="gaussian",STLper="gaussian",BLKper="gaussian",
                   OffeFGper="gaussian",OffTOVper="gaussian",OffORBper="gaussian",
                   OffFT_d_FGA="gaussian",DefeFGper="gaussian",DefTOVper="gaussian",DefDRBper="gaussian",
                   DefFT_d_FGA="gaussian",HomeAway="binomial",PlayOff="binomial")

#Build cache 
cache1<-buildScoreCache(data.df=as.data.frame(chicago_processed_gamelog[,-c(1,2)]),
                       data.dists=distribution1, max.parents = 1)
#Exact Search
mp_dag1<-mostProbable(score.cache = cache1)
fitted_dag1<-fitAbn(object=mp_dag1)


##Experiment 2 using Four factors,Outcome, HomeAway and Playoff
distribution2<-list(WL="binomial",OffeFGper="gaussian",OffTOVper="gaussian",OffORBper="gaussian",
                    OffFT_d_FGA="gaussian",DefeFGper="gaussian",DefTOVper="gaussian",DefDRBper="gaussian",
                    DefFT_d_FGA="gaussian",HomeAway="binomial",PlayOff="binomial")



cache2<-buildScoreCache(data.df=as.data.frame(chicago_processed_gamelog[,c(3,16:25)]),
                       data.dists=distribution2)
#Banned matrix
df<-as.data.frame(chicago_processed_gamelog[,c(3,16:25)])
banned<-matrix(0,ncol(df),ncol(df))
rownames(banned)<-colnames(df)
colnames(banned)<-colnames(df)

#Retained matrix
retained<-matrix(0,ncol(df),ncol(df))
rownames(retained)<-colnames(df)
colnames(retained)<-colnames(df)
  
##Banning the arc from any Match Outcome to any other node, since outcome of game might not affect other nodes
banned[-1,c('WL')]<-1
banned[c('HomeAway'),c(1:9,11)]<-1
banned[c('PlayOff'),1:10]<-1

##Retaining the arc from HomeAway and Opponent Playoff appearance to Game Outcome
retained[c('WL'),c('HomeAway')]<-1
retained[c('WL'),c('PlayOff')]<-1
  
#Exact Search
mp_dag2<-mostProbable(score.cache = cache2)
dag2<-fitAbn(object=mp_dag2,dag.banned=banned,dag.retained=retained,create.graph = T)
plot(dag2)


##Running the exact search for parents incremently

#creating a function which takes maximum number of parents parameter as input and calculate the score

NetworkScore<-function(p){
  
  #creating cache for the network, for maximum p arents, for 11 variables
  cached_network<-buildScoreCache(data.df=as.data.frame(chicago_processed_gamelog[,c(3,16:25)]),
                          data.dists=distribution2, max.parents = p)
  mp_dag<-mostProbable(score.cache = cached_network)
  dag_11vars<-fitAbn(object=mp_dag,dag.banned=banned,dag.retained=retained,create.graph = T)
  return(dag_11vars$mlik)
  
}

scores<-sapply(1:10,NetworkScore)
plot(x=1:10,y=scores,type = 'p',ylim=range(scores) )
abline(v=which.max(scores))
     
cached_network<-buildScoreCache(data.df=as.data.frame(chicago_processed_gamelog[,c(3,16:25)]),
                                data.dists=distribution2, max.parents = 8)
mp_dag<-mostProbable(score.cache = cached_network)
dag_11vars<-fitAbn(object=mp_dag,dag.banned=banned,create.graph = T)
plot(dag_11vars)
