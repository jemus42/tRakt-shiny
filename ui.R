#### Shiny UI ####

shinyUI(fluidPage(
  
  pageWithSidebar(
    headerPanel(title = "tRakt"),
    
    sidebarPanel(
      h2("Show Selection"),
      textInput(inputId = "show.query", label = "Enter the name of a show", value = "FLCL"),
      actionButton(inputId = "get.show", label = "PLOTERIZZLE"),
      h3("Plot Options"),
      radioButtons(inputId = "btn.scale.x", label = "Scale: x-Axis",
                   choices = c("Totoal Episode Numbers" = "epnum",
                               "Airdate" = "firstaired.posix"),
                   selected = "epnum")
      ),
    
    mainPanel(
      h2(htmlOutput("debug.show.name")),
      ggvisOutput(plot_id = "ggvis")
      )
  ),
  includeMarkdown("about.md")
))
