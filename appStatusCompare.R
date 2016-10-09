# UI for showing comparison chart
# last update: 2016-10-08

appStatusCompare <- function(){
        tabPanel('Kurvenvergleich', br(),
                 appStatusSelect(),
                 bsAlert('dataStatus'),
                 plotlyOutput('compareChart')
        )
}