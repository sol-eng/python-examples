library(magrittr)
library(reticulate)  # Used to call Tensorflow Python script
library(shiny)
library(shinycssloaders)
library(gitlink)

behavior <- config::get("image")
stopifnot(behavior %in% c("upload", "download"))

# Load source of Python image classifier script
source_python('image-classifier.py')

server <- function(input, output, session) {
    
    # where the image that should be classified is on disk
    image_path <- reactiveVal("./cat.jpg")
    
    image_prefix <- "pytorch_image"
    
    # the configurable selector for download vs. upload
    output$image_selector <- renderUI({
        if (behavior == "download") {
          textInput("file1", label = h5("Enter Image URL:"), value = "")
        } else if (behavior == "upload") {
          fileInput("file_upload", label = h5("Upload an Image:"))
        } else {
            stop("Invalid configuration. Please chose 'download' or 'upload'")
        }
    })
    
    observe({
        req(input$file_upload)
        upload_file <- input$file_upload
        image_path(upload_file$datapath[[1]])
    })
    
    observeEvent(input$file1, {
        tryCatch({
            # Download image from URL
            temp_download <- fs::file_temp(image_prefix, ext = ".jpg")
            downloader::download(input$file1, temp_download)
            
            image_path(temp_download)
        }, error = function(e){
            stop(safeError(e))
        })  
    })
    
    output$contents <- renderTable({
        req(image_path())

        tryCatch(
            {
                # Call function from PyTorch Python script to classify image
                results <- classify_image_pytorch(image_path=image_path())
            },
            error = function(e) {
                stop(safeError(e))
            }
        )
        return(results)
    })

    output$image1 <- renderImage({
        req(image_path())
        
        # Copy the image to temp space
        new_path <- fs::file_copy(image_path(), fs::file_temp(image_prefix, ext = ".jpg"))

        # Return a list containing the filename
        if(is.null(new_path)) {
            return(NULL)
        }
        else {
            return(list(src = new_path))
        }
    })

    # default images
    observeEvent(input$oil_platform, image_path("./img/oil_platform.jpg"))
    observeEvent(input$truck, image_path("./img/truck.jpg"))
    observeEvent(input$flower, image_path("./img/flower.jpg"))
    observeEvent(input$cat, image_path("./img/cat.jpg"))
    observeEvent(input$dog, image_path("./img/dog.jpg"))

}

ui <- fluidPage(

    titlePanel("Image Classifier"),
    #ribbon_css(
    #    link = "https://github.com/sol-eng/python-examples/tree/master/image-classifier",
    #    position = "left"
    #    ),
    sidebarLayout(
        sidebarPanel(
            uiOutput("image_selector"),
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
            imageOutput("image1", height = NULL) %>% withSpinner(color = "#ffffff")
        )
    )
)

shinyApp(ui = ui, server = server)
