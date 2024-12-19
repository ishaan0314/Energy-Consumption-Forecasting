# Weather-Prediction

For this project, we ahve been hired by eSc, which is a ficticious company that provides electricity. They are concrened with the environmental effects of Global Warming and thus want to incentivise reduced energy consumption. 

The data for this project was to be gathered from an AWS server. There were 3 main files: static housing data (appliance usage, insulation type for floors, walls and ceilings, ownership status etc for 5086 houses), energy consumption for these houses and weather data (Dry Bulb Temperature, Humidity, Wind Speed etc) for the year 2023 for the entire state of South Carolina and some parts of North Carolina. THe data was time-series in nature and consisted of over 50 million observations in total. In order to aid efficiency, we built 2 models; one for each climate zone (Mixed, Humid and Hot, Humid)

There were 2 goals for this project: 
* Forecasting energy consumption for the month of July if it was 5 °F hotter
* Coming up with actionable insights to reduce energy consumption

We also built an interactive shiny web app which reads in our predicted consumption and plots it for each climate zone. The app can be found [here](https://ishaan-lodhi.shinyapps.io/Project_App/).

This was a collaborative effort, with equal contributions from: 
* Marko Masnikosa ([LinkedIn](linkedin.com/in/marko-masnikosa))
* Luis Riviere
