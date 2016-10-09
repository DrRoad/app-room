# UI for configuring NAGIOS data sources
# last update: 2016-10-08

appSourceNagios <- function(){
        tabPanel('NAGIOS Import',
                 br(),
                 fluidRow(
                         column(4,
                                selectInput('sensorList',
                                            'Sensoren:',
                                            sensorUiList,
                                            multiple=TRUE, 
                                            selectize=FALSE,
                                            size=12,
                                            selected = 'Temperatur'),
                                actionButton('delSensorList', 'Entfernen', 
                                             icon('trash'))),
                         column(8,
                                textInput('sensorItemName',
                                          'Name:',
                                          value = 'Temperatur'),
                                tags$label('NAGIOS-URL:'),
                                br(),
                                tags$textarea(id='sensorItemNagiosUrl',
                                              rows=3, cols=80,
                                              'http://localhost/mysite/pnp4nagios/xport/json?host=climateplus_6540&srv=temp'),
                                br(),
                                textInput('sensorItemRepo',
                                          'Repo:',
                                          value = 'eu.ownyourdata.room.temp1'),
                                br(),
                                actionButton('addSensorItem', 
                                             'Hinzufügen', icon('plus')),
                                actionButton('updateSensorItem', 
                                             'Aktualisieren', icon('edit'))
                         )
                 )
        )
}
        