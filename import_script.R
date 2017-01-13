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
writeItem <- function(app, repo_url, item) {
  headers <- defaultHeaders(app[['token']])
  data <- rjson::toJSON(item)
  response <- tryCatch(
    RCurl::postForm(repo_url, .opts=list(httpheader = headers, postfields = data)),
    error = function(e) { 
      return(NA) })
  response
}
updateItem <- function(app, repo_url, item, id) {
  headers <- defaultHeaders(app[['token']])
  item <- c(item, c(id=as.numeric(id)))
  data <- rjson::toJSON(item)
  response <- tryCatch(
    RCurl::postForm(repo_url, .opts=list(httpheader = headers, postfields = data)),
    error = function(e) { return(NA) })
  response
}
deleteItem <- function(app, repo_url, id){
  headers <- defaultHeaders(app[['token']])
  item_url <- paste0(repo_url, '/', id)
  response <- tryCatch(
    httr::DELETE(item_url, add_headers(headers)),
    error = function(e) { return(NA) })
  response
}
importNagios <- function(nagiosUrl, app, repo, repoName, nagiosUser, nagiosPwd){
  cnt <- 0
  hdl <- RCurl::getURL(nagiosUrl, userpwd=paste(nagiosUser, nagiosPwd, sep = ':'), httpauth = 1L, ssl.verifypeer = FALSE, ssl.verifyhost = FALSE)
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
      data_url <- itemsUrl(app[['url']], repo)
      pia_data <- readItems(app, data_url)
      if(nrow(data) > 0) {
        if(nrow(pia_data) > 0){
          mrg_data <- merge(data, pia_data, by.x='seq', by.y='timestamp', all = TRUE)
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
      upd_items <- mrg_data[(mrg_data$val != mrg_data$value) & !is.na(mrg_data$id), c('id', 'seq', 'val')]
      upd_items <- upd_items[complete.cases(upd_items), ]
      if (nrow(upd_items) > 0) {
        invisible(apply(upd_items, 1, function(x) {
          cnt <- cnt + 1
          item <- list(timestamp = x[['seq']],
                       value     = x[['val']])
          dummy <- updateItem(app, data_url, item, x[['id']])
        }))
      }
      new_items <- mrg_data[(!is.na(mrg_data$val) & is.na(mrg_data$value)), c('seq', 'val')]
      if (nrow(new_items) > 0) {
        invisible(apply(new_items, 1, function(x) {
          cnt <<- cnt + 1
          item <- list(timestamp = x[['seq']], value = x[['val']], '_oydRepoName' = repoName)
          writeItem(app, data_url, item)
        }))
      }
    }
  }
  cnt
}

pia_url <- '[pia_url]'
app_key <- '[app_key]'
app_secret <- '[app_secret]'
app <- setupApp(pia_url, app_key, app_secret)
url <- itemsUrl(pia_url, 'eu.ownyourdata.room.nagios')
sensors <- readItems(app, url)
for (i in 1:nrow(sensors)){
  importNagios(as.character(sensors[i, 'nagiosUrl']), app, as.character(sensors[i, 'repo']), as.character(sensors[i, 'name']), as.character(sensors[i, 'user']), as.character(sensors[i, 'password']))
}