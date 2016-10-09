# show compare chart
# last update:2016-10-09

comparePlotly <- function(){
        pdf(NULL)
        outputPlot <- plotly_empty()
        tempData <- repoData('eu.ownyourdata.room.temp1')
        humData <- repoData('eu.ownyourdata.room.hum1')
        xdat <- humData$timestamp
        ydat <- humData$value
        outputPlot <- plot_ly() %>%
                add_lines(x = as.POSIXct(humData$timestamp, 
                                         origin='1970-01-01'),
                          y = humData$value,
                          name = 'Feuchtigkeit') %>%
                add_lines(x = as.POSIXct(tempData$timestamp, 
                                         origin='1970-01-01'),
                          y = tempData$value,
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
        dev.off()
        outputPlot
}
