###################################################
# Title  
# Description
# Marco A. Aquino-López
###################################################
rm(list = ls()) 	# clean R environment

# Load libraries
library(rplum)
source('~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/CRS.R')
tim 	   <- function(x)(.25*x*(x+1))

# Plum run
#Plum("TC-20",coredir="..")
#Y
#2020
#Y

dat 	   <- read.csv("TC-20.csv")
O_CRS      <- CRS(dat$Depth..cm.,dat$X210Pb..Bq.kg.,dat$sd.210Pb.,dat$Density.g.cm.3,dat$X226Ra..Bq.kg.,dat$sd.226Ra.,const_supp=T)
O_CRS$Ages <- O_CRS$Ages+70
O_CRS$Noff <- abs(O_CRS$Ages - tim(O_CRS$Depths))/O_CRS$Errors


####################
CRS 	   <- read.csv("TC-20-CRS.csv")
Plum	   <- read.table("TC-20_31_ages.txt",sep="\t",header=T)
Plum[,-1]  <- Plum[,-1]+70
Plum$error <- (Plum$max-Plum$min)/4
Plum$Noff  <- abs((Plum$mean - tim(Plum$depth))/Plum$error)
CRS$Noff   <- abs((CRS$time..yr.- tim(CRS$Layer..cm.))/CRS$u.time.)


plot(CRS$Layer..cm.,CRS$Noff,pch=19,col="red",ylim=c(0,8),
     main="comparison",xlab="Depth",ylab="Normalized offset")
points(Plum$depth,Plum$Noff,pch=18,col="black" )
points(O_CRS$Depths,O_CRS$Noff,col="blue",pch = 17)
abline(h=c(1,2),col="green")


plot(O_CRS$Depths,O_CRS$Errors,col='blue',pch=18)
points(CRS$Layer..cm.,CRS$u.time.,col="red",pch=17)


plot(O_CRS$Ages-CRS$time..yr.[O_CRS$Depths],pch=18,col='blue')













