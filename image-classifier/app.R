library(shiny)
library(reticulate)
use_python("/opt/python/bin/python3", required=TRUE)
# use_python("/anaconda3/envs/py3/bin/python3", required=TRUE)
source_python('image-classifier.py')

# Define UI for data upload app ----
ui <- fluidPage(

    # App title ----
    titlePanel("Image Classifier"),

    # Sidebar layout with input and output definitions ----
    sidebarLayout(

        # Sidebar panel for inputs ----
        sidebarPanel(

            # Input: Select a file ----
            fileInput("file1", "Choose image file",
                      multiple = FALSE,
                      accept = c("image/jpg",
                                 "image/png",
                                 "image/gif",
                                 ".jpg",
                                 ".png",
                                 ".gif")),

            helpText("Your image will be uploaded, classified using Tensorflow and a model trained on the ImageNet data set, and the resulting predictions will be shown along with their confidence level.")
        ),

        # Main panel for displaying outputs ----
        mainPanel(

            # Output: Data file ----
            tableOutput("contents"),
            imageOutput("image1")

        )

    )
)

# Define server logic to read selected file ----
server <- function(input, output) {

    output$contents <- renderTable({

        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, the image will be classified, and the
        # predictions will be shown.

        req(input$file1)

        tryCatch(
            {

                results <- main(image=input$file1$datapath)

            },
            error = function(e) {
                # return a safeError if a parsing error occurs
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
                # return a safeError if a parsing error occurs
                stop(safeError(e))
            }
        )

        # Return a list containing the filename
        if(is.null(input$file1)) {
            return(NULL)
        }
        else {
        return(list(src = input$file1$datapath))
        }

    })

}

# Run the application
shinyApp(ui = ui, server = server)
