# configure data import from NAGIOS
# last update: 2016-10-12

observe({
        if(is.null(input$sensorList)){
                allItems <- readNagiosItems()
                updateSelectInput(session, 'sensorList',
                                  choices = rownames(allItems))
                
                # check if periodic Nagios Import is scheduled
                schedulerItems <- readSchedulerItems()
                rScript <- toString(nagiosImportScript)
                app <- currApp()
                if(length(app) > 0){
                        replace = list(pia_url    = app[['url']], 
                                       app_key    = app[['app_key']],
                                       app_secret = app[['app_secret']])
                        parameters <- list(
                                Rscript_base64=rScript,
                                replace=replace)
                        config <- list(repo=app[['app_key']],
                                       time='* * * * *',
                                       task='Rscript',
                                       parameters=parameters)
                        if(is.null(schedulerItems[['id']])) {
                                writeItem(app,
                                          itemsUrl(app[['url']], scheduler_id),
                                          config)
                        } else {
                                updateItem(app,
                                           itemsUrl(app[['url']], scheduler_id),
                                           config,
                                           schedulerItems[['id']])
                        }
                }
        }
})

# get stored Sensors in Nagios
readNagiosItems <- function(){
        app <- currApp()
        sensorItems <- data.frame()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.nagios'))
                sensorItems <- readItems(app, url)
                if(nrow(sensorItems) > 0){
                        rownames(sensorItems) <- sensorItems$name
                        sensorItems <- sensorItems[, c('nagiosUrl',
                                                       'repo')]
                }
        }
        sensorItems
}

# show attributes on selecting an item in the Sensor list
observeEvent(input$sensorList, {
        selItem <- input$sensorList
        if(length(selItem)>1){
                selItem <- selItem[1]
                updateSelectInput(session, 'sensorList', selected = selItem)
        }
        allItems <- readNagiosItems()
        selItemName <- selItem
        selItemNagiosUrl <- allItems[rownames(allItems) == selItem, 'nagiosUrl']
        selItemRepo <- allItems[rownames(allItems) == selItem, 'repo']
        updateTextInput(session, 'sensorItemName',
                        value = selItemName)
        updateTextInput(session, 'sensorItemNagiosUrl',
                        value = trim(as.character(selItemNagiosUrl)))
        updateTextInput(session, 'sensorItemRepo',
                        value = trim(as.character(selItemRepo)))
})

observeEvent(input$addSensorItem, {
        errMsg   <- ''
        itemName <- input$sensorItemName
        itemNagiosUrl <- input$sensorItemNagiosUrl
        itemRepo <- input$sensorItemRepo
        allItems <- readNagiosItems()
        if(itemName %in% rownames(allItems)){
                errMsg <- 'Name bereits vergeben'
        }
        if(errMsg == ''){
                app <- currApp()
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.nagios'))
                data <- list(name      = itemName,
                             nagiosUrl = itemNagiosUrl,
                             repo      = itemRepo)
                writeItem(app, url, data)
                initNames <- rownames(allItems)
                allItems$nagiosUrl <- as.character(allItems$nagiosUrl )
                allItems$repo <- as.character(allItems$repo)
                allItems <- rbind(allItems, c(itemNagiosUrl, 
                                              itemRepo))
                
                updateSelectInput(session, 'sensorList',
                                  choices = c(initNames, itemName),
                                  selected = NA)
                updateTextInput(session, 'sensorItemName',
                                value = '')
                updateTextInput(session, 'sensorItemNagiosUrl',
                                value = '')
                updateTextInput(session, 'sensorItemRepo',
                                value = '')
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

observeEvent(input$updateSensorItem, {
        errMsg   <- ''
        selItem <- input$sensorList
        itemName <- input$sensorItemName
        itemNagiosUrl <- input$sensorItemNagiosUrl
        itemRepo <- input$sensorItemRepo
        if(is.null(selItem)){
                errMsg <- 'Keine Sensor ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readNagiosItems()
                app <- currApp()
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.nagios'))
                data <- list(name      = itemName,
                             nagiosUrl = itemNagiosUrl,
                             repo      = itemRepo)
                sensorItems <- readItems(app, url)
                id <- sensorItems[sensorItems$name == selItem, 'id']
                updateItem(app, url, data, id)
                newRowNames <- rownames(allItems)
                newRowNames[newRowNames == selItem] <- itemName
                updateSelectInput(session, 'sensorList',
                                  choices = newRowNames,
                                  selected = NA)
                updateTextInput(session, 'sensorItemName',
                                value = '')
                updateTextInput(session, 'sensorItemNagiosUrl',
                                value = '')
                updateTextInput(session, 'sensorItemRepo',
                                value = '')
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

observeEvent(input$delSensorList, {
        errMsg   <- ''
        selItem <- input$sensorList
        if(is.null(selItem)){
                errMsg <- 'Kein Sensor ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readNagiosItems()
                newRowNames <- rownames(allItems)
                app <- currApp()
                url <- itemsUrl(app[['url']], 
                                paste0(app[['app_key']],
                                       '.nagios'))
                sensorItems <- readItems(app, url)
                id <- sensorItems[sensorItems$name == selItem, 'id']
                deleteItem(app, url, id)
                newRowNames <- newRowNames[newRowNames != selItem]
                allItems <- allItems[rownames(allItems) != selItem, ]
                updateSelectInput(session, 'sensorList',
                                  choices = newRowNames,
                                  selected = NA)
                updateTextInput(session, 'sensorItemName',
                                value = '')
                updateTextInput(session, 'sensorItemNagiosUrl',
                                value = '')
                updateTextInput(session, 'sensorItemRepo',
                                value = '')
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

observeEvent(input$testNagiosUrl, {
        session$sendCustomMessage(type='openUrlInNewTab',
                                  input$sensorItemNagiosUrl)
})