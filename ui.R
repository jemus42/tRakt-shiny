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
      selectInput(inputId = "btn.scale.x", label = "Select timeline format:",
                  choices = btn.scale.x.choices, selected = "epnum"),
      checkboxInput(inputId = "btn.scale.y", label = "Scale Ratings 0 - 100%",
                  value = FALSE)
      ),
    
    mainPanel(
      h2(htmlOutput("show.name")),
      textOutput("show.overview"),
      ggvisOutput(plot_id = "ggvis")
      )
  ),
  includeMarkdown("about.md")
))
