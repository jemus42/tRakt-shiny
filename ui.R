#### Shiny UI ####

shinyUI(fluidPage(pageWithSidebar(
  headerPanel(title = "tRakt"),
  
  sidebarPanel(
    h2("Show selection"),
    textInput(inputId = "show.query", label = "Show name", value = NULL),
    actionButton(inputId = "get.show", label = "Get data")),
  
  mainPanel(
    uiOutput("ggvis_ui"),
    ggvisOutput("ggvis")
    )
)))
