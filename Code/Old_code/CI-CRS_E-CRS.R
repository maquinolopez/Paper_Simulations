###############################
# Authors:
# Marco A. Aquino-López 
# JASC
# Code:
# Runs the Expert-CRS and plots results
###############################
#Load libraries
rm(list = ls()) 	# clean R environment
library(stringr)
library(ggplot2)
library(magrittr)
library(multipanelfigure)
library(quantreg)
library("devtools")
library(roxygen2)
roxygenize()
document()
setwd("./Code/")
#uninstall("Pb210Dating")
install("./Pb210Dating/") # Ask to author of the package code to 'Joan Albert Sánchez Cabeza' <jasanchez@cmarl.unam.mx>
library(Pb210Dating)
source('./CRS_function.R')
#load_all ("Pb210Dating")
#?Pb210CF
#################################
#### CF dating ####

#### User defined parameters ####

wd      <- "/Plum_runs/"
core    <- list.files(wd)
core    <- core[grepl("Sim01",substr(core,0,5) )]
cores   <- vector()#core #vector()
for (k in seq(20,95,5)){
  tmp1  <- core[grepl(as.character(k),substr(core,7,8) )]
  cores <- c(cores,sample
write.table(modelMeans,paste0("./","E_CRS.txt"),col.names = T,row.names = F,append = F)
cores   <- core[-c(1:202)]


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

modelMeans = NULL
cont.malos = 0
# creates files with age model and offsets and Normalized offsets
for (i in 1:length(cores)){
  if (substr(profiles[i],71,72) == "01"){
    f = f1
  }else{ 
    if(substr(profiles[i],71,72) == "02"){
      f = f2
    }else{
      f = f3
    } }
  
  #### sim1 ####
  o1 <- read.csv(profiles[i])
  colnames(o1) <- c("ID", "Depth",   "Density",    "X210Pb", "X210Pb_sd", "Thickness",   "X226Ra", "X226Ra_sd", "info")
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
  s1.CF <- try(Pb210CF(s1.e, Runs = 1e5) )
  if (typeof(s1.CF) == "list" ){
    # values of interest for Marco
    Age    <- head(s1.CF$Val$TimeLayer,-1)
    Depth  <- s1.CF$Val$DepthLayerEx[1:length(Age)]
    SD     <- s1.CF$Unc$TimeLayer[1:length(Age)]
    #s1.CF$Unc$DepthLayerEx
    offset <- abs(Age - f[Depth+1])
    Noffset<- offset/SD
    E_CRS <- matrix(c(Depth,Age,SD,offset,Noffset),ncol=5)
    colnames(E_CRS) <- c("depths","age",'sd','offset','N_offset')
    write.csv(E_CRS,results[i])
    
    if(dim(E_CRS)[1]>2){
      modelMeans = rbind(modelMeans, c(substr(profiles[i],68,79),colMeans(E_CRS[-1,],na.rm = T)  ) )  
    }else{
      modelMeans = rbind(modelMeans, c(substr(profiles[i],68,79),E_CRS[-1,]  ) )
    }
    
  
  }else{
    print(substr(profiles[i],68,79)); cont.malos = cont.malos + 1
    write.table(matrix(rep(0,6),ncol = 6),results[i],col.names = T,row.names = F,append = F)
  }
  }
  

write.table(modelMeans,paste0("./","E_CRS.txt"),col.names = T,row.names = F,append = F)
#######################################################
#######################################################
#######################################################

plot(-10,-10,xlim=c(0,30),ylim=c(0,90),xlab = "Depth (cm)", ylab="Normalized offset" )
colors=head(rep(rainbow(19,end= .9,alpha = .25),each=5),-5)
for (i in 1:length(cores) ){
  E_CRS = read.csv(results[i],header = T)
  points(E_CRS$depths,E_CRS$N_offset,pch=16,col=colors[i])
}
abline(h=c(1,2),col="blue")

#######################################################
#######################################################
#######################################################

kore= 86 #90 #286 #300 #298 # 169 of the big file.

#cores para paper "Sim03_95_091", "Sim03_90_087"
#########
E_CRS = read.csv(results[kore],header = T)
dts   <- read.table(paste0(wd,cores[kore],"/",cores[kore],".csv"),header = T,sep = ',')
crs   <- CRS(dts[,2],dts[,4],dts[,5],dts[,3],mean(dts[,7]),mean(dts[,8]))
crs$Ages <- crs$Ages +  70
plum   <- read.table(paste0(wd,cores[kore],"/",cores[kore],"_31_ages.txt"),header = T,sep = '\t')
plum[,-1]<- plum[,-1]+70

par(mar=c(4, 4, 2.5, 3.5) + 0.1)

plot(E_CRS$depths,E_CRS$age,type = 'l',main="",
     col=rgb(0,1,.6,.3),xlab = "Depth (cm)",ylab = "Age (yr)", yaxt = "n",ylim = c(-50,330),xlim = c(0,30),lwd=2)
axis(side = 2,at= seq(0,300,50))
mtext("sd", side=4, line=1.8, col="black")

d <- plum$depth
lines(plum$depth,plum$mean,lwd=1.3,col=rgb(0,0,1,.3))
pol = cbind( c(d, rev(d) ), c(plum$min, rev(plum$max) ) )
polygon(pol, col=rgb(0,0,1,.3), border=rgb(0,0,1,.3))

d <- crs$Depth
age <- crs$Ages
er <- 2*crs$Errors
lines(crs$Depths,crs$Ages,col=rgb(1,0,0,.5),lwd=2)
pol = cbind( c(d, rev(d) ), c(age-er, rev(age+er) ) )
polygon(pol, col=rgb(1,0,0,.5), border=rgb(1,0,0,.5))


d <- E_CRS$depths
age <- E_CRS$age
er <- 2*E_CRS$sd
pol = cbind( c(d, rev(d) ), c(age-er, rev(age+er) ) )
lines(d,age,col=rgb(0,1,.6,.5))
polygon(pol, col=rgb(0,1,.6,.5), border=rgb(0,1,.6,.5))

lines(x,f3,col='cyan',lwd=2)

legend(0,300,legend = c('Plum',"CI-CRS","R-CRS","True"),col=c(rgb(0,0,1,.3),rgb(1,0,0,.3),rgb(0,1,.6,.5),"cyan"),lty = c(1,1,1),bty = "n",pch=c(16,16,16,NA) )


par(new = TRUE)
plot(crs$Depths,abs(crs$Ages-f3[crs$Depths+1])/crs$Errors,pch=16,xlab = "",ylab = "",col=rgb(1,0,0,.5),xaxt = "n", yaxt = "n",xlim = c(0,30),ylim=c(0,22))
axis(side = 4,at= seq(-10,62,5))
mtext("sd", side=4, line=1.8, col=rgb(0,1,0,.3))
points(E_CRS$depths,E_CRS$N_offset,pch=16,col=rgb(0,1,0,.5))
points(plum$depth,c(4*abs(f3-plum$mean)/(plum$max-plum$min) ),pch=16,col=rgb(0,0,1,.3) )
abline(h=c(1,2),col='blue')

cores[kore]
#########



plot(E_CRS$depths,E_CRS$offset,type = 'l',main="",
    col=rgb(0,1,.6,.8),xlab = "Depth (cm)",ylab = "Age (yr)",ylim=c(0,50),
    xlim = c(0,30),lwd=2)

lines(crs$Depths,abs(crs$Ages-f3[crs$Depths+1]),col=rgb(1,0,0,.5))
lines(plum$depth,abs(f3-plum$mean),col=rgb(0,0,1,.5))





