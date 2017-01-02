# configure data import from NAGIOS
# last update: 2016-10-12

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
                                                       'repo',
                                                       'user',
                                                       'password',
                                                       'active')]
                }
        }
        sensorItems
}

# executed on Start
observe({
        if(is.null(input$sensorList)){
                sensorList()
                allItems <- readNagiosItems()
                updateSelectInput(session, 'sensorList',
                                  choices = rownames(allItems))
                
                # check if periodic Nagios Import is scheduled and script is
                # available
                app <- currApp()
                if(length(app) > 0){
                        schedulerItems <- readSchedulerItems()
                        replace = list(pia_url    = app[['url']], 
                                       app_key    = app[['app_key']],
                                       app_secret = app[['app_secret']])
                        parameters <- list(
                                Rscript_reference = 'nagios_import',
                                Rscript_repo = scriptRepo,
                                replace=replace)
                        config <- list(app=app[['app_key']],
                                       time='0 */2 * * *',
                                       task='Rscript',
                                       parameters=parameters)
                        config$`_oydRepoName` <- 'Scheduler'
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
                        scriptRepoUrl <- itemsUrl(app[['url']], scriptRepo)
                        scriptItems <- readItems(app, scriptRepoUrl)
                        scriptData <- list(name='nagios_import',
                                     script=nagiosImportScript)
                        scriptData$`_oydRepoName` <- 'Raumklima-Skript'
                        if (nrow(scriptItems) == 0){
                                writeItem(app,
                                          scriptRepoUrl,
                                          scriptData)
                        }
                        if (nrow(scriptItems) == 1){
                                updateItem(app,
                                           scriptRepoUrl,
                                           scriptData,
                                           scriptItems[['id']])
                        }
                }
        }
})

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
        selItemUser <- allItems[rownames(allItems) == selItem, 'user']
        selItemPassword <- allItems[rownames(allItems) == selItem, 'password']
        selItemActive <- allItems[rownames(allItems) == selItem, 'active']
        updateTextInput(session, 'sensorItemName',
                        value = selItemName)
        updateTextInput(session, 'sensorItemNagiosUrl',
                        value = trim(as.character(selItemNagiosUrl)))
        updateTextInput(session, 'sensorItemRepo',
                        value = trim(as.character(selItemRepo)))
        updateTextInput(session, 'sensorItemUser',
                        value = trim(as.character(selItemUser)))
        updateTextInput(session, 'sensorItemPassword',
                        value = trim(as.character(selItemPassword)))
        updateCheckboxInput(session, 'sensorItemActive',
                        value = selItemActive)
})

