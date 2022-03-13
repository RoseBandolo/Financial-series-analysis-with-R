FTplotSmoothRfunction <-
function(dateindexpricereturndata,  price_intv=1, return_intv=2, cumReturn_intv=20, index_intv=100, hist_max=1.0, scalingConstant=2.0, span_Price=0.2, span_Vlty, volatility_max=25, volatility_intv=5, qqmin=-2, qqmax=2,Title_plt1="Price", Title_plt1sm="Price Smooth",Title_plt2="Return", Title_plt2cr="CumReturn", Title_plt3="NeedleReturn", Title_plt4="Volatility", Title_plt5="Histogram", Title_plt6="QQplot") {
#
#FTplotsRfunction needs: library(graphics), library(ggplot2), library(scales), library(grid), library(cowplot), library(openxlsx), library (tictoc), library(qqplotr), library(zoo), -  check(28Sept Version)
#
tic()
cat("","\n")
#
# This R function plots times series of prices and returns (usually daily, from an excel file) and also gives the line plot returns, 
# needle plot returns, cumulative returns, volatility and smooth volatility plots.  The xlsx file needs minimally to contain two columns
#  named (Date and Price) and the function will first calculate the associatd serReturn and index. No missing values allowed.  
# Date needs to have or be converted in the code to class 'Date' ** and specific bits of optional code are given for various date formats.  
# New codes may be required depending on form of date in data file.  Previous bits of code need to be skipped by # key entries. Except for dates, 
# other variables need to be class numeric.Calculations for early runs are included to aid choice of good plotting
#
#  The input objects of FTplotsRfunction are the following: 
#  dateindexpricereturndata: an xlsx file with minimally Date and Price as labels - change headings if necessary
#  spanL: the smoothing paramter in the loess R-function
#  preliminary plotting control constants and titles of plots
cat("","\n")
#
# The function saves to files: plt_ts1.jeg, plt_ts1a.jpeg, plt_ts2.jpeg, plt_ts3.jeg, plt_ts4.jpeg, plt_ts5.jpeg
# 
cat("Read dateindexpricereturndata file into index-ordered dataframe  df.FT xlsx file using openxls package","\n")
cat("","\n")
df.FT <- read.xlsx(dateindexpricereturndata, sheet=1) # Review class of data frame variables
cat("df.FT data frame from original xlsx data file - not usually with date as date class - review file","\n")
str(df.FT)
#
cat("","\n")
#
#
#Several date conversion codes 1,2,...,5, depending date format of original data 
#
cat("1. For Dates of the xlsx excel numerical form, conversion code with origin=1899-12-30 available here  ","\n")  
df.FT$Date <- as.Date(df.FT$Date, origin="1899-12-30")  #  *numerical excel dates*, mandiv
#
#cat("2. For Dates of the form (month day, year) in xlsx file, conversion code available here ","\n")
#df.FT$Date <- as.Date(c(df.FT$Date) , format="%B %d, %Y")  # - works on e.g. : **FTSE100d23m9y0419.xls &  
# FTSE100_5Jan2005_30Dec2011.xlsx**
#
#cat("3. For Dates of the form (year-month-day) in xlsx file, conversion code available here ","\n")
#df.FT$Date <- as.Date(c(df.FT$Date)) # works e.g. on chr("1942-05-16")      **GSEC5July13-4July18.xlsx""
#
#cat("4. For Dates of numeric form from xlsx after read.xls, conversion code here","\n") 
##df.FT$serDate <- as.numeric((as.character(df.FT$Date))) # df.FT$serDate is numeric class
#
#cat("5. For dates from excel needing conversion to Date  form after read.xls code here","\n") 
#df.FT$serDate <- as.Date(df.FT$serDate, origin="1899-12-30" )  #df.FT$serDate is date class
#str(df.FT)
#
cat("","\n")
cat("All dates have been created to be of standard date class form","\n")
cat("","\n")
#
cat("df.FT data frame   -   Dates of date class","\n")
str(df.FT)
#
cat("","\n")
#delete unwanted variables in opening data frame dfd.FT in some cases
df.FT$Open <- NULL
df.FT$High <- NULL
df.FT$Low <- NULL
df.FT$Vol <- NULL
df.FT$Change <- NULL
#
FTlengthIndex <- NROW(df.FT)   # will later be truncated by initial vallues
print(FTlengthIndex)
#
cat("Calulate %returns and name serReturn","\n")
cat("","\n")
df.FT$prevPrice <- c(NA, head(df.FT$Price, n=-1))
str(df.FT$prevPrice)
df.FT$serReturn <- 100*(df.FT$Price - df.FT$prevPrice)/df.FT$prevPrice
str(df.FT$serReturn)
##correct for unbelievable low/high values at index= 1098, 1099
#df.FT$serReturn[1098] <-  -1.178
#df.FT$serReturn[1099] <- 1.35
df.FT$frcReturn <- (df.FT$Price - df.FT$prevPrice)/df.FT$prevPrice  # fractional returns
str(df.FT$frcReturn)
cat("Data frame df.FT with % returns as serReturn", "\n")
#str(df.FT)
cat("","\n")
#
cat("Trim df.FT dataframe of initial NA in prevPrice and serReturn", "\n")
df.FT <- df.FT[-1,]
cat("Final form of data frame df.FT", "\n")
str(df.FT)
cat("","\n")
#
cat("Calculate absReturn and cumulative return in date order and add to df.FT", "\n") 
df.FT$absReturn <- abs(df.FT$serReturn)
#df.FT$cumReturn <- cumsum(df.FT$serReturn)  # not correct, not compound retrrn
df.FT$cumReturn <- 100*(df.FT$Price/df.FT$Price[1] - 1)  # % cumulative return
cat("","\n")
cat("Structure of df.FT","\n")
str(df.FT)
cat("","\n")
#
df.FT <- df.FT[-1,]
#
FTlengths <- NROW(df.FT)  # length with return series
df.FT$index <- seq(1, FTlengths, 1)  
#
cat("Final trimmed form of df.FT with index, data lengths FTlengths =", FTlengths, "\n")
str(df.FT) 
cat("","\n")
cat("Write from df.FT to FTfullData.xlsx","\n")
write.xlsx(x=df.FT, file="FTfullData.xlsx")  
#
cat("","\n")
#############################################
#
cat("Add index to df.FT)","\n")
max_index <- max(df.FT$index)
df.FT <- subset(df.FT, df.FT$index >= 1 & df.FT$index <= max_index)
cat("Current form of df.FT)","\n")
str(df.FT)
cat("", "\n")
cat("write from df.FT with selected time period to xlsx file FTdataplotfile.xlsx", "\n")
write.xlsx(x=df.FT, file="FTdataplotfile.xlsx") 
cat("", "\n")
##################################################################

cat("Add smooth Prices to df.FT","\n")
cat("", "\n")
model1P <- loess(Price~index, data=df.FT, span=span_Price, na.rm=TRUE) 
predmodel1P <- predict(model1P, se=TRUE)
#cat("Structure of df.model1fit with smooth prices","\n")
df.model1Pfit <- data.frame(predmodel1P)
df.FT$Price_Smooth <- df.model1Pfit$fit
cat("str(df.FT) with loess smooth prices added to df.FT","\n")
str(df.FT)
cat("","\n")
##################################################################
#
cat("str(df.FTzero, data frame for needle plot, and df.FT$Zeros","\n")
zeros <- rep(0, each=FTlengths)
df.FT$Zeros <- zeros
df.FTzero <- rbind(data.frame(Yrtn=df.FT$serReturn,  Y0=zeros, Xaxis=df.FT$index))
str(df.FTzero)
write.xlsx(x=df.FTzero, file="FTzerodata.xlsx") 
cat("","\n")
#################################################################
#
cat("Time Series of Volatiliy and its Smooth","\n")
cat("", "\n")
df.FT$serVolatility <- scalingConstant*abs(df.FT$serReturn)
cat("Structure of df.FT with serVolatility","\n")
str(df.FT)
model1 <- loess(serVolatility~index, data=df.FT, span=span_Vlty, na.rm=TRUE) 
predmodel1 <- predict(model1, se=TRUE)
df.model1fit <- data.frame(predmodel1)  
df.FT$volatility_Smooth <- df.model1fit$fit  ###
df.FT$NA. <- NULL 
cat("", "\n")
################################################

cat("str(df.FTzero, data frame with added Date, serVolatility, volatility_Smooth","\n")
df.FTzero$Date <- df.FT$Date
df.FTzero$serVolatility <- df.FT$serVolatility
df.FTzero$volatility_Smooth <- df.FT$volatility_Smooth
str(df.FTzero)
cat("", "\n")
#########################################

cat("Structure of dataframe for qqplot, returns.df , using package qqplotr", "\n")
returns.df <- data.frame(qqdata=df.FT$serReturn)
str(returns.df)
cat("", "\n")
##########################################
#
cat("Price: min, max,  intv, breaks chosen","\n")
price_min <- min(df.FT$Price)
price_max <- max(df.FT$Price)
price_intv <- (price_max-price_min)/5  
price_breaks=seq(price_min, price_max, price_intv) 
print(price_min)
print(price_max)
print(price_intv)
print(price_breaks) 
#price_breaks_chosen=seq(0, 150, 50) # mandiv
#print(price_breaks_chosen)
 cat("","\n")
#
cat("Return: min,max, intv, breaks chosen","\n")
return_min <- min(df.FT$serReturn)
return_max <- max(df.FT$serReturn)
return_intv <- (return_max - return_min)/5
return_breaks=seq(return_min, return_max, return_intv)  
print(return_min)
print(return_max)
print(return_intv)
print(return_breaks)
#return_breaks=seq(-10, 20, 10)  # mandiv
return_breaks=seq(-4, 4, 2) #FTSE2005
cat("","\n")
#
cat("cumReturn: min,max, intv, breaka chosen","\n")
cumReturn_min <-min(df.FT$cumReturn)
cumReturn_max <-max(df.FT$cumReturn)
cumReturn_intv <- (cumReturn_max - cumReturn_min)/5
cumReturn_breaks <- seq(cumReturn_min, cumReturn_max, cumReturn_intv)  
print(cumReturn_min)
print(cumReturn_max)
print(cumReturn_intv)
print(cumReturn_breaks)
cumReturn_breaks_chosen <- seq(-5, 1175, 235)  # mandiv
print(cumReturn_breaks_chosen)
cat("","\n")#
#
cat("Volatility: max, intv, breaks chosen","\n")
volatility_max <- max(df.FT$serVolatility)
volatility_intv <- (volatility_max)/5
volatility_breaks=seq(0, volatility_max, volatility_intv) 
print(volatility_max)
print(volatility_intv)
print(volatility_breaks)
#volatility_breaks_chosen=seq(0, 20, 4) #mandiv
volatility_breaks_chosen=c(0, 3, 6, 9, 12, 15) # Ghana GSEC
print(volatility_breaks_chosen)
cat("", "\n")
###########################################
#
cat("Structure of df.FT needed for plots","\n")
str(df.FT)
cat("","\n")
cat("Structure of df.FTzero needed for plots","\n")
str(df.FTzero)
cat("","\n")
cat("Calculations to inform construction of plots","\n")
cat("","\n")
###########################################

cat("Plotting Time Series in R with ggplot ", "\n")
cat("", "\n")
#########################################
#
cat("plt1: Line plot of Price Time Series", "\n")
cat("", "\n")
#
#plot(df.FT$serDate, df.FT$Price) # for testing only
#df.FT$Date <- df.FT$serDate  # mandiv  
#print(df.FT$Price) #only for checking
# 
plt1 <- ggplot(aes(x=Date, y=Price), data=df.FT)  
plt1 <- plt1 + geom_line(size=0.01, color='black')
#plt1 <- plt1 + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("2 years"))  # FTSE100 data
#plt1 <- plt1 + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("5 years")) # Man Divsfd
plt1 <- plt1 + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("1 year")) # GhanaGSEC data
#plt1 <- plt1 + scale_y_continuous(limits=c(price_min, price_max), breaks=price_breaks)  #
#plt1 <- plt1 + scale_y_continuous(limits=c(0, 150), breaks=seq(0, 150, 50))  #Man dvsfd
#plt1 <- plt1 + scale_y_continuous(limits=c(1530,3530), breaks=c(1530,1930,2330,2730,3130,3530))  # Ghana GSE
plt1 <- plt1 + scale_y_continuous(limits=c(60,150), breaks=c(60, 65, 70,75,80,85,90,95,100,105,110,115,120,125,130,135,140,145,150))  # FTSE100
plt1 <- plt1 + ggtitle(Title_plt1)
plt1 <- plt1 + coord_fixed(ratio=1/3)
plt1 <- plt1 + theme_bw()
plt1 <- plt1 + theme(plot.title=element_text(size=14,  hjust=0.5), axis.title=element_text(size=10))  
plt1 <- plt1 + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
plt1 <- plt1 + theme(aspect.ratio=2/5)
#cat("", "\n")
#cat("Using cowplot package to save and display plt1 as plt_ts1.jpeg","\n")
plot_grid(plt1, nrow=1, ncol=1)
save_plot("plt_ts1.jpeg", plt1, nrow=1, ncol=1)
print(plt1)
#
###########################################
#
cat("plt1sm: Line plot of Price Time Series with loess smooth", "\n")
cat("", "\n")
plt1sm <- ggplot(aes(x=Date, y=Price), data=df.FT)  
plt1sm <- plt1sm + geom_line(size=0.01, color='black')
#plt1sm <- plt1sm + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("2 years"))  
plt1sm <- plt1sm + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("1 year")) # Ghana GSEC
#plt1sm <- plt1sm + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("5 years")) #mandiv
#plt1sm <- plt1sm + scale_y_continuous(limits=c(0, 150), breaks=seq(0, 150, 50))  # mandiv
plt1sm <- plt1sm + scale_y_continuous(limits=c(price_min, price_max), breaks=price_breaks)  
#plt1sm <- plt1sm + scale_y_continuous(limits=c(1530,3530), breaks=c(1530,1930,2330,2730,3130,3530))  # Ghana GSEC
plt1sm <- plt1sm + geom_line(aes(Date, Price_Smooth), data=df.FT, color="red")
plt1sm <- plt1sm + ggtitle(Title_plt1sm)
plt1sm <- plt1sm + coord_fixed(ratio=1/3)
plt1sm <- plt1sm + theme_bw()
plt1sm <- plt1sm + theme(plot.title=element_text(size=14,  hjust=0.5), axis.title=element_text(size=10))  
plt1sm <- plt1sm + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
plt1sm <- plt1sm + theme(aspect.ratio=2/5)
cat("", "\n")
cat("Using cowplot package to save and display plt1sm as plt_ts1sm.jpeg","\n")
plot_grid(plt1sm, nrow=1, ncol=1)
save_plot("plt_ts1sm.jpeg", plt1sm, nrow=1, ncol=1)
print(plt1sm)
cat("", "\n")
#
##################################################
cat("plt2: Line plot of Return Time Series", "\n")
#
cat("", "\n")
plt2 <- ggplot(aes(x=Date, y=serReturn), data=df.FT)
plt2 <- plt2 + geom_line(size=0.01, color='black')
#plt2 <- plt2 + scale_x_date(labels = date_format("%Y"), breaks = date_breaks("2 years"))
#plt2 <- plt2 + scale_x_date(labels = date_format("%Y"), breaks = date_breaks("5 years")) # Mandiv
#plt2 <- plt2 + scale_x_date(labels = date_format("%Y"), breaks = date_breaks("1 year")) # GSEC
#plt2 <- plt2 + scale_y_continuous(limits=c(-4, 4), breaks=c( -4, -2, 0, 2, 4))  #Ghana GSECx omit 1 pt
plt2 <- plt2 + scale_y_continuous(limits=c(-10, 10), breaks=c(-10,-7.5, -5, -2.5, 0, 2.5, 5, 7, 10))  # FTSE100 ARCH1 residuals
#plt2 <- plt2 + scale_y_continuous(limits=c(-20, 20), breaks=c( -20,-10,0,10,20)) #Mandiv
plt2<- plt2 + ylab('Return')
plt2 <- plt2 + ggtitle(Title_plt2)
plt2 <- plt2 + coord_fixed(ratio=1/3)
plt2 <- plt2 + theme_bw()
plt2 <- plt2 + theme(plot.title=element_text(size=14,  hjust=0.5), axis.title=element_text(size=10))
plt2 <- plt2 + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
plt2 <- plt2 + theme(aspect.ratio=2/5)
#
cat("Using cowplot package to save and display plt2 as plt_ts2.jpeg","\n")
plot_grid(plt2, nrow=1, ncol=1)
save_plot("plt_ts2.jpeg", plt2, nrow=1, ncol=1)
print(plt2)
cat("", "\n")
#
cat("Using cowplot package for joint display of Price and Return and save  plt1and plt2 as plt1_2.jpeg","\n")
plt1_2 <- plot_grid(plt1, plt2, nrow=2, ncol=1)
save_plot("plt1_2.jpeg", plt1_2, nrow=2, ncol=1)
print(plt1_2)
cat("", "\n")
#
############################################################
cat("plt2cr: Cumulative returns plot here", "\n")
#
plt2cr <- ggplot(aes(x=Date, y=cumReturn), data=df.FT)  
plt2cr <- plt2cr + geom_line(size=0.01, color='black')
#plt2cr <- plt2cr + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("2 years"))  
#plt2cr <- plt2cr + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("5 years")) # mandiv
plt2cr <- plt2cr + scale_x_date(labels = date_format("%Y") , breaks = date_breaks("1 year")) # GSEC 
#plt2cr <- plt2cr + scale_y_continuous(limits=c(cumReturn_min, cumReturn_max), breaks=cumReturn_breaks)  
#plt2cr <- plt2cr + scale_y_continuous(limits=c(-5,1175), breaks=seq(-5, 1175, 235))
#plt2cr <- plt2cr + scale_y_continuous(limits=c(-20, 85), breaks=c(-20, 0, 20, 40, 60, 80))  #FTSE 2004-2019
plt2cr <- plt2cr + scale_y_continuous(limits=c(-20, 80), breaks=c(-20, 0, 20, 40, 60,80))  #FTSE2005
#plt2cr <- plt2cr + scale_y_continuous(limits=c(-20, 80), breaks=c(-20, 0, 20, 40, 60, 80))  #Ghana GSEC
#plt2cr <- plt2cr + scale_y_continuous(limits=c(-5, 1170), breaks=c(-5, 230, 465, 700, 935, 1170)) # mandiv 
plt2cr <- plt2cr + ylab("Cumulative Return")
plt2cr <- plt2cr + ggtitle(Title_plt2cr)
plt2cr <- plt2cr + coord_fixed(ratio=1/3)
plt2cr <- plt2cr + theme_bw()
plt2cr <- plt2cr + theme(plot.title=element_text(size=14, hjust=0.5), axis.title=element_text(size=10))  
plt2cr <- plt2cr + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
plt2cr <- plt2cr + theme(aspect.ratio=2/5)
cat("", "\n")
cat("Using cowplot package to save and display plt2cr as plt2cr_ts3.jpeg","\n")
plot_grid(plt2cr, nrow=1, ncol=1)
save_plot("plt2cr_ts3.jpeg", plt2cr, nrow=1, ncol=1)
print(plt2cr)
cat("", "\n")
############################################################
#
cat("plt3: Needle Plot of Return Time Series", "\n")
#index_breaks=seq(0, FTlengths, index_intv) 
index_breaks=c(0,200, 400, 600, 800, 1000, 1200) #Ghana gse
#index_breaks=c(0,200, 400, 600, 800, 1000, 1200,1400, 1600) #FTSE2005, 1763#
return_breaks=seq(-4, 4, 2) #FTSE2005
str(index_breaks)
#print(index_intv)
cat("", "\n")
plt3 <- ggplot(aes(x=Xaxis, y=Yrtn), data=df.FTzero)  
plt3 <- plt3 + geom_segment(aes(x=Xaxis, y=Y0, xend=Xaxis, yend=Yrtn), colour="black" )  
plt3 <- plt3 + geom_line(size=0.01, color='black') 
#plt3 <- plt3 + scale_x_continuous(limits=c(1, FTlengths), breaks=index_breaks)
plt3 <- plt3 + scale_x_continuous(limits=c(1, 1250), breaks=index_breaks)# Ghana GSE
#plt3 <- plt3 + scale_x_continuous(limits=c(1, 1763), breaks=index_breaks)
#plt3 <- plt3 + scale_x_date(labels = date_format("%Y"),breaks = date_breaks("1 year")) 
#plt3 <- plt3 + scale_y_continuous(limits=c(return_min, return_max), breaks=return_breaks) 
plt3 <- plt3 + scale_y_continuous(limits=c(-4, 4), breaks=c( -4, -2, 0, 2, 4))  # FTSE2005, Ghana GSEComit 1 pt
#plt3 <- plt3 + scale_y_continuous(limits=c(-10, 10), breaks=c( -10.-7.5, -5, -2.5, 0, 2.5, 5, 7, 10))  # FTSE100 ARCH1 residuals
plt3 <- plt3 + xlab('Days')
plt3 <- plt3 + ylab('Return')
plt3 <- plt3 + ggtitle(Title_plt3)
plt3 <- plt3 + coord_fixed(ratio=1/3)
plt3 <- plt3 + theme_bw()
plt3 <- plt3 + theme(plot.title=element_text(size=14, hjust=0.5), axis.title=element_text(size=10))
plt3 <- plt3 + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
plt3 <- plt3 + theme(aspect.ratio=2/5)
cat("Using cowplot package to save and display plt3 as plt_ts3.jpeg","\n")
plot_grid(plt3, nrow=1, ncol=1)
save_plot("plt_ts3.jpeg", plt3, nrow=1, ncol=1)
print(plt3)
cat("", "\n")
#
###############################################################
#
#hist(df.FT$serReturn, freq=NULL)  # testing for y scale
#
cat("plt5: Histogram of Returns", "\n")
cat("", "\n")
plt5 <- ggplot(data=df.FT, aes( x=serReturn))
plt5 <- plt5 + geom_histogram(aes(y=..density..),  color="black", binwidth=0.2,fill="grey") 
#plt5 <- plt5 + xlim(c(return_min, return_max))  ##  change as required
#plt5 <- plt5 + xlim(c(-4, 40.0430))  #Nigeria ? 
plt5 <- plt5 + xlim(c(-4, 4))  #Ghana GSEC
#plt5 <- plt5 + ylim(c(0, 40))  ##  Nigeria
plt5 <- plt5 + ylim(c(0, 0.75))  ##  Ghana GSEC
#plt5 <- plt5 + ylim(c(0, 0.5))  ##  FTSE2005
plt5 <- plt5 + theme_bw()
plt5 <- plt5 + ggtitle(Title_plt5)
plt5 <- plt5 + theme(plot.title=element_text(size=14, hjust=0.5), axis.title=element_text(size=10))
plt5 <- plt5 + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
plt5 <- plt5 + theme(aspect.ratio=1)
print(plt5)   
cat("Using cowplot package to display and save  plt5 as plt_ts5.jpeg","\n")
plot_grid(plt5, nrow=1, ncol=1)
save_plot("plt_ts5.jpeg", plt5, nrow=1, ncol=1)
cat("", "\n")
###############################################

