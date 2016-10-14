# UI for handling actuators
# last update: 2016-10-08

appStatusActuator <- function(){
        tabPanel('Aktoren',
                 br(),
                 helpText('Konfiguriere hier Szeanrien für vorhandene Aktoren.',
                          style='display:inline'),
                 br(),br(),
                 fluidRow(
                         column(4,
                                selectInput('actuatorList',
                                            'Aktionen:',
                                            actuatorUiList,
                                            multiple = TRUE, 
                                            selectize = FALSE,
                                            size = 12,
                                            choices = c('')),
                                actionButton('delActuatorList', 'Entfernen', 
                                             icon('trash')),
                                actionButton('runActuatorList', 
                                             'Jetzt ausführen',
                                             icon('cogs'))),
                         column(8,
                                textInput('actuatorItemName',
                                          'Name:'),
                                selectInput('actuatorItemScenario',
                                            label = 'Szenario:',
                                            choices = c('Fenster zum Kühlen öffnen')),
                                textInput('actuatorItemParameters',
                                          'Szenarien Parameter:'),
                                textInput('actuatorItemCommand',
                                          'Befehl:'),
                                checkboxInput('actuatorItemActive',
                                              'aktiv'),
                                br(),
                                actionButton('addActuatorItem', 
                                             'Hinzufügen', icon('plus')),
                                actionButton('updateActuatorItem', 
                                             'Aktualisieren', icon('edit'))
                         )
                 )
        )
}
