# Load necessary libraries
library(shiny)
library(ggplot2)
library(dplyr)

# Define UI
ui <- fluidPage(
  titlePanel("Energy Consumption Prediction"),
  
  sidebarLayout(
    sidebarPanel(
      # Hour selection
      numericInput(
        "selected_hour",
        "Select Hour (0-23):",
        value = 0,
        min = 0,
        max = 23
      ),
      
      # Climate zone selection
      selectInput(
        "selected_zone",
        "Select Climate Zone:",
        choices = c("Mixed", "Hot")
      ),
      
      # Display results
      textOutput("current_consumption"),
      textOutput("forecast_consumption"),
      
      # Pie chart container
      tags$div(
        style = "margin-top: 30px;",
        plotOutput("pie_chart", height = "400px")
      )
    ),
    
    mainPanel(
      # Display line plot for the selected zone
      plotOutput("zone_plot", height = "400px"),
      
      # Bar plot container
      tags$div(
        style = "margin-top: 20px; margin-left: -30px;",
        plotOutput("total_consumption_plot", height = "400px")
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Read CSV file inside the server
  energy_data <- reactive({
    # Use tryCatch to handle errors if the file is not found
    tryCatch({
      read.csv("combined_energy_results.csv")
    }, error = function(e) {
      stop("Error: Unable to load the dataset. Please ensure 'combined_energy_results.csv' is in the app directory.")
    })
  })
  
  # Reactive function to filter data for the selected climate zone
  zone_data <- reactive({
    data <- energy_data()
    if (input$selected_zone == "Mixed") {
      data.frame(
        Hour = data$Hour,
        Original = data$Predicted_Energy_Consumption_Mixed,
        Warmer = data$Predicted_Warmer_Energy_Consumption_Mixed
      )
    } else if (input$selected_zone == "Hot") {
      data.frame(
        Hour = data$Hour,
        Original = data$Predicted_Energy_Consumption_Hot,
        Warmer = data$Predicted_Warmer_Energy_Consumption_Hot
      )
    }
  })
  
  # Reactive function to calculate total energy consumption for both climate zones
  total_consumption <- reactive({
    data <- energy_data()
    data.frame(
      Zone = c("Mixed", "Mixed", "Hot", "Hot"),
      Prediction = c("Original", "Warmer", "Original", "Warmer"),
      Total = c(
        sum(data$Predicted_Energy_Consumption_Mixed),
        sum(data$Predicted_Warmer_Energy_Consumption_Mixed),
        sum(data$Predicted_Energy_Consumption_Hot),
        sum(data$Predicted_Warmer_Energy_Consumption_Hot)
      )
    )
  })
  
  # Render current consumption
  output$current_consumption <- renderText({
    data <- zone_data()
    if (!is.null(data)) {
      paste("Current Energy Consumption:", data$Original[input$selected_hour + 1], "kWh")
    } else {
      "No data available for the selected hour and climate zone."
    }
  })
  
  # Render forecast consumption
  output$forecast_consumption <- renderText({
    data <- zone_data()
    if (!is.null(data)) {
      paste("Forecast Energy Consumption:", data$Warmer[input$selected_hour + 1], "kWh")
    } else {
      "No data available for the selected hour and climate zone."
    }
  })
  
  # Render energy consumption plot for the selected zone
  output$zone_plot <- renderPlot({
    data <- zone_data()
    
    # Calculate median
    median_value <- median(data$Original)
    
    # Create plot
    ggplot(data, aes(x = Hour)) +
      geom_line(aes(y = Original, color = "Original")) +
      geom_line(aes(y = Warmer, color = "Warmer")) +
      geom_hline(yintercept = median_value, linetype = "dashed", color = "black", size = 0.7) +
      annotate("text", x = max(data$Hour) - 2, y = median_value + 0.1, label = "Median", color = "black", size = 4) +
      scale_color_manual(values = c("Original" = "blue", "Warmer" = "red")) +
      labs(
        title = paste("Hourly Energy Consumption for", input$selected_zone, "Zone"),
        x = "Hour of the Day",
        y = "Energy Consumption (kWh)",
        color = "Scenario"
      ) +
      theme_minimal()
  })
  
  # Render bar plot for total energy consumption
  output$total_consumption_plot <- renderPlot({
    data <- total_consumption()
    
    ggplot(data, aes(x = Zone, y = Total, fill = Prediction)) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(
        title = "Total Energy Consumption for Climate Zones",
        x = "Climate Zone",
        y = "Total Energy Consumption (kWh)",
        fill = "Scenario"
      ) +
      theme_minimal() +
      theme(
        plot.margin = margin(10, 10, 10, 10)
      )
  })
  
  # Render pie chart for warmer predictions
  output$pie_chart <- renderPlot({
    # Calculate total warmer predictions for each climate zone
    data <- energy_data()
    warmer_data <- data.frame(
      Zone = c("Mixed", "Hot"),
      Total = c(
        sum(data$Predicted_Warmer_Energy_Consumption_Mixed),
        sum(data$Predicted_Warmer_Energy_Consumption_Hot)
      )
    )
    
    # Create pie chart
    ggplot(warmer_data, aes(x = "", y = Total, fill = Zone)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +
      labs(
        title = "Energy Consumption for Warmer Predictions",
        fill = "Zone"
      ) +
      theme_void()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
