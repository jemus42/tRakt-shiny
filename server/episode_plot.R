#### Episode plotting code ####
# This is done in observe(), for some actionButton reactivity reason
observe({
  if (!(isActive())){return(NULL)}
  # The 0 - 100 range thing should only be active for ratings
  if (input$btn_scale_y_range && input$btn_scale_y_variable != "rating"){
    updateCheckboxInput(session, inputId = "btn_scale_y_range", value = FALSE)
  } else if (input$btn_scale_y_zero && input$btn_scale_y_variable == "rating"){
    updateCheckboxInput(session, inputId = "btn_scale_y_zero", value = FALSE)
  }
  show    <- isolate(show())
  if (is.null(show)){return(NULL)}
  label_x <- names(btn.scale.x.choices[btn.scale.x.choices == input$btn_scale_x_variable])
  label_y <- names(btn.scale.y.choices[btn.scale.y.choices == input$btn_scale_y_variable])
  var_x   <- input$btn_scale_x_variable
  var_y   <- input$btn_scale_y_variable
  
  #### ggvis object creation starts here ####
  # use as.name() to circumvent ~ usage with variables
  plot <- show$episodes %>% ggvis(x    = as.name(var_x),
                                  y    = as.name(var_y),
                                  fill = ~season)
  plot <- plot %>% layer_points(key := ~tooltip, size.hover := 200, 
                                stroke := NA, stroke.hover := "black", strokeWidth := 2)
  if ("Show" %in% input$btn_trendlines){
    plot <- plot %>% layer_model_predictions(model = "lm", se = F, stroke := "black")
  }
  if ("Season" %in% input$btn_trendlines){
    plot <- plot %>% group_by(season) %>% layer_model_predictions(model = "lm", se = F, stroke = ~season)
    plot <- plot %>% hide_legend("stroke")
  }
  if (input$btn_scale_y_range == TRUE){
    plot <- plot %>% scale_numeric("y", domain = c(0, 100))
  }
  plot <- plot %>% scale_numeric("y", zero = input$btn_scale_y_zero)
  plot <- plot %>% add_axis("x", title = label_x)
  plot <- plot %>% add_axis("y", title = label_y)
  plot <- plot %>% add_legend("fill", title = "Season", orient = "left", 
                              properties = legend_props(
                                            title = list(fontSize = 16),
                                            labels = list(fontSize = 14)
                                           )
                             )
  plot <- plot %>% add_tooltip(function(epdata){epdata$tooltip}, "hover")
  plot <- plot %>% set_options(width = 900, height = 400, renderer = "canvas")
  plot <- plot %>% bind_shiny(plot_id = "ggvis")
})
