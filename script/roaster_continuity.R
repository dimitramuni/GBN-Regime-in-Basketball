#Visualise Roster Contiuity for the teams over seasons
#Color Coding
#Championship Final    2
#Conference Final      5
#Conference Semis      4
#Conference 1st Round  3
#Did not qualify       8

library(ggplot2)
roster_changes=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Roster_Continuity.csv')
str(roster_changes)

#reference: https://statisticsglobe.com/display-all-x-axis-labels-of-barplot-in-r
chicago<-barplot(roster_changes$CHI~roster_changes$Season,las=3,cex.names=0.6,ylim=c(0.0,1.0),
        main="Roster Continuity for the Chicago Bulls",xlab="NBA Season",ylab="% Continuity in Roster in Comparision to Previous Season",
        col=c(rep(8,3),rep(3,3),4,rep(5,2),2,2,2,4,4,2,2,2,rep(8,6),3,3,4,8,3,3,5,3,4,3,4,8,3,rep(8,4))) 
grid(col = 'gray')
legend('topright',c('Championship Final','Eastern Conference Final','Eastern Conference Semi-Final','Eastern Conference 1st Round','Not Qualified for the play-offs'),
       col = c(2,5,4,3,8),lwd=2,cex = 0.4)


cleveland<-barplot(roster_changes$CLE~roster_changes$Season,las=3,cex.names=0.5,ylim=c(0.0,1.0),
        main="Roster Continuity Cleveland Cavaliers",xlab="NBA Season",ylab="% Continuity in Roster")


detroit<-barplot(roster_changes$DET~roster_changes$Season,las=3,cex.names=0.5,ylim=c(0.0,1.0),
        main="Roster Continuity Detroit Pistons",xlab="NBA Season",ylab="% Continuity in Roster")


from_Season<-which(roster_changes$Season=='1996-97')
to_Season<-which(roster_changes$Season=='2015-16')
lakers<-barplot(roster_changes$LAL[from_Season:to_Season]~roster_changes$Season[from_Season:to_Season],las=3,cex.names=0.5,ylim=c(0.0,1.0),
                main="Roster Continuity Los Angeles Lakers",xlab="NBA Season",ylab="% Continuity in Roster",
                col=c(4,5,4,2,2,2,4,2,8,3,3,2,2,2,4,4,3,8,8,8))
                grid(col='gray')
                legend('topright',c('Championship Final','Western Conference Final','Western Conference Semi-Final','Western Conference 1st Round','Not Qualified for the play-offs'),
                       col = c(2,5,4,3,8),lwd=2,cex = 0.4)


