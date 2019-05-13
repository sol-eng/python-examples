library(shiny)
library(reticulate)

gpt2 <- source_python("gpt2.py")

ui <- fluidPage(
  includeCSS("style.css"),
  shinyjs::useShinyjs(),
  
  fluidRow(
    column(4),
    column(4,
       titlePanel("GPT-2 - Transformer completion"),
       
       p(HTML(paste("This is a shiny app using the original", a("released code", href="https://github.com/openai/gpt-2/"),
                    "from", a("OpenAI language model GPT-2", href="https://openai.com/blog/better-language-models/"),
                    "code with 345M parameters. It uses", a("reticulate", href="https://github.com/rstudio/reticulate"),
                    "to import the original Python code into a shiny app with just a couple of lines of R code."
       ))),

       p(HTML(paste("Examples from the original OpenAI post:", actionLink("unicorn_example", "Unicorns"),
                    "-", actionLink("train_example", "Train"),
                    "-", actionLink("miley_example", "Miley Cirus"),
                    "-", actionLink("gpt2_example", "GPT-2"),
                    "-", actionLink("lotr_example", "LOTR"),
                    "-", actionLink("homework_example", "Homework"),
                    "-", actionLink("jfk_example", "JFK"),
                    "-", actionLink("recycling_example", "Recycling")
       ))),
       
       textAreaInput("input_text", "", placeholder = "Type something and the algorithm will guess what's next", width = "100%", height = "80px"),
       div(class="center_button", actionButton("run_btn", "Complete text"), actionButton("reset_btn", "Reset")),
       
       textOutput("status"),
       h3("Completion:", id="completed_header", style = "display:none;"),
       strong(htmlOutput("output_input_text", inline=TRUE)), htmlOutput("completed_text", inline=TRUE)
    ),
    column(4)
  )
)

server <- (function(input, output, session) {
  # initialize reactive values
  niter <- 5
  length <- 40
  rv <- reactiveValues(counter = 0, completed="", clicked = FALSE)
  gen <- NULL
  progress <- NULL
  predict <- get_predict_function("345M", length=length, niter=niter)
  
  output$completed_text <- renderUI({
    HTML(rv$completed)
  })
  
  observe({
    isolate({
      # When the button is clicked, iteration 0
      if (rv$counter == 0 & rv$clicked == TRUE) {
        progress <<- shiny::Progress$new()
        progress$set(message = "Completing text", value = 0)
        progress$inc(0, detail = paste("Preparing model"))
        
        gen <<- predict(input$input_text)
      }
      
      # While its iterating and making predictions
      if (rv$counter >= 0 & rv$counter <= niter & rv$clicked == TRUE) {
        new <- iter_next(gen)
        new <- paste(rv$completed, new)
        new <- gsub("\n", "<br>", new)
        rv$completed <- new
        
        rv$counter <- rv$counter + 1
        progress$inc(1/niter, detail = paste("Prediction ", rv$counter, "/", niter))
      }
      
      if (rv$counter == niter) {
        progress$close()
      }
    })
    
    # When the button is clicked, triggers the iterations
    if (isolate(rv$counter) <= niter & input$run_btn > 0) {
      if (isolate(input$input_text) != "") {
        shinyjs::show(id = "completed_header")
        output$output_input_text <- renderText({ isolate(gsub("\n", "<br>", input$input_text)) })
        
        rv$clicked = TRUE
      }
      invalidateLater(100, session)
    }
  })
  
  observe({
    if (input$reset_btn > 0) {
      rv$clicked = FALSE
      rv$counter <- 0
      rv$completed <- ""
      output$output_input_text <- renderText({ "" })
    }
  })
  
  observeEvent(input$unicorn_example, {
    updateTextAreaInput(session, "input_text", value = "In a shocking finding, scientist discovered a herd of unicorns living in a remote, previously unexplored valley, in the Andes Mountains. Even more surprising to the researchers was the fact that the unicorns spoke perfect English.")
  })
  
  observeEvent(input$train_example, {
    updateTextAreaInput(session, "input_text", value = "A train carriage containing controlled nuclear materials was stolen in Cincinnati today. Its whereabouts are unknown.")
  })
  
  observeEvent(input$miley_example, {
    updateTextAreaInput(session, "input_text", value = "Miley Cyrus was caught shoplifting from Abercrombie and Fitch on Hollywood Boulevard today.")
  })
  
  observeEvent(input$gpt2_example, {
    updateTextAreaInput(session, "input_text", value = "We’ve trained a large language model called GPT-2 that generates realistic paragraphs of text, while also exhibiting zero shot generalization on tasks like machine translation, question answering, reading comprehension, and summarization - problems usually approached by using training datasets and models designed explicitly for these tasks.\n \nA typical approach to language modeling is to learn the following task: predict the next word, given all of the previous words within some text. Last year, OpenAI’s Generative Pre-trained Transformer (GPT) showed that language models trained on large amounts of data can be fine-tuned to specific tasks to achieve high performance. GPT-2 shows that much larger language models trained on a more diverse dataset derived from the internet begin to learn these NLP tasks without needing task-specific training data, instead learning from examples the system derives from the raw text. These systems also display a substantial qualitative jump in the realism and coherence of generated text.")
  })
  
  observeEvent(input$lotr_example, {
    updateTextAreaInput(session, "input_text", value = "Legolas and Gimli advanced on the orcs, raising their weapons with a harrowing war cry.")
  })
  
  observeEvent(input$homework_example, {
    updateTextAreaInput(session, "input_text", value = "For today’s homework assignment, please describe the reasons for the US Civil War.")
  })
  
  observeEvent(input$jfk_example, {
    updateTextAreaInput(session, "input_text", value = "John F. Kennedy was just elected President of the United States after rising from the grave decades after his assassination. Due to miraculous developments in nanotechnology, Kennedy’s brain was rebuilt from his remains and installed in the control center of a state-of-the art humanoid robot. Below is a transcript of his acceptance speech.")
  })
  
  observeEvent(input$recycling_example, {
    updateTextAreaInput(session, "input_text", value = "Recycling is good for the world.")
  })
})

shinyApp(ui = ui, server = server)
