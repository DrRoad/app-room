# UI for handling actuators
# last update: 2016-10-08

appStatusActuator <- function(){
        tabPanel('Aktoren', br(),
                 fluidRow(
                         column(4,
                                selectInput('actuatorList',
                                            'Aktionen:',
                                            actuatorUiList,
                                            multiple=TRUE, 
                                            selectize=FALSE,
                                            size=12,
                                            selected = 'Dienstagabend'),
                                actionButton('delActuatorList', 'Entfernen', 
                                             icon('trash'))),
                         column(8,
                                textInput('actuatorItemName',
                                          'Name:',
                                          value = 'Dienstagabend'),
                                selectInput('actuatorItemScenario',
                                            label = 'Szenario:',
                                            choices = c('Fenster öffnen zum Kühlen')),
                                textInput('actuatorItemScenario',
                                          'Szenarien Parameter:',
                                          value = 'day="Tuesday"; sensor="Temperatur"; value=">26"'),
                                textInput('actuatorItemCmd',
                                          'Befehl:',
                                          value = 'coap win_open.xml'),
                                br(),
                                actionButton('addActuatorItem', 
                                             'Hinzufügen', icon('plus')),
                                actionButton('updateActuatorItem', 
                                             'Aktualisieren', icon('edit'))
                         )
                 )
        )
}
