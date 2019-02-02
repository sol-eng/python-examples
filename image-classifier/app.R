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
            temp_download <- fs::file_temp("image", ext = ".jpg")
            downloader::download(input$file1, temp_download)
            
            image_path(temp_download)
        }, error = function(e){
            stop(safeError(e))
        })  
    })
    
    #image_path <- reactiveVal({
    #    
    #    # After the user uploads a file, the image will be classified and the predictions will be shown.
    #    # Download image from URL
    #    downloader::download(input$file1, "image")
    #    
    #})

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
        #var <- tryCatch(
        #    {
        #        image_path()
        #    },
        #    error = function(e) {
        #        stop(safeError(e))
        #    }
        #)
        # Copy the image to temp space
        new_path <- fs::file_copy(image_path(), fs::file_temp("image", ext = ".jpg"))

        # Return a list containing the filename
        if(is.null(new_path)) {
            return(NULL)
        }
        else {
            return(list(src = new_path))
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
