
## About the Impact Effect Dashboard 

As it is explained in **Brodersen et al (2015)**, *"The causal impact of a treatment is the difference between the observed value of the response and the (unobserved) value that would have been obtained under the alternative treatment, that is, the effect of treatment on the treated"*, *"In the present setting the response variable is a time series, so the causal effect of interest is the difference between the observed series and the series that would have been observed had the intervention not taken place."* 

In other words, it simulates the behalf of a series considering if a given intervention didn't take place. In this case, all the series included will be time series. 


### About Causal Impact

This model was created by **Google**, and it was conceived to simulate the impact of a marketing campaign. If the model determined that this campaign was going to have a positive impact, then this campaign should be set and prepared.

Nevertheless, this powerful methodology can be applied to many different fields and cases. For instance, the app 


### Examples

Data sets used in the Shiny App include:

* **Views** 
Number of visualizations from a YouTube channel about the new Spider man video game. This data is extracted from YouTube analytics and contains the daily views obtained over a year. 

* **Spotify** 
This is a complete dataset of all the "Top 200" and "Viral 50" charts published globally by Spotify. We selected the variables "date" and "streams" from Spotify from the following artist. Olivia Rodrigo, BTS and Travis Scott. We filtered the variable "date" by daily data from 2021 going forward.

* **Disney stock price** 
In order to diverse and expand our Shiny, we introduced another data set. In this case the evolution of Disney´s stock price extracted from Yahoo finance. The variable "date" includes daily data from the years 2018 and 2019. 

Note
The value of streams is NULL when the chart column is "viral50".

Acknowledgement
Image Credits: Photo by Omid Armin on Unsplash

### Causal Impact in action

#### Inputs in the application

In this applications, there are some parameters that need to be specified: 

* **Dataset**. 
In this slider input, you can choose among the example datasets included in the app, so that the impact can be visualized. 

* **Event date**.
In order to select the date of start of the time interval.

* **End condition**. 
To specify the criterium for selecting the time interval. It could be either by setting a fixed interval (the display will show the number of days to set for that interval), by setting the input to minimum (the display will start from the first date available)

#### Outputs displayed

* **Casual impact event analysis**. This will show you the expected response, predicted with Causal Impact library and values like the total impact,
event start and end days, and how many days needed to recover from the impact at the start position. 

It is interesting to talk about the computation related with the days to recover. We consider that the values are recovered when the final value is inside the confidence interval of the expected values. One this point is stablished we try to revert from the end point where the impact is active.

* **More details**. You will find a chart for displaying the Accumulated and Relative impacts. You can also download the auto-generated report by Causal Impact library. 

### The team

* **Carlos Viñals Guitart** (carlos.vinals@cunef.edu) - [@carviagu](https://github.com/carviagu) 

* **Sergio Ranz Casado** (sergio.ranz@cunef.edu) - [@sergerc](https://github.com/sergerc)

* **Marcos Medina Cogolludo** (marcos.medina@cunef.edu) - [@marcosmedina97](https://github.com/marcosmedina97)

* **Jaime del Saz** (jaime.saz@cunef.edu) - [@jaimee8](https://github.com/jaimee8) 

* **Álvaro Serrano del Rincón** (a.serranodelrincon@cunef.edu) - [@aserincon](https://github.com/aserincon)

### References

Brodersen, K. H., Gallusser, F., Koehler, J., Remy, N., & Scott, S. L. (2015). Inferring causal impact using Bayesian structural time-series models. The Annals of Applied Statistics, 9(1), 247-274. 


![](../img/thatsAll.gif)

