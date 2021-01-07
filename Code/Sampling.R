###################################################
# Bayesian Logistic Regression 
# with measurement error in Early Irish
#
# Author:
# Marco A. Aquino-López
###################################################

rm(list = ls()) 	# clean R environment
setwd('~/OwnCloud-NicoleKS/Plum vs CRS/Sampling and percentages/')
# Load libraries
library(rplumMAL)
library(stringr)
#library(ggplot2)
library(data.table)
library(prob)
# Functions

P_sample <- function(p,sim,id,Run=T,crv){ # p is the percentage, sim is the simulation to be used
  dat     <- read.csv(paste0('./',sim))
  nsam    <- as.integer(p*dim(dat)[1])
  cat(nsam," samples will be used ")
  nsample <- sample(dat$Depth , size = nsam )
  print(length(nsample))
  # Revisa si el ultimo elemento esta en la muestra y si no toma un elemento al azar y lo sustitulle
  print(length(nsample))
  if (!(dat[dim(dat)[1],2] %in% nsample)){
    nsample[sample(1:length(nsample), 1)] = dat[dim(dat)[1],2]
  }
  newdatos  <- dat[sort(nsample),1:8]
  newdatos$info <- c(2020,rep(0,nsam-1))
  #revisar si ya esta la simulacion
  fls <- list.files(paste0(getwd(),"/Plum_runs/") )
  if (!isin(fls,id)){
        dir.create(paste0("./Plum_runs/",id) )
        write.csv(newdatos,file = paste0("./Plum_runs/",id,'/',id,'.csv'),row.names = F)
        ranwell = 0
        if(Run==T){
          while(ranwell == 0 ){
            Plum(id,ask = F,suggest = F,BCAD = F)
            print(id)
            fls   <- list.files(paste0(getwd(),"/Plum_runs/",id,'/'))
            p_name <- fls[str_detect(fls, ".out", negate = FALSE)]
            p_name <- p_name[!str_detect(p_name, '_plum.out')]
            p_name <- paste0(getwd(),"/Plum_runs/",id,"/", p_name)
            p_out <- fread(p_name)
            if (sqrt(var(p_out[-1,33]))>.01){## Asume que la columna 33 es donde esta la memoria
                ranwell =1        
            }
            rm(p_out)
            }
        }
        cleanup(id)
        acc_pre(id,crv)
  }
}

sim1 <- function(x){
 (1950 - 2020) +  ( (x^2)/4 + x/2 )
}
sim2 <- function(x){
  (1950 - 2020) +  ( 12*x - .2*x^2 )
}

sim3 <- function(x){
  (1950 - 2020) +  ( 8*x + 25*sin(x/pi) )
}


acc_pre <- function(id,crv){
  fls   <- list.files(paste0("./Plum_runs/",id))
  fls   <- fls[str_detect(fls, "_ages.txt", negate = FALSE)]
  dts   <- read.table(paste0("./Plum_runs/",id,"/",fls),header = T,sep = '\t')
  lista <- matrix(c(dts$depth,abs(dts$mean - crv(dts$depth)),dts$max -dts$min),ncol=3  )
  colnames(lista) <- c("Depth", "Accuracy","precision")
  write.csv(lista,paste0("./Plum_runs/",id,"/accuracy_precision.csv"),row.names = F)

}



cleanup <- function(id){
  fls   <- list.files(paste0(getwd(),"/Plum_runs/",id,'/'))
  fls[str_detect(fls, ".out", negate = FALSE)]
  file.remove(paste0(getwd(),"/Plum_runs/",id,'/',fls[str_detect(fls, ".out", negate = FALSE)]))
}



#### Plot de age-depths models

sim1 <- function(x)( (x^2)/4 + x/2 )
dt1 <- function(x){}
body(dt1) <- D(body(sim1), 'x')
Fi1 = 100
S1 = 10

sim2 <- function(x)( 12*x - .2*x^2 )
dt2 <- function(x){}
body(dt2) <- D(body(sim2), 'x')
Fi2 =  50
S2 = 25

sim3 <- function(x)( 8*x + 25*sin(x/pi) )
dt3 <- function(x){}
body(dt3) <- D(body(sim1), 'x')
Fi3 = 500
S3 = 15

rho <- function(x)(  1.5-.5*cos(x/30*pi) )

P1 <- function(x){S1 + ((Fi1/rho(x)) * dt1(x)) * exp(-.03114*sim1(x))}

P2 <- function(x){S2 + ((Fi2/rho(x)) * dt2(x)) * exp(-.03114*sim2(x))}

P3 <- function(x){S3 + ((Fi3/rho(x)) * dt3(x)) * exp(-.03114*sim3(x))}




legend(0,230,c('proposal 1','proposal 2','proposal 3'),col = c('blue','red','green'))







oldpar <- par()
pdf('~/github/Paper_Simulations/Manuscript/Figures/chronology.pdf',width = 8.5,height = 4.5)

par(mfrow=c(1,2),cex=1.1)

curve(sim1,from = 0,to = 30,col='blue',ylab = 'Age (yr)',xlab='Depth (cm)',main= 'Postulated age-depth models')
curve(sim2,from = 0,to = 30,col='red',add=T)
curve(sim3,from = 0,to = 30,col='green',add=T)
legend(0,250,c('Scenario 1','Scenario 2','Scenario 3'),col = c('blue','red','green'),lty = 1,bty='n')

curve(P2,from = 0,to = 30,col='red',ylab = '210Pb (Bq/kg)',xlab='Depth (cm)',main='Resulting 210Pb profiles')
curve(P3,from = 0,to = 30,col='green',add=T)
curve(P1,from = 0,to = 30,col='blue',add=T)

dev.off()








