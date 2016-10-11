# show compare chart
# last update:2016-10-09

comparePlotly <- function(){
        pdf(NULL)
        outputPlot <- plotly_empty()
        dat1 <- repoData('eu.ownyourdata.room.temp1')
        dat2 <- repoData('eu.ownyourdata.room.hum1')
        if((nrow(dat1) > 0) &
           (nrow(dat2) > 0)){
                dat1$date <- as.POSIXct(dat1$timestamp, 
                                        origin='1970-01-01')
                dat2$date <- as.POSIXct(dat2$timestamp, 
                                        origin='1970-01-01')
                mymin <- as.Date(input$dateRange[1], "%d.%m.%Y")
                mymax <- as.Date(input$dateRange[2], "%d.%m.%Y")
                if(mymax > mymin){
                        dat1 <- dat1[order(dat1[, 'date']),]
                        dat1 <- dat1[dat1$date >= as.POSIXct(mymin) &
                                     dat1$date <= as.POSIXct(mymax), ]
                        dat2 <- dat2[order(dat2[, 'date']),]
                        dat2 <- dat2[dat2$date >= as.POSIXct(mymin) &
                                     dat2$date <= as.POSIXct(mymax), ]
                        if((nrow(dat1) > 0) &
                           (nrow(dat2) > 0)){
                                outputPlot <- plot_ly() %>%
                                        add_lines(x = as.POSIXct(dat2$timestamp, 
                                                                 origin='1970-01-01'),
                                                  y = dat2$value,
                                                  name = 'Feuchtigkeit') %>%
                                        add_lines(x = as.POSIXct(dat1$timestamp, 
                                                                 origin='1970-01-01'),
                                                  y = dat1$value,
                                                  name = 'Temperatur',
                                                  yaxis = 'y2') %>%
                                        layout( title = '',
                                                yaxis = list(
                                                        title = 'Feuchtigkeit'
                                                ),
                                                yaxis2 = list(
                                                        overlaying = 'y',
                                                        side = 'right',
                                                        title = 'Temperatur'
                                                ),
                                                showlegend = FALSE,
                                                margin = list(l = 80, r = 80)
                                        )
                        } else {
                                createAlert(session, 'dataStatus', alertId = 'myDataStatus',
                                            style = 'warning', append = FALSE,
                                            title = 'Keine Daten im gewählten Zeitfenster',
                                            content = 'Für das ausgewählte Zeitfenster sind keine Daten vorhanden.')
                        }
                } else {
                        createAlert(session, 'dataStatus', alertId = 'myDataStatus',
                                    style = 'warning', append = FALSE,
                                    title = 'Ungültiges Zeitfenster',
                                    content = 'Im ausgewählten Zeitfenster liegt das End-Datum vor dem Beginn-Datum. Korriege die Eingabe!')
                }
        } else {
                createAlert(session, 'dataStatus', alertId = 'myDataStatus',
                            style = 'warning', append = FALSE,
                            title = 'Keine Daten in der PIA vorhanden',
                            content = 'Derzeit sind noch keine Daten in der PIA erfasst. Wechsle zu "Datenquellen" und konfiguriere vorhandene Sensoren!')
        }
        dev.off()
        outputPlot
}
