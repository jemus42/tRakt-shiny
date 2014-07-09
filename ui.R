#### Shiny UI ####

shinyUI(
  navbarPage(title = "tRakt", inverse = TRUE, responsive = TRUE, fluid = TRUE,
    
    #### Main view ####
    tabPanel("Main", icon = icon("tasks"),
      progressInit(),
      
      #### Episode information ####
      conditionalPanel(condition = "input.get_show > 0",
        wellPanel(
          h2(htmlOutput("show.name")), br(),
          htmlOutput("show.banner"),
          h3("Show summary"),
          htmlOutput("show.overview")
        ),
        hr(),
        # TODO: Make this default to device width somehow ¯\_(ツ)_/¯
        tabsetPanel(id = "mainPanel", selected = "tab_plot",
          tabPanel(title = "Plot", value = "tab_plot", icon = icon("bar-chart-o"),
                   ggvisOutput(plot_id = "ggvis")
          ),
          tabPanel(title = "Data", value = "tab_data", icon = icon("table"),
                   dataTableOutput(outputId = "table.episodes")
          )
        )
      ),

      hr(),
      
      #### Control panel ####
      inputPanel(
        column(4,
          h3(icon("search"), "Show Selection"),
          textInput(inputId = "show_query", label = "Enter the name of a show", value = "Firefly"),
          br(),
          actionButton(inputId = "get_show", label = "PLOTERIZZLE", icon = icon("play"))
        ),
        column(4, offset = 1,
          h3(icon("cogs"), "Plot Options"), 
          selectInput(inputId = "btn_scale_x_variable", label = "Select timeline format:",
                      choices = btn.scale.x.choices, selected = "epnum"),
          selectInput(inputId = "btn_scale_y_variable", label = "Select target variable:",
                      choices = btn.scale.y.choices, selected = "rating"),
          conditionalPanel(condition = "input.btn_scale_y_variable == 'rating' ",
            checkboxInput(inputId = "btn_scale_y_range", label = "Scale Ratings 0 - 100%",
                          value = FALSE)
          )
        )
      ),
      hr(),
      h5("tRakt version 0.1.18"),
      p("Updates in", tags$a(href = "http://pants.jemu.name//tag/trakt_shiny", "my #pants"))
    ),
    tabPanel(title = "About", icon = icon("question-circle"),
      fixedPage(
        column(4, includeMarkdown("about.md"))
      )
    )
  )
)
