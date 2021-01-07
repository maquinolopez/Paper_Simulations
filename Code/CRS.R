###################################################
# CRS implementation in R 
# This is the implementation of the CRS model in R
# used for comparisons with Plum 
# doi: 10.1007/0-306-47669-X_9
# Marco A. Aquino-López
###################################################
#rm(list = ls()) 	# clean R environment

#########CRS functions##################
CRS=function(Depths,Pb,sdPb,Density,supp,sdsupp,const_supp=T){
  	# Check supported and takes it off the total
	if (length(supp)>1){
	  if (const_supp != T){
	    stopifnot(length(supp) != length(Pb))
	  }else{
	    supp   = mean(supp)
	    sdsupp = mean(sdsupp) 
	  }
	}
  lendat = length(Depths)
	Pb=Pb-supp
	sdPb=sqrt(sdPb^2+sdsupp^2)
	# check if some data goes below 0 bq/kg and ajust data accordinly
	limAct=which(Pb<=0)

	
	if(length(limAct)==0){
	  limAct=length(Pb)
	}else{
	    if(limAct[1]<=2){#Revisar esta linea
	    return(list(Depths=c(-10),Ages=c(-10),Errors=c(-10),supp=c(-10),label=c(-10)))
	    }
  	  limAct=limAct[1]-1
  	  }
  
	Depths=Depths[seq(1,limAct,1)]
  	Pb=Pb[seq(1,limAct,1)]
  	sdPb=sdPb[seq(1,limAct,1)]
  	Density=Density[seq(1,limAct,1)]
  
	lam=.03114
	Cs_CRS=Pb

    	# Calculates the CRS
  	A_CRS=c(10*Cs_CRS[1]*Density[1])
  	for (i in 2:length(Cs_CRS)){
    		A_CRS=c(A_CRS,A_CRS[length(A_CRS)]+ 10*Density[i]*(Cs_CRS[i]-Cs_CRS[i-1])/log(Cs_CRS[i]/Cs_CRS[i-1]) )
 	 }
	Res_CRS=A_CRS[length(A_CRS)]-A_CRS[-length(A_CRS)]
  	CRS_ages=(1/lam)*log(A_CRS[length(A_CRS)]/Res_CRS)
 	
	# Calculates the standard deviation	
  	SD_A_CRS=100*((sdPb^2)+(.07*(Pb))^2)*Density^2
  	SD_A_CRS=cumsum(rev(SD_A_CRS))
  	SD_A_CRS=rev(sqrt(SD_A_CRS) )
	  SD_CRS=(1/lam)*sqrt( (SD_A_CRS[1]/A_CRS[length(A_CRS)])^2 +
                         (1-2*(Res_CRS/A_CRS[length(A_CRS)]))*(SD_A_CRS[-length(SD_A_CRS)]/Res_CRS)^2 )

  	labe=c() 
  	for (lab in Depths[-length(Depths)]){
    		labe=c(labe,paste("CRS-",lab,sep = ""))
  	}
  	list(Depths=Depths[-length(Depths)],Ages=(1950 - 2020)+CRS_ages,Errors=SD_CRS,supp=c(supp,sdsupp),label=labe)
  	
  	
}



acc_preCRS <- function(id,crv){
  dts   <- read.table(paste0("./Plum_runs/",id,"/",id,".csv"),header = T,sep = ',')
  crs   <- CRS(dts[,2],dts[,4],dts[,5],dts[,3],mean(dts[,7]),mean(dts[,8]))
  if (crs$Depths==-10 ){
    lista <- matrix(c(0,0,0),ncol=3  )
    
    colnames(lista) <- c("Depth", "Accuracy","Precision")
    #print(lista)
    write.csv(lista,paste0("./Plum_runs/",id,"/CRSaccuracy_precision.csv"),row.names = F)
  }else{
    lista <- matrix(c(crs$Depths,abs(crs$Ages - crv(crs$Depths)),crs$Errors),ncol=3  )
    
    colnames(lista) <- c("Depth", "Accuracy","Precision")
    #print(lista)
    write.csv(lista,paste0("./Plum_runs/",id,"/CRSaccuracy_precision.csv"),row.names = F)    
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

########
# 
#Check it works
# 
# dat <- read.csv("~/OneDrive - Maynooth University/Paleo work/Nicole K Sanderson/Plum Vs CRS/Code and data/simulations_Plum-CRS/full core/FC1/FC1.csv")
# 
# 
# CRSres = CRS(dat$Depth..cm.,dat$X210Pb..Bq.kg.,dat$sd.210Pb.,dat$Density.g.cm.3,dat$X226Ra..Bq.kg.,dat$sd.226Ra.)
# 
# 
# plot(dat$Depth..cm.,(1950 - 2020) +dat$CRS.age..yr.,type='l',col='blue')
# lines(CRSres$Depths,   CRSres$Ages)
# 
# plot(dat$Depth..cm.,dat$sd.CRS.,type='l',col='blue')
# lines(CRSres$Depths,CRSres$Errors)




