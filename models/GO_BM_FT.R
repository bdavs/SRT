library(rootSolve)

#x : in the input time vector.
#n : the length of input vector
#x[n] : n is used as index to refer the last element of time vector.
#tn : time at nth index of time vector
#sumT : total time

#Goel-Okumoto Bisector Method  Maximum Likelyhood Estimate
GO_BM_MLE <- function(x){
n <- length(x)
tn <- x[n]  
sumT <- sum(x)

#Define MLE of parameter 'b'
GO_MLEeq<-function(b){
	((n*tn*exp(-b*tn))/(1-exp(- b*tn)))+sumT - n/b 
}

#Step-1: Determine initial parameter estimate for parameter 'b'

b0 <- n/sumT # calculates initial guess 

#Step-2: Bracket root
#If this does not bracket the function in 100 iterations then nonconvergence
i <- 0 
maxIterations <- 100
leftEndPoint <- b0/2 #sets left to less than initial guess
leftEndPointMLE <- GO_MLEeq(leftEndPoint)
rightEndPoint <- 1.2*b0 #sets right to more than initial guess
rightEndPointMLE <- GO_MLEeq(rightEndPoint)

while(leftEndPointMLE*rightEndPointMLE > 0 & i <= maxIterations){
	#print('In Step 2 while loop of GO_BM_FT.R')
	leftEndPoint <- leftEndPoint/2
	leftEndPointMLE <- GO_MLEeq(leftEndPoint)
	rightEndPoint <- 2*rightEndPoint
	rightEndPointMLE <- GO_MLEeq(rightEndPoint)
	i <- i+1
}

#Step-3: Invoke uniroot or report non convergence to calling environment

if(leftEndPointMLE*rightEndPointMLE > 0 ){
	return('nonconvergence')
} else {

maxiter <<- 20 #makes maxiter global
  bMLEeqn <- function(maxiter){  
    bMLEroot <- tryCatch(
      uniroot(GO_MLEeq, c(leftEndPoint,rightEndPoint), maxiter=maxiter, tol=1e-10, extendInt="yes")$root,
      warning = function(w){ 
      #print(f.lower)
        if(length(grep("_NOT_ converged",w[1]))>0){
          maxiter <<- maxiter+1 
          print(paste("recursive", maxiter,sep='_'))
          soln(maxiter)
        }
      },
      error = function(e){
        print(e)
      })
    return(bMLEroot)
  }
  bMLE <- bMLEeqn(maxiter)
	#bMLE <- uniroot(GO_MLEeq,lower=leftEndPoint,upper=rightEndPoint, tol = 1e-10, maxiter=2000)$root
	#bMLE <- uniroot(GO_MLEeq,c(leftEndPoint,rightEndPoint))$root
}

#print(bMLE)
#Step-4
#MLE of parameter 'a'
	 aMLE <- n/(1-exp(-bMLE*(tn)))
	 
   GO_MLE_dataframe <- data.frame("GO_aMLE"=aMLE,"GO_bMLE"=bMLE)
	 

	 return(GO_MLE_dataframe) 
}

# GO_MVF_er <- function(param,d){
#   n <- length(d$FT)
#   r <-data.frame()
#   cumulr <-data.frame()
#   for(i in 1:n){
#     r[i,1] <- i
#     r[i,2] <- 1/(param$aMLE*(param$N0-(i-1)))
#     cumulr[i,1] <- i
#     cumulr[i,2] <- 0    
#     for(j in 1:length(r[[1]])){
#       cumulr[i,2] <- cumulr[i,2]+r[j,2]
#     }
#   }
#   g <- data.frame(cumulr[2],cumulr[1])
#   names(g) <- c("Time","Failure")
#   g
# }

# GO_MVF_er <- function(param,d){
#   n <- length(d$FT)
#   r <-data.frame()
#   cumulr <-data.frame()
#   for(i in 1:n){
#     r[i,1] <- i
#     r[i,2] <- 1/(param$aMLE*(param$N0-(i-1)))
#     cumulr[i,1] <- i
#     cumulr[i,2] <- 0
#     for(j in 1:length(r[[1]])){
#       cumulr[i,2] <- cumulr[i,2]+r[j,2]
#     }
#   }
#   g <- data.frame(cumulr[2],cumulr[1])
#   names(g) <- c("Time","Failure")
#   g
# }

##Goel-Okumoto Mean Value Function
GO_MVF <- function(param,d){ 
  #param$aMLE <- 100
  n <- length(d$FT) 
  rows <- data.frame() 
  print(param)
  #t_index <- seq(0,9000,1)
  # param$aMLE <- 142.8809
  # param$bMLE <- 3.420379e-05
  t_index <- seq(d$FT[1],d$FT[n],(d$FT[n]-d$FT[1])/100)
  for(i in 1:length(t_index)){
    rows[i,1] <- t_index[i]
    rows[i,2] <- param$GO_aMLE*(1-exp(-1*t_index[i]*param$GO_bMLE))
    rows[i,3] <- "GO"
  }
  rows <- data.frame(rows[1],rows[2],rows[3])
  names(rows) <- c("Time","Failure","Model")
  return(rows)
}
#Goel-Okumoto Mean time to Failure
GO_MTTF <- function(params,d){
  n <- length(d$FT)
  rows <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    rows[i,1] <- i
    rows[i,2] <-(1/(params$GO_aMLE*params$GO_bMLE*(exp(-params$GO_bMLE*d$FT[i]))))
    rows[i,3] <- "GO"
    }
  rows <- data.frame(rows[1],rows[2],rows[3])
  names(rows) <- c("Failure_Number","MTTF","Model")
  return(rows)
}

