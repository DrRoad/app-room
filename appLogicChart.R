# show compare chart
# last update:2016-10-09

sensorList <- function(){
        sensors <- readNagiosItems()
        allSensors <- vector()
        sel1 <- ''
        sel2 <- ''
        if (nrow(sensors) > 0){
                allSensors <- c(
                        'ausblenden',
                        rownames(sensors)
                )
                sel1 <- rownames(sensors)[1]
                if(nrow(sensors) > 1){
                        sel2 <- rownames(sensors)[2]
                } else {
                        sel2 <- 'ausblenden'
                }
        } else {
                allSensors <- c('nicht vorhanden')
                sel1 <- 'nicht vorhanden'
                sel2 <- 'nicht vorhanden'
        }
        
        updateSelectInput(
                session,
                'sensor1Select',
                choices = allSensors,
                selected = sel1)
        updateSelectInput(
                session,
                'sensor2Select',
                choices = allSensors,
                selected = sel2)

        appRepos <<- append(appReposDefault,
                            setNames(as.character(sensors$repo),
                                     as.list(rownames(sensors))))
        updateSelectInput(
                session,
                'repoSelect',
                choices = names(appRepos),
                selected = 'Nagios')
}

comparePlotly <- function(){
        pdf(NULL)
        outputPlot <- plotly_empty()
        sel1 <- input$sensor1Select
        sel2 <- input$sensor2Select
        dat1 <- data.frame()
        dat2 <- data.frame()
        sensors <- readNagiosItems()
        if((sel1 != 'ausblenden') & (sel1 != 'nicht vorhanden')){
                dat1repo <- as.character(
                        sensors[rownames(sensors) == sel1, 
                                'repo'])
                dat1 <- repoData(dat1repo)
        }
        if((sel2 != 'ausblenden') & (sel2 != 'nicht vorhanden')){
                dat2repo <- as.character(
                        sensors[rownames(sensors) == sel2, 
                                'repo'])
                dat2 <- repoData(dat2repo)
        }
        mymin <- as.Date(input$dateRange[1], "%d.%m.%Y")
        mymax <- as.Date(input$dateRange[2], "%d.%m.%Y")
        closeAlert(session, 'myDataStatus')
        if(mymax > mymin){
                if(nrow(dat1) > 0){
                        dat1$date <- as.POSIXct(dat1$timestamp, 
                                                origin='1970-01-01')
                        if(mymax > mymin){
                                dat1 <- dat1[order(dat1[, 'date']),]
                                dat1 <- dat1[dat1$date >= as.POSIXct(mymin) &
                                                     dat1$date <= as.POSIXct(mymax), ]
                        }
                }
                if(nrow(dat2) > 0){
                        dat2$date <- as.POSIXct(dat2$timestamp, 
                                                origin='1970-01-01')
                        if(mymax > mymin){
                                dat2 <- dat2[order(dat2[, 'date']),]
                                dat2 <- dat2[dat2$date >= as.POSIXct(mymin) &
                                                     dat2$date <= as.POSIXct(mymax), ]
                        }
                }
                if((nrow(dat1) > 0) &
                   (nrow(dat2) > 0)){
                        outputPlot <- plot_ly() %>%
                                add_lines(x = as.POSIXct(dat1$timestamp, 
                                                         origin='1970-01-01'),
                                          y = dat1$value,
                                          name = sel1) %>%
                                add_lines(x = as.POSIXct(dat2$timestamp, 
                                                         origin='1970-01-01'),
                                          y = dat2$value,
                                          name = sel2,
                                          yaxis = 'y2') %>%
                                layout( title = '',
                                        yaxis = list(
                                                title = sel1
                                        ),
                                        yaxis2 = list(
                                                overlaying = 'y',
                                                side = 'right',
                                                title = sel2
                                        ),
                                        showlegend = FALSE,
                                        margin = list(l = 80, r = 80)
                                )
                } else {
                        if(nrow(dat1) > 0){
                                outputPlot <- plot_ly() %>%
                                        add_lines(x = as.POSIXct(dat1$timestamp, 
                                                                 origin='1970-01-01'),
                                                  y = dat1$value,
                                                  name = sel1) %>%
                                        layout( title = '',
                                                yaxis = list(
                                                        title = sel1
                                                ),
                                                showlegend = FALSE,
                                                margin = list(l = 80, r = 80)
                                        )
                        }
                        if(nrow(dat2) > 0){
                                outputPlot <- plot_ly() %>%
                                        add_lines(x = as.POSIXct(dat2$timestamp, 
                                                                 origin='1970-01-01'),
                                                  y = dat2$value,
                                                  name = sel2) %>%
                                        layout( title = '',
                                                yaxis = list(
                                                        title = sel2
                                                ),
                                                showlegend = FALSE,
                                                margin = list(l = 80, r = 80)
                                        )
                        }
                        if((nrow(dat1) == 0) &
                           (nrow(dat2) == 0)){
                                createAlert(session, 'dataStatus', alertId = 'myDataStatus',
                                            style = 'warning', append = FALSE,
                                            title = 'Keine Daten für Sensoren im gewählten Zeitfenster',
                                            content = 'Für die ausgewählten Sensoren sind im angegebenen Zeitfenster keine Daten vorhanden.')
                        }
                }
        } else {
                createAlert(session, 'dataStatus', alertId = 'myDataStatus',
                            style = 'warning', append = FALSE,
                            title = 'Ungültiges Zeitfenster',
                            content = 'Im ausgewählten Zeitfenster liegt das End-Datum vor dem Beginn-Datum. Korriege die Eingabe!')
        }
        dev.off()
        outputPlot
}
