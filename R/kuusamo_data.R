# Kettis ------------------------------------------------------------------

# 1.5.-31.7.2011 ja 1.5.-31.7.2012.
apiKey <- "04d9592f-c8c0-4c8d-b3c2-50465da8bb47"

# 1.5.-31.7.2011
startDateTime <- "2011-05-01"
endDateTime <- "2011-07-31"
kuusamo.2011 <- get_weather_data(apiKey, startDateTime, endDateTime, "101887")

# 1.5.-31.7.2012
startDateTime <- "2012-05-01"
endDateTime <- "2012-07-31"
kuusamo.2012 <- get_weather_data(apiKey, startDateTime, endDateTime, "101887")

write.table(kuusamo.2011, "data/kiutakongas2011.csv", row.names=FALSE, sep=";")
write.table(kuusamo.2012, "data/kiutakongas2012.csv", row.names=FALSE, sep=";")
