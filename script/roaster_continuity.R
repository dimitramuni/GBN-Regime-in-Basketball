#Visualise Roster Contiuity for the teams over seasons
roster_changes=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Roster_Continuity.csv')
str(roster_changes)

#reference: https://statisticsglobe.com/display-all-x-axis-labels-of-barplot-in-r
barplot(roster_changes$CHI~roster_changes$Season,las=3,cex.names=0.5,ylim=c(0.0,1.0),
        main="Roster Continuity Chicago Bulls",xlab="NBA Season",ylab="% Continuity in Roster")

barplot(roster_changes$CLE~roster_changes$Season,las=3,cex.names=0.5,ylim=c(0.0,1.0),
        main="Roster Continuity Cleveland Cavaliers",xlab="NBA Season",ylab="% Continuity in Roster")

barplot(roster_changes$DET~roster_changes$Season,las=3,cex.names=0.5,ylim=c(0.0,1.0),
        main="Roster Continuity Detroit Pistons",xlab="NBA Season",ylab="% Continuity in Roster")

#lines(roster_changes$CLE,type='o',col="purple")
#lines(roster_changes$DET,type='o',col="green")