cat("plt6: QQ PLOT of Returns, using package qqplotr", "\n")
cat("", "\n")
qqintv <- as.integer((qqmax-qqmin)/4) # add bands later
plt6 <- ggplot(data=returns.df, aes(sample=qqdata)) 
plt6 <- plt6 + stat_qq_band()  
plt6 <- plt6 + stat_qq_line()  
plt6 <- plt6 + stat_qq_point() 
plt6 <- plt6 + scale_x_continuous(limits=c(qqmin, qqmax), breaks=seq(qqmin, qqmax, qqintv)) 
plt6 <- plt6 + scale_y_continuous(limits=c(qqmin, qqmax), breaks=seq(qqmin, qqmax, qqintv))
plt6 <- plt6 + labs(x="Gaussian Quantiles", y="Data Quantiles")
plt6 <- plt6 + theme_bw()
plt6 <- plt6 + ggtitle(Title_plt6)
plt6 <- plt6 + theme(plot.title=element_text(size=14, hjust=0.5), axis.title=element_text(size=10))
plt6 <- plt6 + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
plt6 <- plt6+ theme(aspect.ratio=1)
plt6
cat("Using cowplot package to display and save  plt6 as plt_ts6.jpeg","\n")
plot_grid(plt6, nrow=1, ncol=1)
save_plot("plt6.jpeg",plt6, nrow=1, ncol=1)
print(plt6)
#
cat("", "\n")
cat("Calculation of Mean, Stdev, Skewness, Excess3-Kurtosis of serReturn", "\n")
Mean <- mean(df.FT$serReturn)
str(Mean)
Stdev <- sd(df.FT$serReturn)
str(Stdev)
Skewness <- skewness(df.FT$serReturn)
str(Skewness)
Kurtosis <- kurtosis(df.FT$serReturn, method=c("excess"))
str(Kurtosis)
#
cat("", "\n")
cat("calculation of Anderson Darling Test for Normality", "\n")
AD <- ad.test(df.FT$serReturn)
cat("Anderson Darling Statistic", "\n")
print(AD$statistic)
cat("Anderson Darling p.value", "\n")
print(AD$p.value)
#
cat("", "\n")
#
################################################################
#
cat("plt4: Needle plot of Volatility with lowess Smooth", "\n")
cat("", "\n")
index_breaks=c(0,200, 400, 600, 800, 1000, 1200) # Ghana GSE
#
cat("df.FTzero data frame", "\n")
str(df.FTzero)
cat("", "\n")
#
plt4 <- ggplot(aes(x=Xaxis, y=serVolatility), data=df.FTzero)  
#plt4 <- ggplot(aes(x=Xaxis, y=serVolatility), data=df.FT) 
plt4 <- plt4 + geom_segment(aes(x=Xaxis, y=Y0, xend=Xaxis, yend=serVolatility), colour="grey", size=0.05 )
plt4 <- plt4 + geom_line(aes(x=Xaxis, y=volatility_Smooth),colour='red', size=1.0)
#plt4 <- plt4 + geom_line(size=0.05, color='black')    
#plt4 <- plt4 + scale_x_continuous(limits=c(1, FTlengths), breaks=index_breaks) 
#plt4 <- plt4 + scale_x_continuous(limits=c(1, 1763), breaks=index_breaks)  # FTSE2005
plt4 <- plt4 + scale_x_continuous(limits=c(1, 1250), breaks=index_breaks)  # Ghana GSEC
#plt4 <- plt4 + scale_x_date(labels = date_format("%Y"),breaks = date_breaks("2 years"))
#plt4 <- plt4 + scale_x_date(labels = date_format("%Y"),breaks = date_breaks("5 years"))
#plt4 <- plt4 + scale_x_date(labels = date_format("%Y"),breaks = date_breaks("1 year")) # Ghana GSEC
plt4 <- plt4 + scale_y_continuous(limits=c(0, 4), breaks=c(0, 1, 2, 3, 4)) #Ghana GSEC
#plt4 <- plt4 + scale_y_continuous(limits=c(-1, 10), breaks=c(0,2,4,6,8,10))  # FTSE2005
#plt4 <- plt4 + scale_y_continuous(limits=c(0, volatility_max), breaks=volatility_breaks)
plt4 <- plt4 + xlab('Days')
plt4 <- plt4 + ylab('Volatility')
plt4 <- plt4 + ggtitle(Title_plt4)
plt4 <- plt4 + coord_fixed(ratio=1/3)
plt4 <- plt4 + theme_bw()
plt4 <- plt4 + theme(plot.title=element_text(size=14, hjust=0.5), axis.title=element_text(size=10))
plt4 <- plt4 + theme(panel.grid.major=element_blank(), panel.grid.minor=element_blank())
plt4 <- plt4 + theme(aspect.ratio=2/5)
print(plt4)
cat("Using cowplot package to display and save  plt4 as plt_ts4.jpeg","\n")
plot_grid(plt4, nrow=1, ncol=1)
save_plot("plt_ts4.jpeg", plt4, nrow=1, ncol=1)
cat("", "\n")
##############################################################################
#
cat("THIS IS END of FTplotSmoothRfunction.R", "\n")
cat("", "\n")
toc()
#
}
