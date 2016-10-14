# UI for configuring NAGIOS data sources
# last update: 2016-10-08

appSourceNagios <- function(){
        tabPanel('NAGIOS Import',
                 br(),
                 helpText('Konfiguriere hier die vorhandenen Sensoren und ihren Speicherort in Nagios. Du kannst auch ', style='display:inline'),
                 actionLink('importNagiosNow', 
                            'Daten jetzt importieren', 
                            icon('download'), style='display:inline'),
                 br(),br(),
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
                                          value = ''),
                                tags$label('NAGIOS-URL:'),
                                br(),
                                tags$textarea(id='sensorItemNagiosUrl',
                                              rows=3, cols=80,
                                              ''),
                                br(),
                                actionLink('testNagiosUrl', 
                                           'Link testen',
                                           icon=icon('external-link')),
                                helpText('(Pop-up Blocker dafür ausschalten!)',
                                         style='display:inline'),
                                br(),br(),
                                textInput('sensorItemRepo',
                                          'Repo:',
                                          value = ''),
                                br(),
                                actionButton('addSensorItem', 
                                             'Hinzufügen', icon('plus')),
                                actionButton('updateSensorItem', 
                                             'Aktualisieren', icon('edit'))
                         )
                 )
        )
}
        