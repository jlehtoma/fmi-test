library(fmi)
library(dplyr)
library(ggplot2)
library(reshape2)

source("R/theme.R")

get_weather_data <- function(apiKey, startDateTime, endDateTime, fmisid) {

  request <- FMIWFSRequest(apiKey=apiKey)
  
  request$setParameters(request="getFeature",
                        storedquery_id="fmi::observations::weather::daily::timevaluepair",
                        parameters="rrday,snow,tday,tmin,tmax")
  
  client <- FMIWFSClient()
  
  response <- client$getDailyWeather(request=request, 
                                     startDateTime=startDateTime,
                                     endDateTime=endDateTime,
                                     fmisid=fmisid)
  dat <- as.data.frame(response)
  
  # Get the variable names
  var.names <- dplyr::select(dat, variable) 
  
  # Manual splicing and dicing
  # Get just the times and values
  timevalues <- dplyr::select(dat, -fid, -gml_id, -beginPosition, -endPosition,
                              -timePosition, -value, -identifier, -name1, 
                              -name2, -name3, -region, -variable, -coords.x2, 
                              -coords.x1)
  
  # timevalues should now 2 x days amount of cols. Actual data (time) rows
  # are redundant as they contain all the same information. Measurements cols
  # do not.
  times <- timevalues[,seq(1, ncol(timevalues)/2)]
  times <- as.data.frame(as.Date(t(times[1,])))
  colnames(times) <- c("Date")
  
  values <- timevalues[,seq(ncol(timevalues)/2+1, ncol(timevalues))]
  values <- t(values)
  values <- as.data.frame(apply(values, 2, as.numeric))
  colnames(values) <- var.names$variable
  
  # Bind things together
  measurements <- cbind(times, values)
  rownames(measurements) <- NULL
  # Replace NaNs
  measurements[is.na(measurements)] <- NA
  
  return(measurements)
}

apiKey <- "04d9592f-c8c0-4c8d-b3c2-50465da8bb47"

# 1.5.-31.7.2011
startDateTime <- "2013-01-01"
endDateTime <- "2013-12-31"

kuusamo.2012 <- get_weather_data(apiKey, startDateTime, endDateTime, "101887")
helsinki.2012 <- get_weather_data(apiKey, startDateTime, endDateTime, "100971")

# Melt the data
m.kuusamo.2012 <- reshape2::melt(kuusamo.2012, id.vars=c("Date"))
m.kuusamo.2012$location <- "Kuusamo, Kiutaköngäs"

m.helsinki.2012 <- reshape2::melt(helsinki.2012, id.vars=c("Date"))
m.helsinki.2012$location <- "Helsinki, Kaisaniemi"

dat <- rbind(m.kuusamo.2012, m.helsinki.2012)

# Plot
p <- ggplot(dplyr::filter(dat, variable %in% c("tday", "tmax", "tmin")),
                          aes(x=Date, y=value, color=variable))
p + geom_line() + facet_wrap(~ location, ncol=1) + ylab("Temperature (C)\n") +
  xlab("\nDate")

p <- ggplot(dplyr::filter(dat, variable == "snow"), aes(x=Date, y=value, 
                                                        color=location))
p + geom_line(size=1) + xlab("\nDate") + ylab("Snowdepth (cm)\n")

p <- ggplot(dplyr::filter(dat, variable == "rrday"), aes(x=Date, y=value, 
                                                         color=location))
p + geom_point(alpha=1/3) + stat_smooth(method="loess") +  
  xlab("\nDate") + ylab("Precipitation (mm)\n")

