#### Shiny UI ####
shinyUI(
  navbarPage(
    title = "tRakt", inverse = FALSE, theme = shinytheme("cosmo"),
    #### Main view ####
    tabPanel("Main",
      icon = icon("tasks"),
      tags$head(
        tags$meta(name = "google-site-verification", content = "fbD3_htmdCUtmrjbI1dAZbsS0sN-T10_U3xAN7W791Y"),
        includeHTML("html/proxy-click-js.html")
        #includeHTML("html/piwik.html")
      ),

      #### Episode information ####
      ## Show this when the actionButton was not clicked yet, marking the 'inactive' state
      # Used to be a clunky conditionalPanel, now just use shinyjs
      wellPanel(id = "intro-wellpanel", includeMarkdown("text/intro.md")),
      ## Show this only when the actionButton was clicked, marking the 'active' state

      hidden(
        wellPanel(
          id = "show_info",
          h2(htmlOutput("show_name")),
          fluidRow(
            column(2, htmlOutput("show_banner", inline = TRUE)),
            column(
              10,
              htmlOutput("show_overview"),
              htmlOutput("show_links"), br(),
              htmlOutput("show_ratings")
            )
          )
        )
      ),
      
      hidden(
        hr(),
        tabsetPanel(
          id = "episode_info", selected = "tab_plot"#,
          # tabPanel(
          #   title = "Plot", value = "tab_plot", icon = icon("bar-chart-o"),
          #   plotlyOutput(outputId = "episodeplot")
          # ),
          # tabPanel(
          #   title = "Episodes", value = "tab_data_episodes", icon = icon("table"),
          #   DT::dataTableOutput(outputId = "table_episodes")
          # ),
          # tabPanel(
          #   title = "Seasons", value = "tab_data_seasons", icon = icon("table"),
          #   DT::dataTableOutput(outputId = "table_seasons")
          # )
        )
      ),

      hr(),

      #### Control panel ####
      wellPanel(fluidRow(
        column(
          4,
          h3(icon("search"), "Show Selection"),
          tagAppendAttributes(
            selectizeInput(
              inputId = "shows_cached", label = "Select a show or enter a show title",
              choices = NULL, selected = NULL, 
              options = list(
                create = TRUE,
                placeholder = "Select a show from the cache"
              )
            ),
            `data-proxy-click` = "get_show"
          ),
          actionButton(inputId = "get_show", label = "PLOTERIZZLE", icon = icon("play"))
        ),
        column(
          4, h3(icon("cogs"), "Plot Options"),
          selectInput(
            inputId = "btn_scale_x_variable", label = "Select timeline format:",
            choices = btn.scale.x.choices, selected = "epnum"
          ),
          selectInput(
            inputId = "btn_scale_y_variable", label = "Select target variable:",
            choices = btn.scale.y.choices, selected = "rating"
          )
        ),
        column(
          4, h3(icon("cogs"), "Display Options"),
          conditionalPanel(
            condition = "input.btn_scale_y_variable != 'rating' ",
            checkboxInput(
              inputId = "btn_scale_y_zero", label = "Start y axis at zero",
              value = FALSE
            )
          ),
          conditionalPanel(
            condition = "input.btn_scale_y_variable == 'rating' ",
            checkboxInput(
              inputId = "btn_scale_y_range", label = "Scale Ratings 0 - 100%",
              value = FALSE
            )
          ), br(),
          checkboxGroupInput(
            inputId = "btn_trendlines", label = "Trendlines", inline = T,
            choices = c("Show", "Season"), selected = NULL
          )
        )
      )),
      hr(),
      fluidRow(
        column(6, includeMarkdown("text/footer.md"))
      )
    ),
    tabPanel(
      title = "About", icon = icon("question-circle"),
      fixedPage(
        column(6, includeMarkdown("README.md")),
        column(6, includeMarkdown("text/about.md"))
      )
    ),
    # Didn't know where else to put it, but this one's a biggie
    useShinyjs()
  ) # end of navbarPage
) # End of shinyUI
