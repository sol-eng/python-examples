# Using R with Python

<a href="https://rstudio.github.io/reticulate/">
  <img src="reticulated_python.png" width="200">
</a>

### Reticulate

The reticulate package provides a comprehensive set of tools for interoperability between Python and R. You can use Python for the following:

* Call Python from R
* Use Python with R Markdown, Shiny, and R scripts
* Source Python scripts
* Import Python modules
* Use Python interactively within an R session
* Translate between R and Pandas data frames
* Translate between R matrices and NumPy arrays
* Bind with Virtualenv
* Bind with Conda environments

### RStudio Connect

You can publish Jupyter notebooks to RStudio connect. The RStudio plugin for Jupyter allows you to publish Jupyter notebooks with the press of a button. Once published on RStudio Connect, these notebooks can be scheduled for updates or refreshed on demand.

### Examples

* [Use Python with R Markdown](https://colorado.rstudio.com/rsc/reticulate-demo) [[login]](https://colorado.rstudio.com/rsc/connect/#/apps/1924/access/2075)
* [Use Python to visualize data in R Markdown](https://colorado.rstudio.com/rsc/python-visuals) [[login]](https://colorado.rstudio.com/rsc/connect/#/apps/1716/access)
* [Publish Jupyter Notebooks to RStudio Connect](https://colorado.rstudio.com/rsc/jupyter-geospatial) [[login]](https://colorado.rstudio.com/rsc/connect/#/apps/1762/access)
* [Python-based Visualizations in Jupyter Notebooks](https://colorado.rstudio.com/rsc/jupyter-notebook-visualization) [[login]](https://colorado.rstudio.com/rsc/connect/#/apps/2038/access/2160)
* [Interactive Python-based Plots in Jupyter Notebooks](https://colorado.rstudio.com/rsc/jupyter-notebook-interactive-plots) [[login]](https://colorado.rstudio.com/rsc/connect/#/apps/2036/access/2158)

### Getting Started

* Clone this repository
* Install Python on your machine
* Set the `RETICULATE_PYTHON` environment variable to point to your installation
  of Python, for example using the following line in your `~/.Rprofile`:

  ```
  Sys.setenv(RETICULATE_PYTHON = '/usr/local/bin/python')
  ```
* Run the examples
* Publish the examples with source code to RStudio Connect

### Philosophy

The intent of the reticulate package is to integrate Python into R projects, and are not intended for standalone Python work. There are many IDEs available for doing data science with Python including JupyterLab, Rodeo, Spyder, and Visual Studio Code, and we strongly recommend using one of them for Python-only projects. However, if you are using reticulated Python within an R project then RStudio provides a set of tools that we think you will find extremely helpful.
