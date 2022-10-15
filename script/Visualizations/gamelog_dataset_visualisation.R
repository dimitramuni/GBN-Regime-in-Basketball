#Script to visualise pre-processed gamelog dataset of Chicago Bulls and Portland Trail Blazers

setwd("~/Desktop/GBN-Regime-in-Basketball/data")
chicago_processed_gamelog=read.csv('PreProcessed_Chicago_Gamelog.csv')
#number of data points
nObs<-dim(chicago_processed_gamelog)[1]

#Set:1
## Variables visualised : Game-Outcome, Home-Away, Opponent team in Playoffs
par(mfrow=c(3,1))
barplot(table(chicago_processed_gamelog$WL)/nObs,ylim=c(0,1),main='Game Outcome',ylab='proportion')
barplot(table(chicago_processed_gamelog$HomeAway)/nObs,ylim=c(0,1),main='Home or Away',ylab='proportion')
barplot(table(chicago_processed_gamelog$PlayOff)/nObs,ylim=c(0,1),main='Opponent team in Playoffs',ylab='proportion')

#Set:2
## Variables visualised : for FG%,3P%,FT% for Chicago Bulls and Opponents (3*2=6 variables)
par(mfrow=c(2,3))
hist(chicago_processed_gamelog$TmFGper*100,probability=T,xlab='Team FG%',main ='')
lines(density(chicago_processed_gamelog$TmFGper*100))
hist(chicago_processed_gamelog$Tm3Pper*100,probability=T,xlab='Team 3P%',main='')
lines(density(chicago_processed_gamelog$Tm3Pper*100))
hist(chicago_processed_gamelog$TmFTper*100,probability=T,xlab='Team FT%',main='')
lines(density(chicago_processed_gamelog$TmFTper*100))
hist(chicago_processed_gamelog$OppFGper*100,probability=T,xlab='Opponent FG%',main='')
lines(density(chicago_processed_gamelog$OppFGper*100))
hist(chicago_processed_gamelog$Opp3Pper*100,probability=T,xlab='Opponent 3P%',main='')
lines(density(chicago_processed_gamelog$Opp3Pper*100))
hist(chicago_processed_gamelog$OppFTper*100,probability=T,xlab='Opponent FT%',main='')
lines(density(chicago_processed_gamelog$OppFTper*100))

#Set:3 Six variables, FT rate, TS%, TRB%, AST%, STL%, BLK%
par(mfrow=c(2,3))
hist(chicago_processed_gamelog$FTr*100,freq = FALSE,xlab='Free Throw Rate',main ='')
lines(density(chicago_processed_gamelog$FTr*100))
hist(chicago_processed_gamelog$TSper*100,probability=T,xlab='TS%',main ='')
lines(density(chicago_processed_gamelog$TSper*100))
hist(chicago_processed_gamelog$TRBper*100,probability=T,xlab='TRB%',main ='')
lines(density(chicago_processed_gamelog$TRBper*100))

hist(chicago_processed_gamelog$ASTper*100,probability=T,xlab='AST%',main ='')
lines(density(chicago_processed_gamelog$ASTper*100))
hist(chicago_processed_gamelog$STLper*100,probability=T,xlab='STL%',main ='')
lines(density(chicago_processed_gamelog$STLper*100))
hist(chicago_processed_gamelog$BLKper*100,probability=T,xlab='BLK%',main ='')
lines(density(chicago_processed_gamelog$BLKper*100))


#Set:4 Four factors for Chicago Bulls (Offensive and Defensive, 4*2=8)
par(mfrow=c(4,2))
hist(chicago_processed_gamelog$OffeFGper*100,probability = T,xlab='Offensive eFG%',main='')
lines(density(chicago_processed_gamelog$OffeFGper*100))
hist(chicago_processed_gamelog$OffTOVper*100,probability = T,xlab='Offensive TOV%',main='')
lines(density(chicago_processed_gamelog$OffTOVper*100))
##test
hist(chicago_processed_gamelog$OffORBper*100,probability = T,xlab='ORB%',main='')
lines(density(chicago_processed_gamelog$OffORBper*100))
hist(chicago_processed_gamelog$OffFT_d_FGA*100,probability = T,xlab='Offensive FT/FGA',main='')
lines(density(chicago_processed_gamelog$OffFT_d_FGA*100))

hist(chicago_processed_gamelog$DefeFGper*100,probability = T,xlab='Defensive eFG%',main='')
lines(density(chicago_processed_gamelog$DefeFGper*100))
hist(chicago_processed_gamelog$DefTOVper*100,probability = T,xlab='Defensive TOV%',main='')
lines(density(chicago_processed_gamelog$DefTOVper*100))

hist(chicago_processed_gamelog$DefDRBper*100,probability = T,xlab='DRB%',main='')
lines(density(chicago_processed_gamelog$DefDRBper*100))
hist(chicago_processed_gamelog$DefFT_d_FGA*100,probability = T,xlab='Defensive FT/FGA',main='')
lines(density(chicago_processed_gamelog$DefFT_d_FGA*100))

