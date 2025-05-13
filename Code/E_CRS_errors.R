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
# library(multipanelfigure)
library(quantreg)
library("devtools")
library(roxygen2)
# roxygenize()
# document()
# setwd("./Code/")
#uninstall("Pb210Dating")
# install("./Pb210Dating/",dependencies = T) # Ask to author of the package code to 'Joan Albert Sánchez Cabeza' <jasanchez@cmarl.unam.mx>
library(Pb210Dating)
source('./CRS_function.R')
#load_all ("Pb210Dating")
#?Pb210CF
#################################
#### CF dating ####

#### User defined parameters ####
 
wd      <- "./Plum_runs/"
core    <- list.files(wd)
# core    <- core[grepl("Sim0",substr(core,0,5) )]
# cores   <- vector()#core #vector()
# for (k in seq(20,95,5)){
#   tmp1  <- core[grepl(as.character(k),substr(core,7,8) )]
#   cores <- c(cores,sample(tmp1,20))
# }
cores <- core
print(cores)
# cores   <- core[-c(1:202)]
#### preliminary actions ####
profiles    <- paste0(wd,cores,"/",cores, ".csv")
simulations <- paste0(wd,cores,"/",cores,'_E-CRS.csv')
results     <- paste0(wd,cores,"/",'E-CRS.csv')
constants   <- "./constants.csv"
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
  if (file.exists(profiles[i])) {
    if (! file.exists(simulations[i])){
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
        info_pct <- sub(".*Sim\\d{2}_(\\d{2}).*", "\\1", profiles[i])
        E_CRS <- matrix(c(Depth,Age,SD,offset,Noffset,rep(as.numeric(info_pct),length(SD))),ncol=6)
        colnames(E_CRS) <- c("depths","age",'sd','offset','N_offset',"info_pct")
        write.csv(E_CRS,results[i])

        if(dim(E_CRS)[1]>2){
          modelMeans = rbind(modelMeans, c(sub(".*(Sim\\d{2}_\\d{2}).*", "\\1", profiles[i]),colMeans(E_CRS[-1,],na.rm = T)  ) )  
        }else{
          modelMeans = rbind(modelMeans, c(sub(".*(Sim\\d{2}_\\d{2}).*", "\\1", profiles[i]),E_CRS[-1,]  ) )
        }
        
      
      }else{
        print(substr(profiles[i],68,79)); cont.malos = cont.malos + 1
        write.table(matrix(rep(0,6),ncol = 6),results[i],col.names = T,row.names = F,append = F)
      }
    }else{
        E_CRS = read.csv(results[i])
        E_CRS <- cbind(E_CRS, info_pct <- as.numeric(sub(".*Sim\\d{2}_(\\d{2}).*", "\\1", profiles[i])) )
        colnames(E_CRS)[ncol(E_CRS)] <- "info_pct"
        print(E_CRS)

        if(dim(E_CRS)[1]>2){
          modelMeans = rbind(modelMeans, c(sub(".*(Sim\\d{2}_\\d{2}).*", "\\1", profiles[i]),colMeans(E_CRS[-1,],na.rm = T)  ) )  
        }else{
          modelMeans = rbind(modelMeans, c(sub(".*(Sim\\d{2}_\\d{2}).*", "\\1", profiles[i]),E_CRS[-1,]  ) )
        } 
    }
  }
}
  
print(modelMeans)
write.table(modelMeans,paste0("./","E_CRS.txt"),col.names = T,row.names = F,append = F)