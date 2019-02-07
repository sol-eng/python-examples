library(shiny)
library(reticulate)

source_python('predict.py')
source_python('namesgenerator.py')

to_title <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

ui <- fluidPage(
  titlePanel("Sentiment Analysis"),
  shiny::inputPanel(
      textInput(
        "raw_title",
        "Movie Title",
        placeholder = "Title of the movie"
    ),
      textAreaInput(
        "raw_review",
        "Movie Review",
        placeholder = "Type your review here..."
    ),
    actionButton("submit", "Submit Review")
  ),
  shiny::fluidRow(
    uiOutput("review")
  )
)

server <- function(input, output, session) {
  raw_html <- reactiveVal()
  observeEvent(input$submit, {
    req(input$raw_title, input$raw_review)

    raw_html(
      div(
        build_pretty_output(input$raw_title, input$raw_review),
        style = htmltools::css("text-align" = "center")
        )
      )
  })

  output$review <- renderUI(raw_html())
}

build_pretty_output <- function(title, review) {
  reviewer_name <- to_title(py$get_random_name(sep = " "))

  predict_output <- py$predict(input = review)

  score <- predict_output[[2]][["POSITIVE"]]
  num_stars <- (score + 0.1) %/% 0.2

  adj <- switch(
    num_stars + 1,
    "A scathing review",
    "A harsh review",
    "A disappointed review",
    "A less-than-stellar review",
    "A excited review",
    "A glowing review")

  if (num_stars) {
    ui_icon <- shiny::icon(
      name = "star",
      lib = "font-awesome",
      class = "fa-4x"
      )

    ui_output <- tagList(
      h2(to_title(title)),
      h4(paste(
        adj,
        "from",
        reviewer_name
      )),
      do.call(
        div,
        lapply(
          seq_len(num_stars),
          function(x, ui_icon){return(ui_icon)},
          ui_icon=ui_icon)
        ),
      br(),
      p(paste("Score:", score)),
      shiny::wellPanel(tags$blockquote(review))
    )
  } else {
    ui_icon <- shiny::icon(
      name = "times-circle",
      lib = "font-awesome",
      class = "fa-4x"
    )
    ui_output <- tagList(
      h2(to_title(title)),
      h4(paste(
        adj,
        "from",
        reviewer_name
      )),
      div(
        ui_icon
      ),
      br(),
      p(paste("Score:", score)),
      shiny::wellPanel(tags$blockquote(review))
    )
  }
}


shinyApp(ui = ui, server = server)
