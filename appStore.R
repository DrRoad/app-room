# layout for section "Storage"
# last update: 2016-10-06

appStore <- function(){
        fluidRow(
                column(12,
                       h3('Datenblatt'),
                       p('hello world')
                       # selectInput('repoSelect',
                       #             label = 'Auswahl:',
                       #             choices = names(appReposDefault)),
                       # rHandsontableOutput('dataSheet'),
                       # br(),
                       # htmlOutput('dataSheetDirty', inline = TRUE),
                       # conditionalPanel(
                       #         condition = "output.dataSheetDirty != ''",
                       #         tagList(actionButton('saveSheet', 
                       #                              'Änderungen im Datentresor speichern', 
                       #                              icon=icon('save')),
                       #                 br(),br())),
                       # downloadButton('exportCSV', 'CSV Export')
                )
        )
}
