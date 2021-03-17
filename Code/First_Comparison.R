###############
##  Comparison between models. 
##  (CRS, CIC, CRS, Plum)
##  
##  
#################
library(Pb210Dating)
source("~/github/Paper_Simulations/Code/CRS.R")
setwd('~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/')

#### User defined parameters ####

wd      <- "~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/"
core    <- list.files(wd)
core    <- core[grepl("Sim01",substr(core,0,5) )]
cores   <- vector()
for (k in seq(20,95,5)){
  tmp1  <- core[grepl(as.character(k),substr(core,7,8) )]
  cores <- c(cores,sample(tmp1,20)) 
}

# cores   <- core[-c(1:202)]

# write.csv(cores,"~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/cores_E-CRS_bigest.csv")
# cores  <- read.csv("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/cores_E-CRS_bigest.csv")[,2]
# cores  <- read.csv("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/cores_E-CRS_big.csv")[,2]
# cores  <- read.csv("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/cores_E-CRS.csv")[,2]

#### preliminary actions ####
profiles    <- paste0(wd,cores,"/",cores, ".csv")
simulations <- paste0(wd,cores,"/",cores,'_E-CRS.csv')
results     <- paste0(wd,cores,"/",'E-CRS.csv')
constants   <- "~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/constants.csv"
col.names   <- c("sample.code", "layer.bot", "layer.bot.u", "mass.dry", "mass.dry.u",
                 "pb210", "pb210.u", "ra226", "ra226.u", "cs137", "cs137.u")

# theoretical age-models
x  <- 0:30
f1 <- x**2/4 + x/2
f2 <- 12*x - 0.2*x**2
f3 <- 8*x + 25*sin(x/pi)
#which function to use
f <- f1

# creates files with age model and offsets and Normalized offsets
for (i in 1:length(cores)){
  #### sim1 ####
  o1 <- read.csv(profiles[i])
  ## transform and write new data frame to suit the package structure
  # As I work with masses, I simulate the equivalent core surface
  diameter <- sqrt(4 * 1 / pi)
  mass     <- o1$Density
  aux.1    <- data.frame(sample.code = o1$ID,
                         layer.bot <- o1$Depth, layer.bot.u = 0.1,
                         mass.dry	= mass, mass.dry.u = 0.0001,
                         pb210 = o1$X210Pb, pb210.u = o1$X210Pb_sd,
                         ra226 = o1$X226Ra, ra226.u = o1$X226Ra_sd)
  write.csv(aux.1, simulations[i], row.names = FALSE, quote = FALSE)
  
  # I have created a constants file, the same for all
  s1 <- ReadData(NameConstants = constants, NameProfiles = simulations[i],
                 NameValidation = NA, Proxy = FALSE)
  
  # complete profile (always needed if not all sections are considered)
  # SURFACE CONCENTRATION IS NEEDED, TO AVOID EXTRAPOLATION
  s1.c  <- CompleteProfile(s1)
  
  # calculate bottom layer for dating
  s1.e  <- Equilibrium(s1.c, Interactive = FALSE)
  
  # CF dating
  s1.CF <- Pb210CF(s1.e, Runs = 1e5)
  
  # values of interest for Marco
  Age    <- head(s1.CF$Val$TimeLayer,-1)
  Depth  <- s1.CF$Val$DepthLayerEx[1:length(Age)]
  SD     <- s1.CF$Unc$TimeLayer[1:length(Age)]
  #s1.CF$Unc$DepthLayerEx
  offset <- abs(Age - f1[Depth+1])
  Noffset<- offset/SD
  E_CRS <- matrix(c(Depth,Age,SD,offset,Noffset),ncol=5)
  colnames(E_CRS) <- c("depths","age",'sd','offset','N_offset')
  write.csv(E_CRS,results[i])
}


kore= 70 #286 #300 #298 # 169 of the big file.

#cores para paper "Sim03_95_091", "Sim03_90_087"
#########
E_CRS = read.csv(results[kore],header = T)
dts   <- read.table(paste0(wd,cores[kore],"/",cores[kore],".csv"),header = T,sep = ',')
crs   <- CRS(dts[,2],dts[,4],dts[,5],dts[,3],mean(dts[,7]),mean(dts[,8]))
crs$Ages <- crs$Ages +  70

# par(new = TRUE)
# plot(crs$Depths,abs(crs$Ages-f3[crs$Depths+1])/crs$Errors,pch=16,xlab = "",ylab = "",col=rgb(1,0,0,.5),xaxt = "n", yaxt = "n",xlim = c(0,30),ylim=c(0,22))
# axis(side = 4,at= seq(-10,62,5))
# mtext("sd", side=4, line=1.8, col=rgb(0,1,0,.3))
# points(E_CRS$depths,E_CRS$N_offset,pch=16,col=rgb(0,1,0,.5))
# points(plum$depth,c(4*abs(f3-plum$mean)/(plum$max-plum$min) ),pch=16,col=rgb(0,0,1,.3) )
# abline(h=c(1,2),col='blue')
kore=135
cores[kore]
#########

