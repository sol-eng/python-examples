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
    column(
      8,
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
       actionButton("submit", "Submit Review"),
      br(),
      br()
     ),
    column(
      4,
      actionButton("sample_1", "Sample Review 1"),
      actionButton("sample_2", "Sample Review 2"),
      actionButton("sample_3", "Sample Review 3"),
      actionButton("sample_4", "Sample Review 4")
    )
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
      build_pretty_output(input$raw_title, input$raw_review)
    )
  })

  observeEvent(input$sample_1, {
    raw_html(
      build_pretty_output(
        "The Incredibles",
        paste(
          "This movie was well named - incredible!",
          "So much excitement and fun, along with quality",
          "heroes and hearty laughter. I recommend this movie highly!"
        )
      )
    )
  })

  observeEvent(input$sample_2, {
    raw_html(
      build_pretty_output(
        "The Not So Incredibles",
        paste(
          "What were the writers thinking?",
          "It's almost like they forgot what their job",
          "was, or how to make a movie entertaining. This",
          "movie was bores-ville from start to finish, simply",
          "awful. Don't waste your time going to see this one!"
        )
      )
    )
  })

  observeEvent(input$sample_3, {
    raw_html(
      build_pretty_output(
        "Questionable Questioners",
        paste(
          "The Questionable Questioners will make you question...",
          "Why are we here? What are we doing? Why am I writing this review?",
          "I don't know where I stand. Maybe it was not so great,",
          "or maybe it was pretty good after all.",
          "I think you will just have to see for yourself."
        )
      )
    )
  })

  observeEvent(input$sample_4, {
    raw_html(
      build_pretty_output(
        "Briefing Briefers",
        paste(
          "What did I just watch? It was ok."
        )
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

  return(
    div(
      ui_output,
      style = htmltools::css("text-align" = "center")
    )
  )
}


shinyApp(ui = ui, server = server)
