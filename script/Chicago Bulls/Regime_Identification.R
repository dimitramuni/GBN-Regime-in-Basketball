
#11 variables (four factor*2, Outcome,PlayOff,HomeAway)
gamelog_discrete_chicago<-discretize(gamelog_stat_chicago[,-c(1:15,24:25)], breaks = 5)
#gamelog_discrete_chicago$Opp<-factor(gamelog_stat_chicago$Opp)
gamelog_discrete_chicago$WL<-factor(gamelog_stat_chicago$WL)
gamelog_discrete_chicago$PlayOff<-factor(gamelog_stat_chicago$PlayOff)
gamelog_discrete_chicago$HomeAway<-factor(gamelog_stat_chicago$HomeAway)


source('~/Desktop/GBN-Regime-in-Basketball/script/Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = gamelog_discrete_chicago,k=3,n_iteration = 2000)
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

bn1<-hc(gamelog_discrete_chicago[1:1282,],
        score = 'bde',
        blacklist = blacklisted_arcs1,
        restart = 1000,
        maxp=8)
bnlearn::score(bn1,gamelog_discrete_chicago)
graphviz.plot(bn1)

bn2<-hc(gamelog_discrete_chicago[1283:2105,],score = 'bde',
        restart = 1000,
        blacklist = blacklisted_arcs1,
        maxp=8)
bnlearn::score(bn2,gamelog_discrete_chicago)
graphviz.plot(bn2)


bn3<-hc(gamelog_discrete_chicago[2106:2775,],
        score = 'bde',
        restart = 1000,
        blacklist = blacklisted_arcs1,
        maxp=8)
bnlearn::score(bn3,gamelog_discrete_chicago)
graphviz.plot(bn3)


bn4<-hc(gamelog_discrete_chicago[2776:dim(gamelog_discrete_chicago)[1],],
        blacklist = blacklisted_arcs1,
        score = 'bde',
        restart = 1000,
        maxp=8)
bnlearn::score(bn4,gamelog_discrete_chicago)
graphviz.plot(bn4)

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
