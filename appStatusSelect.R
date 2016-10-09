# UI for selecting a date-range
# last update: 2016-10-06

appStatusSelect <- function(){
        fluidRow(
                column(4,
                       dateRangeInput('dateRange',
                                      language = 'de',
                                      separator = ' bis ',
                                      format = 'dd.mm.yyyy',
                                      label = 'Zeitfenster',
                                      start = as.Date(Sys.Date() - months(6)), 
                                      end = Sys.Date()
                       )
                ),
                column(4,
                       selectInput('sensor1Select',
                                   label = 'Sensor 1:',
                                   choices = c('Feuchtigkeit'))),
                column(4,
                       selectInput('sensor2Select',
                                   label = 'Sensor 2:',
                                   choices = c('Temperatur')))
        )
}