#Goel Okumoto failure intensity
GO_FI <- function(params,d){
  n <- length(d$FT)
  rows <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    rows[i,1] <- d$FT[i]
    rows[i,2] <- params$GO_aMLE*params$GO_bMLE*(exp(-params$GO_bMLE*d$FT[i]))
    rows[i,3] <- "GO"
    }
  rows <- data.frame(rows[1],rows[2],rows[3])
  names(rows) <- c("Failure_Count","Failure_Rate","Model")
  return(rows)

}


#Goel Okumoto Reliability
GO_R <- function(params,d){
  n <- length(d$FT)
  rows <-data.frame()
  cumulr <-data.frame()
  for(i in 1:n){
    rows[i,1] <- d$FT[i]
    rows[i,2] <- exp(-params$GO_bMLE*d$FT[i])
    rows[i,3] <- "GO"
  }
  rows <- data.frame(rows[1],r[2],r[3])
  names(rows) <- c("Time","Reliability","Model")
  return(rows)
}

#GO log likelihood
GO_lnL <- function(x,params){
  n <- length(x)
  tn <- x[n]
  firstSumTerm <- 0
  for(i in 1:n){
    firstSumTerm = firstSumTerm + (-params$GO_bMLE*x[i])
  }
  lnL <- -(params$GO_aMLE)*(1-exp(-params$GO_bMLE*tn)) + n*(log(params$GO_aMLE)) +n*log(params$GO_bMLE) + firstSumTerm
  return(lnL)
}

#GO_MVF ccontinuous
GO_MVF_cont <- function(params,t){
  return(params$GO_aMLE*(1-exp(-params$GO_bMLE*t)))
}

#GO Reliability change
GO_R_delta <- function(params,cur_time,delta){
  return(exp(-(GO_MVF_cont(params,(cur_time+delta)) -GO_MVF_cont(params,cur_time))))
}

#GO Reliability Max Likelihood equation root finder 
GO_R_MLE_root <- function(params,cur_time,delta, reliability){
  root_equation <- reliability - exp(params$GO_aMLE*(1-exp(-params$GO_bMLE*cur_time)) -params$GO_aMLE*(1-exp(-params$GO_bMLE*(cur_time+delta))))
  return(root_equation)
}

maxiter <- 1000
#Time taken to achieve desired reliability
GO_Target_T <- function(params,cur_time,delta, reliability){

  f <- function(t){
    return(GO_R_MLE_root(params,t,delta, reliability))
  }
    #works in a similar way to the regular MLE function but with reliability as the key parameter
  current_rel <- GO_R_delta(params,cur_time,delta)
  if(current_rel < reliability){
      sol <- tryCatch(
        uniroot(f, c(cur_time,cur_time + 50),extendInt="yes", maxiter=maxiter, tol=1e-10)$root,
        warning = function(w){
        #print(f.lower)
          if(length(grep("_NOT_ converged",w[1]))>0){
            maxiter <<- maxiter+10
            print(paste("recursive", maxiter,sep='_'))
            GO_Target_T(a,b,cur_time,delta, reliability) #calls self recursively until converges or max interations
          }
        },
        error = function(e){
          print(e)
          #return(e)
        })
  }
  else {
    sol <- "Target reliability already achieved"
  }
    return(sol)
  }
#GO growth in reliability 
GO_R_growth <- function(params,cur_time,delta, reliability){  
  
  rows <-data.frame()
  tt_index <- seq(0,cur_time,cur_time/1000)
    for(i in 1:length(tt_index)){   
      rows[i,1] <- tt_index[i]
      temp <- GO_R_delta(params,tt_index[i],delta)
      #print(typeof(temp))
      if(typeof(temp) != typeof("character")){ #if calculated number is a charatcer then return NA
        rows[i,2] <- temp
        rows[i,3] <- "GO"
      }
      else{
        rows[i,2] <- "NA"
        rows[i,3] <- "GO"
      }     
    }
    growth <- data.frame(rows[1],rows[2],rows[3])
    names(growth) <- c("Time","Reliability_Growth","Model")
    #print(g)
    return(growth)
      
}

#NHPP log-likelihood function

#lnl <- -aMLE*(1-exp(-bMLE*tn))+n*log(aMLE)+n*log(bMLE)-bMLE*sum(x)

#Mean Value function

#MVF <- aMLE*(1-exp(-bMLE*x))