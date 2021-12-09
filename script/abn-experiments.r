#Using additive bayesian modeling package for some experiments
library(abn)
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



cache2<-buildscorecache(data.df=as.data.frame(chicago_processed_gamelog[,c(3,16:25)]),
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

#Banning 
  
#Banning the arc from Match Outcome to any other node, since outcome of game might not affect other nodes
banned[-1,c('WL')]<-1
#None of the nodes except HomeAway should affect if the game is played at Home or Away
banned[c('HomeAway'),c(1:9,11)]<-1
#None of the nodes except PlayOff(if the opponent played in PlayOff) should have causal link to PlayOff
banned[c('PlayOff'),1:10]<-1

##Retaining the arc from HomeAway and Opponent Playoff appearance to Game Outcome

#Playing at Home or Away has causal link with game outcome
retained[c('WL'),c('HomeAway')]<-1
#If opponet team appeared in PlayOff has causal link with game outcome
retained[c('WL'),c('PlayOff')]<-1
  
#Exact Search'

mp_dag2<-mostprobable(score.cache = cache2,score='mlik',prior.choice = 1)
dag2<-fitabn(object=mp_dag2,dag.banned=banned,dag.retained=NULL,create.graph = T)
plot(dag2)


##Running the exact search for parents incremently

#creating a function which takes maximum number of parents parameter as input and calculate the score

NetworkScore<-function(p){
  
  #creating cache for the network, for maximum p arents, for 11 variables
  c_network<-buildscorecache(data.df=as.data.frame(chicago_processed_gamelog[1:1282,c(3,16:25)]),
                          data.dists=distribution2, max.parents = p)
  #most probable and fitting function from abn
  mp_dag<-mostprobable(score.cache = c_network)
  dag_11vars<-fitabn(object=mp_dag,dag.banned=banned,dag.retained=retained,create.graph = T)
  return(dag_11vars$mlik)
  
}

#finding out optimal number of parents for which Network Score is the highest
scores<-sapply(1:10,NetworkScore)
#plotting the network score vs number of parents 
plot(x=1:10,y=scores,type = 'p',ylim=range(scores) ,xlab='Number of parents',ylab='Marginal Log Likelihood of the model')
abline(v=which.max(scores))

#Learning the final dag for number of parents for which Network Score is the highest  
cached_network1<-buildscorecache(data.df=as.data.frame(chicago_processed_gamelog[1:1282,c(3,16:25)]),
                                data.dists=distribution2, max.parents = 8,verbose=F)
mp_dag1<-mostprobable(score.cache = cached_network1,verbose = F)
dag_11vars1<-fitabn(object=mp_dag1,dag.banned=NULL,create.graph = T,verbose = F)
plot(dag_11vars1)



####Regime Identification for 11 vars
source('Identify_exact_abn.R')
start_time<-Sys.time()
Identify_Positions_abn(data=chicago_processed_gamelog[,c(3,16:25)],
                       distribution =distribution2,banned=banned,retained=retained,max_parents = 8,k=3, n_iteration = 2)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)




