library(dygraphs)
library(datasets)
library(rgdal)
library(rjson)
library(maptools)
shinyServer(function(input, output) {

  url ="https://envirocar.org/api/stable/tracks/56d9dc80e4b0b5e23789124a"
  
  importEnviroCar = function(file) {
    # spCbind
    # read data as spatial object:
    layer = readOGR(file, layer = "OGRGeoJSON")
    # convert time from text to POSIXct:
    layer$time = as.POSIXct(layer$time, format = "%Y-%m-%dT%H:%M:%S")
    # the third column is JSON, we want it in a table (data.frame) form: 1. form
    # a list of lists
    l1 = lapply(as.character(layer[[3]]), fromJSON)
    # 2. parse the $value elements in the sublist:
    l2 = lapply(l1, function(x) as.data.frame(lapply(x, function(X) X$value)))
    # bind these value elements, row by row, together
    ret = do.call(rbind, l2)
    # read the units:
    units = lapply(l1[1], function(x) as.data.frame(lapply(x, function(X) X$unit)))
    # add a units attribute to layer
    layer[[3]] = NULL
    # add the table as attributes to the spatial object
    if (length(layer) == nrow(ret)) {
      layer = spCbind(layer, ret)
      attr(layer, "units") = units[[1]]
      layer
    } else NULL
  }
  sp = importEnviroCar(url)
  predicted <- reactive({
   
    
    data1=sp[,input$param1]
    data2=sp[,input$param2]
    d3=sp[,"time"]
    d3=d3[[1]]
    d1=data1[[1]]
    d2=data2[[1]]
    speedtime1=data.frame(d1,d3)
    speedtime2=data.frame(d2,d3)
    speedtime1.ts <- xts(speedtime1$d1, order.by=speedtime1$d3)
    speedtime2.ts <- xts(speedtime2$d2, order.by=speedtime2$d3)
    combspeed <- cbind(speedtime1.ts,speedtime2.ts)
  })
  
  output$dygraph <- renderDygraph({
    dygraph(predicted())  %>%
    dySeries("..1", label = input$param1) %>%
      dySeries("..2", label = input$param2) %>%
      dyOptions(stackedGraph = TRUE) %>%
      dyRangeSelector(height = 20)
  })
 
  
})