#### Shiny UI ####

shinyUI(fluidPage(
  progressInit(),
  
  pageWithSidebar(
    headerPanel(title = "tRakt v0.1.4"),
    
    sidebarPanel(
      h2("Show Selection"),
      textInput(inputId = "show.query", label = "Enter the name of a show", value = "Firefly"),
      actionButton(inputId = "get.show", label = "PLOTERIZZLE"),
      h3("Plot Options"),
      radioButtons(inputId = "btn.scale.x", label = "Scale: x-Axis",
                   choices = btn.scale.x.choices,
                   selected = "epnum")
      ),
    
    mainPanel(
      h2(htmlOutput("show.name")),
      textOutput("show.overview"),
      ggvisOutput(plot_id = "ggvis")
      )
  ),
  includeMarkdown("about.md")
))
