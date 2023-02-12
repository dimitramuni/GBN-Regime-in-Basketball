## Mergining Regimes identified by nonzero delts in the data set
## Based on work  by Bendtsen M. (2017), https://link.springer.com/article/10.1007/s10618-017-0510-5
## See Appendix A.2
rm(list=ls())
library(bnlearn)
source("~/Desktop/GBN-Regime-in-Basketball/script/Regime Combination/Collapse.R")
require(textshape)
require(bnlearn)
require(Rlab)
require(dplyr)
require(numbers)

chicago_scores=read.csv('~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls/Processed_Chicago_Bulls.csv')
dataset=chicago_scores[,-c(1)]
dataset<-as.data.frame(unclass(dataset),stringsAsFactors = TRUE)

nonzero_delta_from_Identify<-c(390,930,1695,2689)
n=dim(dataset)[1]
d=numeric(length = length(nonzero_delta_from_Identify))
d[1]=nonzero_delta_from_Identify[1]
d[2]=nonzero_delta_from_Identify[2]
d[3]=nonzero_delta_from_Identify[3]
d[4]=nonzero_delta_from_Identify[4]

#Merge Function #L1
#Merge_Regimes<-function(dataset,nonzero_delta_from_Identify){

#splitting D into subsets #L2 and #L3
split_subset<-split_index(dataset,nonzero_delta_from_Identify)
D1=split_subset[[1]]
D2=split_subset[[2]]
D3=split_subset[[3]]
D4=split_subset[[4]]
D5=split_subset[[5]]
#first regime has 2 as the child regime and last regime does not have any child regime
#assigning column names to vector positions of C
#names(C)<-C_ColumnName
#container for all possible structuers #L7
no_of_structures=length(nonzero_delta_from_Identify)+1
H=vector(mode='list',length = no_of_structures)
C=vector(mode='list',length = no_of_structures)
H[[1]]=list(R1=D1,R2=D2,R3=D3,R4=D4,R5=D5)
C[[1]]=list(R1='R2',R2='R3',R3='R4',R5=NULL)

H[[2]]=list(R1=rbind(D1,D3),R2=D2,R3=D4,R4=D5)
C[[2]]=list(R1=c('R2','R3'),R2='R1',R3='R4',R4=NULL)

H[[3]]=list(R1=rbind(D1,D3,D5),R2=D2,R3=D4)
C[[3]]=list(R1=c('R2','R3'),R2='R1',R3='R1')

H[[4]]=list(R1=rbind(D1,D3),R2=rbind(D2,D4),R3=D5)
C[[4]]=list(R1='R2', R2=c('R1','R3'), R3=NULL)


H[[5]]=list(R1=rbind(D1,D3),R2=rbind(D2,D5),R3=D4)
C[[5]]=list(R1=c('R2','R3'), R2='R1', R3='R2')

H[[6]]=list(R1=rbind(D1,D3,D5),R2=rbind(D2,D4))
C[[6]]=list(R1='R2', R2='R1')

H[[7]]=list(R1=rbind(D1,D4),R2=D2,R3=D3,R4=D5)
C[[7]]=list(R1=c('R2','R4'), R2='R3', R3='R1',R4=NULL)

H[[8]]=list(R1=rbind(D1,D4),R2=rbind(D2,D5),R3=D3)
C[[8]]=list(R1='R2', R2='R3', R3='R1')

H[[9]]=list(R1=rbind(D1,D4),R2=D2,R3=rbind(D3,D5))
C[[9]]=list(R1=c('R2','R3'), R2='R3', R3='R1')

H[[10]]=list(R1=rbind(D1,D5),R2=D2,R3=D3,R4=D4)
C[[10]]=list(R1='R2', R2='R3', R3='R4',R4='R1')

H[[11]]=list(R1=rbind(D1,D5),R2=rbind(D2,D4),R3=D3)
C[[11]]=list(R1='R2', R2='R3', R3='R1')

H[[12]]=list(R1=D1,R2=rbind(D2,D4),R3=D3,R4=D5)
C[[12]]=list(R1='R2', R2=c('R3','R4'), R3='R2',R4=NULL)

H[[13]]=list(R1=rbind(D1,D5),R2=rbind(D2,D4),R3=D3)
C[[13]]=list(R1='R2', R2=c('R1','R3'), R3='R2')

H[[14]]=list(R1=D1, R2=rbind(D2,D5),R3=D3,R4=D4)
C[[14]]=list(R1='R2', R2='R3', R3='R4',R4='R2')

H[[15]]=list(R1=D1,R2=D2,R3=rbind(D3,D5),R4=D4)
C[[15]]=list(R1='R2', R2='R3', R3='R4',R4='R3')



#number of hypotheses to evalute can be found using bell number
k<-length(nonzero_delta_from_Identify)
no_of_structures=numbers::bell(k)



#Marginal Likelihood of Hypothesis
marglik_h=c()
#iterating over each hypothesis
for(i in 1:length(H)){
  
  #iterating over each BN within a hypothesis
  marg_bn=c()
  for (j in 1:length(H[[i]])) {
    
    bn=hc(H[[i]][[j]],score = 'bde') 
    marg_bn=c(marg_bn,bnlearn::score(bn,H[[i]][[j]],type = "bde"))
  }
  marglik_h=c(marglik_h,sum(marg_bn))
}

