#Data Cleaning Portland Season 1999-00
library(lubridate)
library(ggplot2)
library(ggpubr)
setwd("~/Desktop/Sports Analytics/NBA-Player-Profile-analysis")
portland_9900=read.csv('Portland_gamelog_1999_2000.csv')
portland_9900$HomeAway<- ifelse(portland_9900$Sep=='@','Away','Home')

team_tags<-c('MIA','NYK','PHI','ORL','BOS','NJN','WAS','IND','CHH','TOR','DET','MIL','CLE','ATL',
             'CHI','UTA','SAS','MIN','DAL','DEN','HOU','VAN','LAL','POR','SEA','SAC','GSW','LAC','PHO')

### Total Team Salaries in season 1999-00

team_total_salary=data.frame('Team'=team_tags,'Salary'=NA)

setwd("~/Desktop/Sports Analytics/NBA-Player-Profile-analysis/salary_9900")
for (ind in 1:length(team_tags)){
  
  df<-read.csv(paste0(team_tags[ind],'_9900_salary.csv'))
  team_total_salary[ind,2]=  sum(df[,2])
}




### common code for BN
setwd("~/Desktop/Sports Analytics/NBA-Player-Profile-analysis")
season_gamelog=read.csv('Portland_gamelog_1999_2000.csv')

player_names=c('RWallace','SPippen','SteveS','DamonS','ArvydasS','DetlefS','GregA',
               'BrianG','BonziW','JermaineO','StaceyA','AntonioH','JoeK','GaryG')

for (i in 1:length(player_names)) {
  

player_date_MP=read.csv(paste0(player_names[i],'.csv'))
player_date_MP$MP=round(as.difftime(player_date_MP$MP,format = "%M:%S", units = "mins"))
player_date_MP$Involvment= ifelse(player_date_MP$MP<=5,'Min',ifelse(player_date_MP$MP>=20,'Max','Medium'))

## Games not played by the player

if(length(setdiff(season_gamelog$Date,player_date_MP$Date))>0){
  print(setdiff(season_gamelog$Date,player_date_MP$Date))
  cat(player_names[i],'wee!!')
  season_gamelog[-which(season_gamelog$Date %in% setdiff(season_gamelog$Date,player_date_MP$Date)),player_names[i]]=player_date_MP$Involvment
  season_gamelog[which(season_gamelog$Date %in% setdiff(season_gamelog$Date,player_date_MP$Date)),player_names[i]]=c('Min')
  
}
else {season_gamelog[,player_names[i]]=player_date_MP$Involvment}

}
head(season_gamelog)

####
library(bnlearn)
library(dplyr)
library(Rgraphviz)
df=season_gamelog[,c(-1,-2,-3,-5,-6)]

df<-mutate_all(df,as.factor)
graphviz.plot(hc(df))

glm(formula = WL~.,family = binomial(link = 'logit'),data=df)


################# Attempt Regression

season_gamelog=read.csv('Portland_gamelog_1999_2000.csv')
season_gamelog$ScorePM=season_gamelog$TmScore-season_gamelog$OppScore
season_gamelog$log_diff_salary=NA
for (ind in 1:dim(season_gamelog)[1]) {


season_gamelog[ind,c('log_diff_salary')]= 
  log(team_total_salary$Salary[which(team_total_salary$Team=='POR')])-log(team_total_salary$Salary[which(team_total_salary$Team==season_gamelog$Opp[ind])]  ) 

}

fit<-lm(formula = ScorePM~log_diff_salary,season_gamelog)
prd<-predict(fit)

plot(x=season_gamelog$log_diff_salary,y=season_gamelog$ScorePM,type='p')
points(x=season_gamelog$log_diff_salary,y=prd,col='red')

season_gamelog$HomeAway<- ifelse(portland_9900$Sep=='@','Away','Home')
home_inds=which(season_gamelog$HomeAway=='Home')
away_inds=which(season_gamelog$HomeAway=='Away')


### Regressing with differently for home and away game

fit_home<-lm(formula = ScorePM~log_diff_salary,season_gamelog[home_inds,])
prd_home<-predict(fit_home)

plot(x=season_gamelog$log_diff_salary[home_inds],y=season_gamelog$ScorePM[home_inds],type='p')
points(x=season_gamelog$log_diff_salary[home_inds],y=prd_home,col='red')


fit_away<-lm(formula = ScorePM~log_diff_salary,season_gamelog[away_inds,])
prd_away<-predict(fit_away)

plot(x=season_gamelog$log_diff_salary[away_inds],y=season_gamelog$ScorePM[away_inds],type='p')
points(x=season_gamelog$log_diff_salary[away_inds],y=prd_away,col='blue')






#plotting Portland Trail Blazers' score difference 
#during season 1999 - 2000 in each game 
#against logarithm salary difference for 
#Trail Blazers and opponent in each game

plot(x=season_gamelog$log_diff_salary,
     y=season_gamelog$ScorePM,type='p',
     xlab='logarithmic difference in salary',
     ylab='Score Difference',
     main='Portland Trail Blazers Season 1999 - 2000')
points(x=season_gamelog$log_diff_salary[home_inds],
       y=prd_home,col='red',type='o')
points(x=season_gamelog$log_diff_salary[away_inds],
       y=prd_away,col='blue',type='o')
legend('topright',legend=c('home game','away game'),
       col=c('red','blue'),lty=2,pch=1)


p1<-ggplot(subset(season_gamelog, HomeAway %in% 'Home' ),
           aes(x=log_diff_salary,y=ScorePM))+geom_point()+
           geom_line(aes(log_diff_salary,y=prd_home),colour='red',size=1)+ 
           #geom_smooth(method='lm',colour='red',size=1,se=FALSE) +
           xlab('logarithmic difference in salary for home games')+
           ylab('Score Difference')+
           ggtitle('Portland Trail Blazers Season 1999 - 2000 home games')

p2<-ggplot(subset(season_gamelog, HomeAway %in% 'Away' ),
           aes(x=log_diff_salary,y=ScorePM))+geom_point()+
           geom_line(aes(log_diff_salary,y=prd_away),colour='darkblue',size=1)+ 
           #geom_smooth(method='lm',colour='darkblue',size=1,se=FALSE) +
           xlab('logarithmic difference in salary for away games')+
           ylab('Score Difference')+
           ggtitle('Portland Trail Blazers Season 1999 - 2000 away games')
ggarrange(p1,p2)


