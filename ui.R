#### Shiny UI ####

shinyUI(fluidPage(pageWithSidebar(
  headerPanel(title = "tRakt"),
  
  sidebarPanel(
    h2("Show selection"),
    textInput(inputId = "show.query", label = "Show name", value = "FLCL"),
    actionButton(inputId = "get.show", label = "Get data")
    ),
  
  mainPanel(
    textOutput("debug.show.name"),
    ggvisOutput("ggvis")
    )
)))
