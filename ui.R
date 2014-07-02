#### Shiny UI ####

shinyUI(fluidPage(
  
  pageWithSidebar(
    headerPanel(title = "tRakt"),
    
    sidebarPanel(
      h2("Show selection"),
      textInput(inputId = "show.query", label = "Show name", value = "FLCL"),
      actionButton(inputId = "get.show", label = "PLOTERIZZLE")
      ),
    
    mainPanel(
      h2(htmlOutput("debug.show.name")),
      ggvisOutput(plot_id = "ggvis")
      )
  ),
  includeMarkdown("about.md")
))
