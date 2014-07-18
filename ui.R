#### Shiny UI ####

shinyUI(
  navbarPage(title = "tRakt", inverse = TRUE, responsive = TRUE, fluid = TRUE,
  
    #### Main view ####
    tabPanel("Main", icon = icon("tasks"),
      progressInit(),
      
      #### Episode information ####
      ## Show this when the actionButton was not clicked yet, marking the 'inactive' state
      conditionalPanel(condition = "input.get_show == 0",
        wellPanel(includeMarkdown("text/intro.md"))
      ),
      ## Show this only when the actionButton was clicked, marking the 'active' state
      conditionalPanel(condition = "input.get_show > 0 && output.show_name != ''",
        wellPanel(
          h2(htmlOutput("show_name")),
          fluidRow(
            column(2, htmlOutput("show_banner")),
            column(10, 
              htmlOutput("show_overview"), 
              htmlOutput("show_links"), br(),
              htmlOutput("show_ratings")
            )
          )
        ),
        hr(),
        # TODO: Make this default to device width somehow ¯\_(ツ)_/¯
        tabsetPanel(id = "mainPanel", selected = "tab_plot_ggvis",
          tabPanel(title = "Plot (ggvis)", value = "tab_plot_ggvis", icon = icon("bar-chart-o"),
                   ggvisOutput(plot_id = "ggvis")
          ),
          tabPanel(title = "Plot (nvd3)", value = "tab_plot_nvd3", icon = icon("bar-chart-o"),
                   chartOutput(outputId = "plot_nvd3", lib = "nvd3")
          ),
          tabPanel(title = "Episodes", value = "tab_data_episodes", icon = icon("table"),
                   dataTableOutput(outputId = "table_episodes")
          ),
          tabPanel(title = "Seasons", value = "tab_data_seasons", icon = icon("table"),
                   dataTableOutput(outputId = "table_seasons")
          )
        )
      ),

      hr(),
      
      #### Control panel ####
      inputPanel(
        column(3,
          h3(icon("search"), "Show Selection"),
          textInput(inputId = "show_query", label = "Search a show on trakt.tv", value = ""),
          br(),
          selectizeInput(inputId = "shows_cached", label = "Or select a cached show", 
                         choices = "Loading cache…", selected = NULL),
          actionButton(inputId = "get_show", label = "PLOTERIZZLE", icon = icon("play"))
        ),
        column(3, h3(icon("cogs"), "Plot Options"),
          selectInput(inputId = "btn_scale_x_variable", label = "Select timeline format:",
                      choices = btn.scale.x.choices, selected = "epnum"),
          selectInput(inputId = "btn_scale_y_variable", label = "Select target variable:",
                      choices = btn.scale.y.choices, selected = "rating")
        ),
        column(3, h3(icon("cogs"), "Display Options"),
          h5("Axis scales"),
          conditionalPanel(condition = "input.btn_scale_y_variable != 'rating' ",
            checkboxInput(inputId = "btn_scale_y_zero", label = "Start y axis at zero",
                          value = FALSE)
          ),
          conditionalPanel(condition = "input.btn_scale_y_variable == 'rating' ",
                           checkboxInput(inputId = "btn_scale_y_range", label = "Scale Ratings 0 - 100%",
                                         value = FALSE)
          ), br(),
          h5("Trendlines (WIP)"),
          checkboxGroupInput(inputId = "btn_trendlines", label = "", inline = T,
                             choices = c("Show", "Season"), selected = NULL)
        )
      ),
      hr(),
      includeMarkdown("text/footer.md"),
      # Clumsiest way of hiding a debug input element ever
      conditionalPanel(condition = "false", checkboxInput(inputId = "debug", label = ".", value = F)),
      conditionalPanel(condition = "input.debug",
        plotOutput(outputId = "usage_stats", width = "100%")
      )
    ),
    tabPanel(title = "About", icon = icon("question-circle"),
      fixedPage(
        column(8, includeMarkdown("text/about.md"))
      )
    )
  )
)
