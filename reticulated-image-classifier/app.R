library(magrittr)
library(reticulate) # Used to call Tensorflow Python script
library(shiny)
library(shinycssloaders)

behavior <- config::get("image")
stopifnot(behavior %in% c("upload", "fetch-image-url"))

# Load source of Python image classifier script
source_python("image-classifier.py")

server <- function(input, output, session) {

    # where the image that should be classified is on disk
    image_path <- reactiveVal("./img/cat.jpg")

    image_prefix <- "pytorch_image"

    # the configurable selector for fetch-image-url vs. upload
    output$image_selector <- renderUI({
        if (behavior == "fetch-image-url") {
            list(
                textInput("file1", label = h5("Enter Image URL:"), value = ""),
                actionButton("fetch-image-url", "Fetch Image")
            )
        } else if (behavior == "upload") {
            fileInput("file_upload", label = h5("Upload an Image:"))
        } else {
            stop("Invalid configuration. Please chose 'fetch-image-url' or 'upload'")
        }
    })

    # handle upload
    observe({
        req(input$file_upload)
        upload_file <- input$file_upload
        image_path(upload_file$datapath[[1]])
    })

    # handle fetch-image-url
    observeEvent(input[["fetch-image-url"]], {
        req(input$file1)
        tryCatch(
            {
                # Fetch image from URL
                temp_fetch_image_url <- fs::file_temp(image_prefix, ext = ".jpg")
                downloader::download(input$file1, temp_fetch_image_url)

                image_path(temp_fetch_image_url)
            },
            error = function(e) {
                # usually, you would not expose this to the user
                # without a little sanitization
                showNotification(as.character(safeError(e)), type = "warning")
            }
        )
    })

    output$contents <- renderTable({
        req(image_path())

        tryCatch(
            {
                # Call function from PyTorch Python script to classify image
                results <- classify_image_pytorch(image_path = image_path())
            },
            error = function(e) {
                # usually, you would not expose this to the user
                # without a little sanitization
                showNotification(as.character(safeError(e)), type = "warning")
            }
        )
        return(results)
    })

    # render the image
    output$image1 <- renderImage({
        req(image_path())

        # Copy the image to temp space
        new_path <- fs::file_copy(image_path(), fs::file_temp(image_prefix, ext = ".jpg"))

        # Return a list containing the filename
        if (is.null(new_path)) {
            return(NULL)
        } else {
            return(list(src = new_path, style = htmltools::css(width = "100%")))
        }
    }, deleteFile = FALSE)

    # default images
    observeEvent(input$oil_platform, image_path("./img/oil_platform.jpg"))
    observeEvent(input$truck, image_path("./img/truck.jpg"))
    observeEvent(input$flower, image_path("./img/flower.jpg"))
    observeEvent(input$cat, image_path("./img/cat.jpg"))
    observeEvent(input$dog, image_path("./img/dog.jpg"))
}

ui <- fluidPage(
    titlePanel("Image Classifier"),
    sidebarLayout(
        sidebarPanel(
            uiOutput("image_selector"),
            helpText("Your image will be classified using PyTorch."),
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
            helpText("View", a("source code on GitHub", href = "https://github.com/sol-eng/python-examples/tree/master/image-classifier"))
        ),
        mainPanel(
            # Output
            tableOutput("contents") %>% withSpinner(),
            imageOutput("image1", height = NULL) %>% withSpinner(color = "#ffffff")
        )
    )
)

shinyApp(ui = ui, server = server)