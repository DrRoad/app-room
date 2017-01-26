defaultHeaders <- function(token) {
  c('Accept'        = '*/*', 'Content-Type'  = 'application/json', 'Authorization' = paste('Bearer', token))
}
itemsUrl <- function(url, repo_name) {
  paste0(url, '/api/repos/', repo_name, '/items')
}
getToken <- function(pia_url, app_key, app_secret) {
  auth_url <- paste0(pia_url, '/oauth/token')
  optTimeout <- RCurl::curlOptions(connecttimeout = 10)
  response <- tryCatch(
    RCurl::postForm(auth_url, client_id = app_key, client_secret = app_secret, grant_type = 'client_credentials', .opts = optTimeout),
    error = function(e) { return(NA) })
  if (is.na(response)) {
    return(NA)
  } else {
    if(jsonlite::validate(response[1])){
      return(rjson::fromJSON(response[1])$access_token)
    } else {
      return(NA)
    }
  }
}
setupApp <- function(pia_url, app_key, app_secret) {
  app_token <- getToken(pia_url, app_key, app_secret)
  if(is.na(app_token)){
    vector()
  } else {
    c('url' = pia_url, 'app_key' = app_key, 'app_secret' = app_secret, 'token' = app_token)
  }
}
r2d <- function(response){
  if (is.na(response)) {
    data.frame()
  } else {
    if (nchar(response) > 0) {
      retVal <- rjson::fromJSON(response)
      if(length(retVal) == 0) {
        data.frame()
      } else {
        if ('error' %in% names(retVal)) {
          data.frame()
        } else {
          if (!is.null(retVal$message)) {
            if (retVal$message == 
                'error.accessDenied') {
              data.frame()
            } else {
              do.call(rbind, lapply(retVal, data.frame))
            }
          } else {
            do.call(rbind, lapply(retVal, data.frame))
          }
        }
      }
    } else {
      data.frame()
    }
  }
}
readItems <- function(app, repo_url) {
  if (length(app) == 0) {
    data.frame()
    return()
  }
  headers <- defaultHeaders(app[['token']])
  url_data <- paste0(repo_url, '?size=2000')
  header <- RCurl::basicHeaderGatherer()
  doc <- tryCatch(
    RCurl::getURI(url_data, .opts=list(httpheader = headers), headerfunction = header$update),
    error = function(e) { return(NA) })
  response <- NA
  respData <- data.frame()
  if(!is.na(doc)){
    recs <- tryCatch(
      as.integer(header$value()[['X-Total-Count']]),
      error = function(e) { return(0)})
    if(recs > 2000) {
      for(page in 0:floor(recs/2000)){
        url_data <- paste0(repo_url,
                           '?page=', page,
                           '&size=2000')
        response <- tryCatch(
          RCurl::getURL(url_data,
                        .opts=list(httpheader=headers)),
          error = function(e) { return(NA) })
        subData <- r2d(response)
        if(nrow(respData)>0){
          respData <- rbind(respData, subData)
        } else {
          respData <- subData
        }
      }
    } else {
      response <- tryCatch(
        RCurl::getURL(url_data, .opts=list(httpheader = headers)),
        error = function(e) { return(NA) })
      respData <- r2d(response)
    }
  }
  respData
}
getSensorData <- function(sensor, sensors){
  url <- as.character(sensors[sensors$name == sensor, 'nagiosUrl'])
  repo <- as.character(sensors[sensors$name == sensor, 'repo'])
  user <- as.character(sensors[sensors$name == sensor, 'user'])
  pwd <- as.character(sensors[sensors$name == sensor, 'password'])
  value <- NA
  hdl <- RCurl::getURL(url, userpwd=paste(user, pwd, sep = ':'), httpauth = 1L, ssl.verifypeer = FALSE, ssl.verifyhost = FALSE)
  if(typeof(hdl) == 'character') {
    if(jsonlite::validate(hdl)){
      raw <- jsonlite::fromJSON(hdl)
      meta <- raw[1]$meta
      rows <- raw[2]$data$row
      seq <- as.integer(meta$start) +
        (1:as.integer(meta$rows))*as.integer(meta$step)
      val <- lapply(rows$v, function(x){ as.numeric(x[1]) })
      data <- as.data.frame(cbind(seq, val))
      data <- data.frame(matrix(unlist(data), nrow=nrow(data), byrow=F))
      data <- data[complete.cases(data), ]
      colnames(data) <- c('seq', 'val')
      data <- data[with(data, order(-seq)), ]
      value <- data[1, 'val']
    }
  }
  value
}

pia_url <- '[pia_url]'
app_key <- '[app_key]'
app_secret <- '[app_secret]'
app <- setupApp(pia_url, app_key, app_secret)
url <- itemsUrl(pia_url, 'eu.ownyourdata.room.nagios')
sensors <- readItems(app, url)
url <- itemsUrl(pia_url, 'eu.ownyourdata.room.actuator')
actuators <- readItems(app, url)
if(nrow(actuators) > 0){
  for (i in 1:nrow(actuators)){
    sensor <- rjson::fromJSON(as.character(actuators[i, 'params']))$sensor
    compare <- rjson::fromJSON(as.character(actuators[i, 'params']))$compare
    value <- rjson::fromJSON(as.character(actuators[i, 'params']))$value
    sensorValue <- getSensorData(sensor, sensors)
    runAction = FALSE
    switch(compare,
       greater={
         cat(paste(sensor, sensorValue, '>', value))
         if(!is.na(sensorValue) & sensorValue > value){
           runAction = TRUE
           cat(' TRUE!')
         }
       },
       equal={
         cat(paste(sensor, sensorValue, '=', value))
         if(!is.na(sensorValue) & sensorValue == value){
           runAction = TRUE
           cat(' TRUE!')
         }
       },
       less={
         cat(paste(sensor, sensorValue, '<', value))
         if(!is.na(sensorValue) & sensorValue == value){
           runAction = TRUE
           cat(' TRUE!')
         }
       }
    )
    if(runAction){
      system(as.character(actuators[i, 'command']))
    }
    cat("\n")
  }
}
