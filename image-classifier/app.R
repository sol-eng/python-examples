library(magrittr)
library(reticulate)  # Used to call Tensorflow Python script
library(shiny)
library(shinycssloaders)

# Load source of Python image classifier script
source_python('image-classifier.py')

server <- function(input, output, session) {

    output$contents <- renderTable({
        # After the user uploads a file, the image will be classified and the predictions will be shown.
        req(input$file1)

        tryCatch(
            {
                # Download image from URL
                downloader::download(input$file1, "image")

                # Call function from PyTorch Python script to classify image
                results <- classify_image_pytorch(image_path="image")
            },
            error = function(e) {
                stop(safeError(e))
            }
        )
        return(results)
    })

    output$image1 <- renderImage({
        req(input$file1)
        tryCatch(
            {
                input$file1
            },
            error = function(e) {
                stop(safeError(e))
            }
        )

        # Return a list containing the filename
        if(is.null(input$file1)) {
            return(NULL)
        }
        else {
            return(list(src = "image"))
        }
    })

    observe({
        x = input$oil_platform
        image_url = "https://upload.wikimedia.org/wikipedia/commons/a/a1/Oil_platform.jpeg"
        updateTextInput(session, "file1", value = paste(image_url))
    })

    observe({
        x = input$truck
        image_url = "https://upload.wikimedia.org/wikipedia/commons/6/6c/Toyota-1984-truck.jpg"
        updateTextInput(session, "file1", value = paste(image_url))
    })

    observe({
        x = input$flower
        image_url = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Aster_Tataricus.JPG/612px-Aster_Tataricus.JPG"
        updateTextInput(session, "file1", value = paste(image_url))
    })

    observe({
        x = input$cat
        image_url = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Egyptian_Mau_Bronze.jpg/611px-Egyptian_Mau_Bronze.jpg"
        updateTextInput(session, "file1", value = paste(image_url))
    })

    observe({
        x = input$dog
        image_url = "https://upload.wikimedia.org/wikipedia/commons/e/e4/Border_Collie_600.jpg"
        updateTextInput(session, "file1", value = paste(image_url))
    })

}

ui <- fluidPage(

    titlePanel("Image Classifier"),
    sidebarLayout(
        sidebarPanel(
            textInput("file1", label = h5("Enter Image URL:"), value = ""),
            helpText("Your image will be downloaded and classified using Tensorflow in Python."),
            helpText("The resulting predictions will be shown along with their confidence level."),
            hr(),
            helpText("Or, choose an example image:"),
            actionButton("dog", "Dog"),
            actionButton("cat", "Cat"),
            actionButton("flower", "Flower"),
            tags$br(),
            tags$br(),
            actionButton("truck", "Truck"),
            actionButton("oil_platform", "Oil Platform"),
            hr(),
            helpText("View", a("source code on GitHub", href="https://github.com/sol-eng/python-examples/tree/master/image-classifier"))
        ),

        mainPanel(
            # Output
            tableOutput("contents") %>% withSpinner(),
            imageOutput("image1") %>% withSpinner(color = "#ffffff")
        )
    )
)

shinyApp(ui = ui, server = server)
