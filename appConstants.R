# global constants available to the app
# last update:2016-10-08

# constants required for every app
appName <- 'room'
appTitle <- 'Raumklima'
app_id <- 'eu.ownyourdata.room'

appFields <- c('timestamp', 'value')
appFieldKey <- 'timestamp'
appFieldTypes <- c('timestamp', 'number')
appFieldInits <- c('empty', 'empty')
appFieldTitles <- c('Zeit', 'Wert')
appFieldWidths <- c(100, 100)

# Version information
currVersion <- "0.3.0"
verHistory <- data.frame(rbind(
        c(version = "0.3.0",
          text    = "erstes Release")
))

# app specific constants
sensorUiList <- c('Temperatur', 'Feuchtigkeit')
actuatorUiList <- c('Dienstagabend')