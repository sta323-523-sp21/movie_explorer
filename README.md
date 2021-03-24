# Movie explorer

An R Shiny app using [The Open Movie Database](http://www.omdbapi.com).

The OMDb API is a RESTful web service to obtain movie information, all content
and images on the site are contributed and maintained by our users.

A free API can be obtained at http://www.omdbapi.com/apikey.aspx.

## Features

- A customized UI with R's html tag functions

- Alerts with `shinyalert`

- A custom theme with `shinythemes`

- Fluid layouts with `sidebarLayout()` and `column()`

- Delayed reactivity with action buttons and `eventReactive()`

- Data download functionality with `downloadHandler()`

- Decoupled caller and reactive value relationships with `isolate()`
