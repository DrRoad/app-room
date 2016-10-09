# application specific logic
# last update: 2016-10-07

source('srvDateselect.R', local=TRUE)
source('srvEmail.R', local=TRUE)
source('appLogicChart.R', local=TRUE)

# any record manipulations before storing a record
appData <- function(record){
        record
}

getRepoStruct <- function(repo){
        list('fields'      = appFields,
             'fieldKey'    = appFieldKey,
             'fieldTypes'  = appFieldTypes,
             'fieldInits'  = appFieldInits,
             'fieldTitles' = appFieldTitles,
             'fieldWidths' = appFieldWidths) 
}

output$compareChart <- renderPlotly({
        comparePlotly()
})

repoData <- function(repo){
        data <- data.frame()
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']],
                                repo)
                data <- readItems(app, url)
        }
        data
}