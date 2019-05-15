# Shiny GPT-2

This example uses the original tensorflow code for [openai/gpt-2](https://github.com/openai/gpt-2), it uses reticulate
to import and use this code with just a couple of lines of R code.

All the Python code and model used is the original released by OpenAI except for `gpt2.py` that was reorganized to be able to query it interactively instead of a CLI based approach.

## How to run

### 1. R environment

Requirements:

- [packrat[(https://rstudio.github.io/packrat/)

Execute this or use RStudio in the project settings.

```
packrat::init()
```

### 2. Python environment

Requirements:

- Python 3.6. Note that Python 3.7 is not supported by this example
- virtualenv


Create the Python environment:

```
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### reticulate

The `.Rprofile` in this example its configured set `RETICULATE_PYTHON` to `.venv/bin/python` relative to the location of this project so everything should work automatically.

### Download model

With the environment created activated and dependencies installed:

```
python download_model.py 345M
```

### Run shiny app

Now you can execute the `app.R` inside RStudio.

### Deploying to connect

The project will run as is just note that the first time it will download the model automatically, since it wont find, so it might take a couple of minutes to start, after that it will start much faster.

