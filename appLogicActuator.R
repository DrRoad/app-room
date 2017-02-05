# configure actuators
# last update: 2016-10-14

# get stored Actuators
readActuatorItems <- function(){
        app <- currApp()
        actuatorItems <- data.frame()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.actuator'))
                actuatorItems <- readItems(app, url)
                if(nrow(actuatorItems) > 0){
                        rownames(actuatorItems) <- actuatorItems$name
                        actuatorItems <- actuatorItems[, c('scenario',
                                                           'params',
                                                           'command',
                                                           'active')]
                }
        }
        actuatorItems
}

observe({
        if(is.null(input$actuatorList)){
                allItems <- readActuatorItems()
                updateSelectInput(session, 'actuatorList',
                                  choices = rownames(allItems))
                
                # check if periodic Actuator actions are scheduled
                app <- currApp()
                if(length(app) > 0){
                        schedulerItems <- readSchedulerItems()
                        schedulerUrl <- itemsUrl(app[['url']], schedulerKey)
                        
                        # get scheduler item for actuator action
                        schedulerActuator <- schedulerItems[
                                schedulerItems$parameters.Rscript_reference == 
                                        'actuator_exec', ]
                        if(nrow(schedulerActuator) > 1){
                                lapply(schedulerActuator$id,
                                       function(x) deleteItem(app, schedulerUrl,
                                                              as.character(x)))
                                schedulerActuator <- data.frame()
                        }
                        
                        # write scheduler entries
                        replace = list(pia_url    = app[['url']],
                                       app_key    = app[['app_key']],
                                       app_secret = app[['app_secret']])
                        parameters <- list(Rscript_reference = 'actuator_exec',
                                           Rscript_repo = scriptRepo,
                                           replace=replace)
                        config <- list(app=app[['app_key']],
                                       time='*/5 * * * *',
                                       task='Rscript',
                                       parameters=parameters)
                        config$`_oydRepoName` <- 'Scheduler'
                        
                        if(nrow(schedulerActuator) == 0){
                                writeItem(app, schedulerUrl, config)
                        } else {
                                updateItem(app, schedulerUrl, config,
                                           schedulerActuator$id)
                        }
                        
                        # write script for scheduler entry----------------------
                        scriptRepoUrl <- itemsUrl(app[['url']], scriptRepo)
                        scriptItems <- readItems(app, scriptRepoUrl)
                        
                        # get scheduler script for actuator exec
                        schedulerActuatorScript <- scriptItems[
                                scriptItems$name == 'actuator_exec', ]
                        if(nrow(schedulerActuatorScript) > 1){
                                lapply(schedulerActuatorScript$id,
                                       function(x) deleteItem(app, 
                                                              scriptRepoUrl,
                                                              as.character(x)))
                                schedulerActuatorScript <- data.frame()
                        }
                        
                        # write scripts
                        scriptData <- list(name='actuator_exec',
                                           script=actuatorScript)
                        scriptData$`_oydRepoName` <- 'Raumklima-Skript'
                        
                        if(nrow(schedulerActuatorScript) == 0){
                                writeItem(app, scriptRepoUrl, scriptData)
                        } else {
                                updateItem(app, scriptRepoUrl, scriptData,
                                           schedulerActuatorScript$id)
                        }
                }
        }
})

# show attributes on selecting an item in the Sensor list
observeEvent(input$actuatorList, {
        selItem <- input$actuatorList
        if(length(selItem) > 1){
                selItem <- selItem[1]
                updateSelectInput(session, 'actuatorList', selected = selItem)
        }
        allItems <- readActuatorItems()
        selItemName <- selItem
        selItemScenario <- allItems[rownames(allItems) == selItem, 'scenario']
        selItemParameters <- allItems[rownames(allItems) == selItem, 'params']
        selItemCommand <- allItems[rownames(allItems) == selItem, 'command']
        selItemActive <- allItems[rownames(allItems) == selItem, 'active']
        updateTextInput(session, 'actuatorItemName',
                        value = selItemName)
        updateSelectInput(session, 'actuatorItemScenario',
                        selected = selItemScenario)
        updateTextInput(session, 'actuatorItemParameters',
                        value = selItemParameters)
        updateTextInput(session, 'actuatorItemCommand',
                        value = selItemCommand)
        updateCheckboxInput(session, 'actuatorItemActive',
                            value = selItemActive)
})