pb = read.csv(paste0("~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/Plum_runs/",cores[kore],'/',cores[kore],'.csv'))

header <- c("depth_min","depth_max","density","Pb210ex","Pb210ex_er","Cs137","Cs137_er","Am241","Am241_er")
newcore <- c(pb$Depth-pb$Thickness,pb$Depth,pb$Density,pb$X210Pb-pb$X226Ra,pb$X210Pb_sd+pb$X226Ra_sd,rep(NA,length(pb$ID)),rep(NA,length(pb$ID)),rep(NA,length(pb$ID)),rep(NA,length(pb$ID)) )
newcore <- matrix(newcore,ncol = 9)
colnames(newcore) <- header
write.table(newcore,file = paste0(getwd(),"/Cores/First_core/First_core.txt"),sep = '\t',row.names = FALSE,col.names = TRUE)

serac::serac("First_core",coring_yr=2020,model=c("CIC","CRS","CFCS"),plotphoto = F,plotpdf = F,plot_Pb = F,plot_Am = F)

CFCS  <- read.table(paste0(getwd(),"/Cores/First_core/First_core_CFCS_interpolation.txt"),header = T)
CRS_CIS <- read.table(paste0(getwd(),"/Cores/First_core/First_core_CRS.txt"),header = T)
CIC   <- read.table(paste0(getwd(),"/Cores/First_core/First_core_CIC_interpolation.txt"),header = T)
###################
dev.off()
par(mar=c(4, 4, 2.5, 3.5) + 0.1)

plot(E_CRS$depths,E_CRS$age,type = 'l',main="",
     col=rgb(0,1,.6,.3),xlab = "Depth (cm)",ylab = "Age (yr)", yaxt = "n",ylim = c(-1,230),xlim = c(0,30),lwd=2)
axis(side = 2,at= seq(0,300,50))
lines(x,f1,col='green',lwd=2)

## Expert CRS
d <- E_CRS$depths
age <- E_CRS$age
er <- 2*E_CRS$sd
pol = cbind( c(d, rev(d) ), c(age-er, rev(age+er) ) )
lines(d,age,col=rgb(0,1,.6,.5))
polygon(pol, col=rgb(0,1,.6,.5), border=rgb(0,1,.6,.5))

## CI_CRS
d <- crs$Depth
age <- crs$Ages
er <- 2*crs$Errors
lines(crs$Depths,crs$Ages,col=rgb(1,0,0,.5),lwd=2)
pol = cbind( c(d, rev(d) ), c(age-er, rev(age+er) ) )
polygon(pol, col=rgb(1,0,0,.5), border=rgb(1,0,0,.5))

## CFCS
d <- CFCS$depth_avg_mm
age <- 2020-CFCS$BestAD
lines(d,age,col=rgb(1,1,0,.5),lwd=2)
pol = cbind( c(d, rev(d) ), c(2020-CFCS$MinAD, rev(2020-CFCS$MaxAD) ) )
polygon(pol, col=rgb(1,1,0,.5), border=rgb(1,1,0,.5))

## CIC
d <- CIC$depth_avg_mm
age <- 2020-CIC$BestAD
lines(d,age,col=rgb(1,0,1,.5),lwd=2)
pol = cbind( c(d, rev(d) ), c(2020-CIC$MinAD, rev(2020-CIC$MaxAD) ) )
polygon(pol, col=rgb(1,0,1,.5), border=rgb(1,0,1,.5))

## Regular CRS
d <- CRS_CIS$depth_avg_mm
age <- 2020-CRS_CIS$BestAD
lines(d,age,col=rgb(.5,.5,1,.5),lwd=2)
pol = cbind( c(d, rev(d) ), c(2020-CRS_CIS$MinAD, rev(2020-CRS_CIS$MaxAD) ) )
polygon(pol, col=rgb(.5,.5,1,.5), border=rgb(.5,.5,1,.5))


lines(x,f1,col='green',lwd=2)

cores[kore]


legend(0,240,legend = c("CI-CRS","R-CRS","True"),col=c(rgb(1,0,0,.3),rgb(0,1,.6,.5),"green"),lty = c(1,1,1),bty = "n",pch=c(16,16,16,NA) )



plum   <- read.table(paste0(wd,cores[kore],"/",cores[kore],"_31_ages.txt"),header = T,sep = '\t')
plum[,-1]<- plum[,-1]+70
plum
d <- plum$depth
lines(plum$depth,plum$mean,lwd=1.3,col=rgb(0,0,1,.3))
pol = cbind( c(d, rev(d) ), c(plum$min, rev(plum$max) ) )
polygon(pol, col=rgb(0,0,1,.3), border=rgb(0,0,1,.3))
############