C[[which.max(marglik_h)]]  

top_5_hypotheses=order(marglik_h,decreasing=TRUE)[1:5]

##############Synthetic Dataset Hypothesis 1


no_of_test_dataset<-100
Synth_D_H1<-vector(mode='list',length =no_of_test_dataset)
Synth_Whole_H1<-vector(mode='list',length =no_of_test_dataset)
for (i in 1:no_of_test_dataset) {
  
  for (j in 1:length(H[[top_5_hypotheses[1]]])) {
    
    Synth_D_H1[[i]][[j]]<-slice_sample(H[[top_5_hypotheses[1]]][[j]],n=dim(H[[top_5_hypotheses[1]]][[j]])[1],replace = TRUE)
    
  }
  Synth_Whole_H1[[i]]<-do.call('rbind',Synth_D_H1[[i]])
  
}

source('~/Desktop/GBN-Regime-in-Basketball/script/Regime Identification/Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data = Synth_Whole_H1[[2]],k=4,n_iteration =10000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)


#capture.output(Synth_Whole_H1,file='~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls/Synthetic/H1.csv')
#rm(list=c('Synth_D_H1','Synth_Whole_H1'))

##############Synthetic Dataset Hypothesis 2


no_of_test_dataset<-100
Synth_D_H2<-vector(mode='list',length =no_of_test_dataset)
Synth_Whole_H2<-vector(mode='list',length =no_of_test_dataset)
for (i in 1:no_of_test_dataset) {
  
  for (j in 1:length(H[[top_5_hypotheses[2]]])) {
    
    Synth_D_H2[[i]][[j]]<-slice_sample(H[[top_5_hypotheses[2]]][[j]],n=dim(H[[top_5_hypotheses[2]]][[j]])[1],replace = TRUE)
    
  }
  Synth_Whole_H2[[i]]<-do.call('rbind',Synth_D_H2[[i]])
  
}
capture.output(Synth_Whole_H2,file='~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls/Synthetic/H2.csv')
#rm(list=c('Synth_D_H2','Synth_Whole_H2'))

##############Synthetic Dataset Hypothesis 3


no_of_test_dataset<-100
Synth_D_H3<-vector(mode='list',length =no_of_test_dataset)
Synth_Whole_H3<-vector(mode='list',length =no_of_test_dataset)
for (i in 1:no_of_test_dataset) {
  
  for (j in 1:length(H[[top_5_hypotheses[3]]])) {
    
    Synth_D_H3[[i]][[j]]<-slice_sample(H[[top_5_hypotheses[3]]][[j]],n=dim(H[[top_5_hypotheses[3]]][[j]])[1],replace = TRUE)
    
  }
  Synth_Whole_H3[[i]]<-do.call('rbind',Synth_D_H3[[i]])
  
}


capture.output(Synth_Whole_H3,file='~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls/Synthetic/H3.csv')
rm(list=c('Synth_D_H3','Synth_Whole_H3'))
##############Synthetic Dataset Hypothesis 4


no_of_test_dataset<-100
Synth_D_H4<-vector(mode='list',length =no_of_test_dataset)
Synth_Whole_H4<-vector(mode='list',length =no_of_test_dataset)
for (i in 1:no_of_test_dataset) {
  
  for (j in 1:length(H[[top_5_hypotheses[4]]])) {
    
    Synth_D_H4[[i]][[j]]<-slice_sample(H[[top_5_hypotheses[4]]][[j]],n=dim(H[[top_5_hypotheses[4]]][[j]])[1],replace = TRUE)
    
  }
  Synth_Whole_H4[[i]]<-do.call('rbind',Synth_D_H4[[i]])
  
}


capture.output(Synth_Whole_H4,file='~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls/Synthetic/H4.csv')
rm(list=c('Synth_D_H4','Synth_Whole_H4'))
##############Synthetic Dataset Hypothesis 5


no_of_test_dataset<-100
Synth_D_H5<-vector(mode='list',length =no_of_test_dataset)
Synth_Whole_H5<-vector(mode='list',length =no_of_test_dataset)
for (i in 1:no_of_test_dataset) {
  
  for (j in 1:length(H[[top_5_hypotheses[5]]])) {
    
    Synth_D_H5[[i]][[j]]<-slice_sample(H[[top_5_hypotheses[5]]][[j]],n=dim(H[[top_5_hypotheses[5]]][[j]])[1],replace = TRUE)
    
  }
  Synth_Whole_H5[[i]]<-do.call('rbind',Synth_D_H5[[i]])
  
}

capture.output(Synth_Whole_H5,file='~/Desktop/GBN-Regime-in-Basketball/data/Chicago_Bulls/Synthetic/H5.csv')
rm(list=c('Synth_D_H5','Synth_Whole_H5'))

source('~/Desktop/GBN-Regime-in-Basketball/script/Regime Identification/Identify_hc.R')
start_time<-Sys.time()
Identify_Positions_hc(data =Synth_Whole_H1[[20]] ,k=4,n_iteration = 1000)
end_time<-Sys.time()
cat('time taken: ',end_time-start_time)



