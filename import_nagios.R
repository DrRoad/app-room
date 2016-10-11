# version 2016-08-17

# Comments
# - after download run:
#   Rscript setup.R
# - convert timestamp to date & time:
#   as.POSIXct(ts, origin="1970-01-01")
# - call script:
#   Rscript import_nagios.R --ip=abbb::ba27:ebff:fef1:8e19 --host=climateplus_6540 --service=temp --pia=http://localhost:8080 --key=eu.ownyourdata.nagios --secret=MlMX4W5hjghTYUzBknNq --repo=eu.ownyourdata.nagios.temp1
#   Rscript import_nagios.R --ip=abbb::ba27:ebff:fef1:8e19 --host=climateplus_6540 --service=temp --pia=http://192.168.1.209:8080 --key=eu.ownyourdata.nagios --secret=hLIikugcIVEfIbMbrcUB --repo=eu.ownyourdata.nagios.temp1
# script to import from Q
#   Rscript import_nagios.R --ip=iot.quintessenz.net:22080 --host=climateplus_5e3c --service=hum --pia=http://localhost:8080 --key=eu.ownyourdata.room --secret=yNl2aAzUvYKSFq7HsY9m --repo=eu.ownyourdata.room.hum1
#   Rscript import_nagios.R --ip=iot.quintessenz.net:22080 --host=climateplus_5e3c --service=temp --pia=http://localhost:8080 --key=eu.ownyourdata.room --secret=yNl2aAzUvYKSFq7HsY9m --repo=eu.ownyourdata.room.temp1

suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(tools))
suppressPackageStartupMessages(library(RCurl))
suppressWarnings(suppressPackageStartupMessages(library(jsonlite)))

# path handling
args <- commandArgs(trailingOnly = F)
scriptPath <- file_path_as_absolute(dirname(sub("--file=","",
                                                args[grep("--file",args)])))
setwd(scriptPath)

# include files
source(paste0(scriptPath, "/srvBase.R"))

# get options -----------------------------------
custom_options <- as.data.frame(matrix(unlist(strsplit(gsub("--", "", 
        args[grepl("--.*=.*", args)]), "=")), ncol=2, byrow=TRUE))

# IP address
ip <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "ip", ]) > 0) {
        ip <- as.character(
                custom_options[as.character(custom_options$V1) == "ip", "V2"])
}

# host
host <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "host", ]) > 0) {
        host <- as.character(
                custom_options[as.character(custom_options$V1) == "host", "V2"])
}

# service
service <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "service", ]) > 0) {
        service <- as.character(
                custom_options[as.character(custom_options$V1) == "service", "V2"])
}

# view
view <- "1"
if (nrow(custom_options[as.character(custom_options$V1) == "view", ]) > 0) {
        view <- as.character(
                custom_options[as.character(custom_options$V1) == "view", "V2"])
}

# PIA Url
pia_url <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "pia", ]) > 0) {
        pia_url <- as.character(
                custom_options[as.character(custom_options$V1) == "pia", "V2"])
}

# App Key
app_key <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "key", ]) > 0) {
        app_key <- as.character(
                custom_options[as.character(custom_options$V1) == "key", "V2"])
}

# App Secret
app_secret <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "secret", ]) > 0) {
        app_secret <- as.character(
                custom_options[as.character(custom_options$V1)=="secret", "V2"])
}

# Repo
repo <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "repo", ]) > 0) {
        repo <- as.character(
                custom_options[as.character(custom_options$V1)=="repo", "V2"])
}

# Nagios User for login
nagiosUser <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "user", ]) > 0) {
        nagiosUser <- as.character(
                custom_options[as.character(custom_options$V1)=="user", "V2"])
}

# Nagios Password for login
nagiosPwd <- ""
if (nrow(custom_options[as.character(custom_options$V1) == "pwd", ]) > 0) {
        nagiosPwd <- as.character(
                custom_options[as.character(custom_options$V1)=="pwd", "V2"])
}

