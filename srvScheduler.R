# functions for setting up recurring tasks
# last update:2016-10-13

readSchedulerItems <- function(){
        app <- currApp()
        if(length(app) > 0){
                url <- itemsUrl(app[['url']], scheduler_id)
                readItems(app, url)
        } else {
                data.frame()
        }
}