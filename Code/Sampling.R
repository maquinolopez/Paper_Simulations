###################################################
# Sampling density 210Pb  
# 
# Marco A. Aquino-López
###################################################
setwd('~/OneDrive - Maynooth University/Paleo work/Nicole K Sanderson/Sampling and percentages/')
source("Sampling_function.R")


# Simulation 1
accuracy  <- c()
precision <- c()
for (p in seq(.95,.95,by = .05)){
  for (i in 1:100){
    corename <- paste("Sim01",100*p,formatC(i,width = 3,flag="0"),sep = '_')
    psample=P_sample(p, 'FC1.csv', corename,Run = T,crv = sim1)
    accuracy <- rbind(accuracy,c(corename,psample$accu) )
    precision<- rbind(precision,c(corename,psample$prec))
  }
}


# Simulation 2
accuracy  <- c()
precision <- c()
for (p in seq(.95,.95,by = .05)){
  for (i in 1:100){
    corename <- paste("Sim02",100*p,formatC(i,width = 3,flag="0"),sep = '_')
    psample=P_sample(p, 'FC2.csv', corename,Run = T,crv = sim1)
    accuracy <- rbind(accuracy,c(corename,psample$accu) )
    precision<- rbind(precision,c(corename,psample$prec))
  }
}


# Simulation 3
accuracy  <- c()
precision <- c()
for (p in seq(.95,.95,by = .05)){
  for (i in 1:100){
    corename <- paste("Sim03",100*p,formatC(i,width = 3,flag="0"),sep = '_')
    psample=P_sample(p, 'FC3.csv', corename,Run = T,crv = sim1)
    accuracy <- rbind(accuracy,c(corename,psample$accu) )
    precision<- rbind(precision,c(corename,psample$prec))
  }
}