# run in RStudio
"
setwd('~/cs/ownyourdata/apps/raumklima')
source('srvBase.R')
ip <- 'iot.quintessenz.net:22080'
host <- 'climateplus_5e3c'
service <- 'hum'
#service <- 'temp'
pia_url <- 'http://localhost:8080'
pia_url <- 'https://demo-pia.sloppy.zone'
app_key <- 'eu.ownyourdata.room'
app_secret <- 'yNl2aAzUvYKSFq7HsY9m'
app_secret <- 'y13s0LJzbzJZSGbAo9ge'
repo <- 'eu.ownyourdata.room.hum1'
#repo <- 'eu.ownyourdata.room.temp1'
view <- '2'
"


if ((nchar(ip) == 0) |
    (nchar(host) == 0) |
    (nchar(service) == 0) |
    (nchar(pia_url) == 0) |
    (nchar(app_key) == 0) |
    (nchar(app_secret) == 0) |
    (nchar(repo) == 0)){
        cat("Fehler: fehlende Argumente --ip, --host, --service, --pia, --key, --secret, --repo\n")
        quit()
}

# get data --------------------------------------
#source <- "http://[abbb::ba27:ebff:fef1:8e19]/mysite/pnp4nagios/xport/json?host=climateplus_6540&srv=temp"
source <- paste0("http://",
                 ip,
                 "/mysite/pnp4nagios/xport/json",
                 "?host=", host,
                 "&srv=", service,
                 "&view=", view)
hdl  <- GET(source, authenticate(nagiosUser, nagiosPwd))
if(validate(content(hdl, "text"))) {
        raw  <- jsonlite::fromJSON(content(hdl, "text"))
} else {
        cat("Fehler: keine gültigen Daten\n")
        quit()
}
tmp <- unlist(raw$data$row)
val <- as.numeric(tmp[seq(3, length(tmp), 3)])
# df   <- as.data.frame(t(as.matrix(as.data.frame(raw$data$row$v))))
# val  <- as.numeric(as.character(df[,3]))
meta <- raw[1]$meta

seq <- as.integer(meta$start) + (1:as.integer(meta$rows))*as.integer(meta$step)
data <- as.data.frame(cbind(seq, val))

cat(paste0('data from: ', 
           as.POSIXct(as.integer(meta$start), origin='1970-01-01'), 
           ' (', meta$start, ') to: ', 
           as.POSIXct(as.integer(meta$end), origin='1970-01-01'), 
           ' (', meta$end, ")\n"))

# connect PIA ---------------------------------------------
app <- setupApp(pia_url, app_key, app_secret)
data_url <- itemsUrl(pia_url, repo)
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

cnt <- 0
lastTs <- 0
lastVal <- NA

# what is different -> updateItem
upd_items <- mrg_data[(mrg_data$val != mrg_data$value) & 
                       !is.na(mrg_data$id), 
                      c('id', 'seq', 'val')]
upd_items <- upd_items[complete.cases(upd_items), ]
if (nrow(upd_items) > 0) {
        apply(
                upd_items,
                1,
                function(x) {
                        cnt <<- cnt + 1
                        if(x[['seq']] > lastTs) {
                                lastTs <<- x[['seq']]
                                lastVal <<- x[['val']]
                        }
                        item <- list(timestamp = x[['seq']], 
                                     value     = x[['val']])
                        dummy <- updateItem(app, data_url, item, x[['id']])
                }
        )
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
                        if(x[['seq']] > lastTs) {
                                lastTs <<- x[['seq']]
                                lastVal <<- x[['val']]
                        }
                        item <- list(timestamp = x[['seq']], 
                                     value     = x[['val']])
                        dummy <- writeItem(app, data_url, item)
                }
        ))
}

cat(paste0(cnt, " records processed\n"))
cat(paste0(as.POSIXct(lastTs, origin='1970-01-01'), ': ', lastVal, "\n"))

