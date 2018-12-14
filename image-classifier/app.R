library(reticulate)  # Used to call Tensorflow Python script
library(shiny)
library(magrittr)
library(shinycssloaders)

# Set PyTorch model directory
Sys.setenv(TORCH_MODEL_ZOO = "./model")

source_python('image-classifier.py')

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
            actionButton("truck", "Truck"),

            hr(),

            helpText("View", a("source code on GitHub", href="https://github.com/sol-eng/python-examples/tree/master/image-classifier"))

        ),

        mainPanel(

            # Output: Data file ----
            tableOutput("contents") %>% withSpinner(),
            imageOutput("image1") %>% withSpinner(color = "#ffffff")

        )

    )
)

server <- function(input, output, session) {

    output$contents <- renderTable({

        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, the image will be classified, and the
        # predictions will be shown.
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
        x = input$cat
        updateTextInput(session, "file1", value = paste("https://www.catster.com/wp-content/uploads/2017/08/Pixiebob-cat.jpg"))
    })

    observe({
        x = input$truck
        updateTextInput(session, "file1", value = paste("http://image.fourwheeler.com/f/174296714+w660+h440+q80+re0+cr1+ar0/006-chevy-1500-boggers-mud-truck-suspension.jpg"))
    })

    observe({
        x = input$dog
        updateTextInput(session, "file1", value = paste("https://www.akc.org/wp-content/themes/akc/component-library/assets/img/welcome.jpg"))
    })

}

shinyApp(ui = ui, server = server)