observeEvent(input$addSensorItem, {
        errMsg   <- ''
        itemName <- input$sensorItemName
        itemNagiosUrl <- input$sensorItemNagiosUrl
        itemRepo <- input$sensorItemRepo
        itemUser <- input$sensorItemUser
        itemPassword <- input$sensorItemPassword
        itemActive <- input$sensorItemActive
        
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
                             repo      = itemRepo,
                             user      = itemUser,
                             password  = itemPassword,
                             active    = itemActive)
                data$`_oydRepoName` <- 'NAGIOS Import'
                writeItem(app, url, data)
                initNames <- rownames(allItems)
                allItems$nagiosUrl <- as.character(allItems$nagiosUrl )
                allItems$repo <- as.character(allItems$repo)
                allItems$user <- as.character(allItems$user)
                allItems$password <- as.character(allItems$password)
                allItems$active <- as.logical(allItems$active)
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
                updateTextInput(session, 'sensorItemUser',
                                value = '')
                updateTextInput(session, 'sensorItemPassword',
                                value = '')
                updateCheckboxInput(session, 'sensorItemActive',
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

observeEvent(input$updateSensorItem, {
        errMsg   <- ''
        selItem <- input$sensorList
        itemName <- input$sensorItemName
        itemNagiosUrl <- input$sensorItemNagiosUrl
        itemRepo <- input$sensorItemRepo
        itemUser <- input$sensorItemUser
        itemPassword <- input$sensorItemPassword
        itemActive <- input$sensorItemActive
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
                             repo      = itemRepo,
                             user      = itemUser,
                             password  = itemPassword,
                             active    = itemActive)
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
                updateTextInput(session, 'sensorItemUser',
                                value = '')
                updateTextInput(session, 'sensorItemPassword',
                                value = '')
                updateCheckboxInput(session, 'sensorItemActive',
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
                updateTextInput(session, 'sensorItemUser',
                                value = '')
                updateTextInput(session, 'sensorItemPassword',
                                value = '')
                updateCheckboxInput(session, 'sensorItemActive',
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

observeEvent(input$testNagiosUrl, {
        session$sendCustomMessage(type='openUrlInNewTab',
                                  input$sensorItemNagiosUrl)
})

observeEvent(input$importSensorList, {
        errMsg <- ''
        succMsg <- ''
        selItem <- input$sensorList
        if(is.null(selItem)){
                errMsg <- 'Kein Sensor ausgewählt.'
        }
        if(errMsg == ''){
                allItems <- readNagiosItems()
                selItemName <- selItem
                selItemNagiosUrl <- as.character(trim(
                        allItems[rownames(allItems) == selItem, 'nagiosUrl']))
                selItemRepo <- as.character(trim(
                        allItems[rownames(allItems) == selItem, 'repo']))
                selItemUser <- as.character(trim(
                        allItems[rownames(allItems) == selItem, 'user']))
                selItemPwd <- as.character(trim(
                        allItems[rownames(allItems) == selItem, 'password']))
                cnt <- importNagios(selItemNagiosUrl, 
                                    selItemRepo,
                                    selItemName,
                                    selItemUser,
                                    selItemPwd)
                succMsg <- paste(cnt, 'Datensätze importiert.')
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
        if(succMsg != ''){
                createAlert(session, 'taskInfo', 
                            'mySensorItemStatus',
                            title = 'Aktion erfolgreich',
                            content = succMsg,
                            style = 'info',
                            append = 'false')
        }
})

importNagios <- function(nagiosUrl, repo, repoName, nagiosUser, nagiosPwd){
        cnt <- 0
        # get data --------------------------------------
        #hdl  <- GET(nagiosUrl, authenticate(nagiosUser, nagiosPwd))
        hdl <- getURL(nagiosUrl, 
                      userpwd=paste(nagiosUser, nagiosPwd, sep = ':'),
                      httpauth = 1L, 
                      ssl.verifypeer = FALSE,
                      ssl.verifyhost = FALSE)
        #if(validate(content(hdl, "text"))) {
        #        raw  <- jsonlite::fromJSON(content(hdl, "text"))
        if(typeof(hdl) == 'character') {
                if(jsonlite::validate(hdl)){
                        raw <- jsonlite::fromJSON(hdl)
                        meta <- raw[1]$meta
                        rows <- raw[2]$data$row
                        seq <- as.numeric(rows$t)
                        val <- lapply(rows$v, function(x){ as.numeric(x[1]) })
                        # tmp <- unlist(raw$data$row)
                        # val <- as.numeric(tmp[seq(3, length(tmp), 3)])
                        # meta <- raw[1]$meta
                        # seq <- as.integer(meta$start) + 
                        #         (1:as.integer(meta$rows))*as.integer(meta$step)
                        data <- as.data.frame(cbind(seq, val))
                        # connect PIA ---------------------------------------------
                        app <- currApp()
                        data_url <- itemsUrl(app[['url']], repo)
                        pia_data <- readItems(app, data_url)
                        
                        # merge data
                        if(nrow(data) > 0) {
                                if(nrow(pia_data) > 0){
                                        mrg_data <- merge(data, pia_data, 
                                                          by.x='seq', by.y='timestamp',
                                                          all = TRUE)
                                } else {
                                        mrg_data <- data
                                        mrg_data$value <- NA
                                        mrg_data$id <- NA
                                }
                        } else {
                                if(nrow(pia_data) > 0){
                                        mrg_data <- pia_data
                                        mrg_data$val <- NA
                                } else {
                                        mrg_data <- data.frame()
                                }
                        }
                        
                        # what is different -> updateItem
                        upd_items <- mrg_data[(mrg_data$val != mrg_data$value) & 
                                                      !is.na(mrg_data$id), 
                                              c('id', 'seq', 'val')]
                        upd_items <- upd_items[complete.cases(upd_items), ]
                        if (nrow(upd_items) > 0) {
                                invisible(apply(
                                        upd_items,
                                        1,
                                        function(x) {
                                                cnt <- cnt + 1
                                                item <- list(timestamp = x[['seq']], 
                                                             value     = x[['val']])
                                                dummy <- updateItem(app, data_url, item, x[['id']])
                                        }
                                ))
                        }
                        
                        # what is new -> writeItem
                        new_items <- mrg_data[(!is.na(mrg_data$val) & 
                                                       is.na(mrg_data$value)), 
                                              c('seq', 'val')]
                        if (nrow(new_items) > 0) {
                                invisible(apply(
                                        new_items,
                                        1,
                                        function(x) {
                                                cnt <<- cnt + 1
                                                item <- list(timestamp = x[['seq']], 
                                                             value     = x[['val']])
                                                item$`_oydRepoName` <- repoName
                                                writeItem(app, data_url, item)
                                        }
                                ))
                        }
                }
        }
        cnt
}