observeEvent(input$addActuatorItem, {
        errMsg   <- ''
        itemName <- input$actuatorItemName
        itemScenario <- input$actuatorItemScenario
        itemParameters <- input$actuatorItemParameters
        itemCommand <- input$actuatorItemCommand
        itemActive <- input$actuatorItemActive
        allItems <- readActuatorItems()
        if(itemName %in% rownames(allItems)){
                errMsg <- 'Name bereits vergeben'
        }
        if(errMsg == ''){
                app <- currApp()
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.actuator'))
                data <- list(name     = itemName,
                             scenario = itemScenario,
                             params   = itemParameters,
                             command  = itemCommand,
                             active   = itemActive) 
                data$`_oydRepoName` <- "Aktoren"
                writeItem(app, url, data)
                initNames <- rownames(allItems)
                allItems$scenario <- as.character(allItems$scenario)
                allItems$params <- as.character(allItems$params)
                allItems$command <- as.character(allItems$command)
                allItems$active <- as.logical(allItems$active)
                allItems <- rbind(allItems, c(itemScenario, 
                                              itemParameters,
                                              itemCommand,
                                              itemActive))
                
                updateSelectInput(session, 'actuatorList',
                                  choices = c(initNames, itemName),
                                  selected = NA)
                updateTextInput(session, 'actuatorItemName',
                                value = '')
                updateSelectInput(session, 'actuatorItemScenario',
                                  selected = NA)
                updateTextInput(session, 'actuatorItemParameters',
                                value = '')
                updateTextInput(session, 'actuatorItemCommand',
                                value = '')
                updateTextInput(session, 'actuatorItemActive',
                                value = FALSE)
        }
        closeAlert(session, 'myActuatorItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'myActuatorItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
})

observeEvent(input$updateActuatorItem, {
        errMsg   <- ''
        selItem <- input$actuatorList
        itemName <- input$actuatorItemName
        itemScenario <- input$actuatorItemScenario
        itemParameters <- input$actuatorItemParameters
        itemCommand <- input$actuatorItemCommand
        itemActive <- input$actuatorItemActive
        if(is.null(selItem)){
                errMsg <- 'Keine Aktion ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readActuatorItems()
                app <- currApp()
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.actuator'))
                data <- list(name     = itemName,
                             scenario = itemScenario,
                             params   = itemParameters,
                             command  = itemCommand,
                             active   = itemActive)
                actuatorItems <- readItems(app, url)
                id <- actuatorItems[actuatorItems$name == selItem, 'id']
                updateItem(app, url, data, id)
                newRowNames <- rownames(allItems)
                newRowNames[newRowNames == selItem] <- itemName
                updateSelectInput(session, 'actuatorList',
                                  choices = newRowNames,
                                  selected = NA)
                updateTextInput(session, 'actuatorItemName',
                                value = '')
                updateSelectInput(session, 'actuatorItemScenario',
                                  selected = NA)
                updateTextInput(session, 'actuatorItemParameters',
                                value = '')
                updateTextInput(session, 'actuatorItemCommand',
                                value = '')
                updateTextInput(session, 'actuatorItemActive',
                                value = FALSE)
        }
        closeAlert(session, 'myActuatorItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'myActuatorItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
})

observeEvent(input$delActuatorList, {
        errMsg   <- ''
        selItem <- input$actuatorList
        if(is.null(selItem)){
                errMsg <- 'Keine Aktion ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readActuatorItems()
                newRowNames <- rownames(allItems)
                app <- currApp()
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.actuator'))
                actuatorItems <- readItems(app, url)
                id <- actuatorItems[actuatorItems$name == selItem, 'id']
                deleteItem(app, url, id)
                newRowNames <- newRowNames[newRowNames != selItem]
                allItems <- allItems[rownames(allItems) != selItem, ]
                updateSelectInput(session, 'actuatorList',
                                  choices = newRowNames,
                                  selected = NA)
                updateTextInput(session, 'actuatorItemName',
                                value = '')
                updateSelectInput(session, 'actuatorItemScenario',
                                  selected = NA)
                updateTextInput(session, 'actuatorItemParameters',
                                value = '')
                updateTextInput(session, 'actuatorItemCommand',
                                value = '')
                updateTextInput(session, 'actuatorItemActive',
                                value = FALSE)
        }
        closeAlert(session, 'mySensorItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'mySensorItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
})

observeEvent(input$runActuatorList, {
        errMsg <- ''
        succMsg <- ''
        selItem <- input$actuatorList
        if(is.null(selItem)){
                errMsg <- 'Keine Aktion ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readActuatorItems()
                selItemName <- selItem
                selItemCommand <- allItems[rownames(allItems) == selItem, 
                                           'command']
                pcs <- strsplit(as.character(selItemCommand), "\\s+")[[1]]
                cmd <- pcs[1]
                params <- pcs[2:length(pcs)]
                system2(cmd, params)
                succMsg <- paste0('Befehl [', 
                                 paste(pcs, collapse = ' '), 
                                 '] ausgeführt.')
        }
        closeAlert(session, 'myActuatorItemStatus')
        if(errMsg != ''){
                createAlert(session, 'taskInfo', 
                            'myActuatorItemStatus',
                            title = 'Achtung',
                            content = errMsg,
                            style = 'warning',
                            append = 'false')
        }
        if(succMsg != ''){
                createAlert(session, 'taskInfo', 
                            'myActuatorItemStatus',
                            title = 'Aktion erfolgreich',
                            content = succMsg,
                            style = 'info',
                            append = 'false')
        }
})