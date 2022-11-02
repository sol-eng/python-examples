# Quarto With the Jupyter Engine and Lightbox Extension

Note on Lightbox: This example has been tested and works with Quarto versions 1.0.36 and 1.1.189 and Lightbox version 0.1.3. 

## Deploy

Steps: 

* Test locally
* Acquire an [API key](https://docs.rstudio.com/connect/user/api-keys/) 
* Publish with your method of choice 

Tip: Use [quarto projects](https://quarto.org/docs/projects/quarto-projects.html) for the most robust publishing experience. The rsconnect-python package (and git backed publishing on Connect) as of 2022/11/02 are only able to deploy Quarto projects, not standalone documents. 

**Quarto CLI**

```bash
quarto publish connect quarto-python-lightbox.qmd
```

**rsconnect-python**

Configure your server address and publish. 

```
rsconnect add \
    --api-key <MY-API-KEY> \
    --server <https://connect.example.org:3939> \
    --name <SERVER-NICKNAME>
```

```
rsconnect deploy quarto . -n <SERVER-NICKNAME>
```

[Important: If your Quarto content contains R code, you cannot use the rsconnect-python CLI's rsconnect deploy quarto function. You can still use rsconnect deploy manifest to deploy content for which a manifest has already been generated.](https://quarto.org/docs/publishing/rstudio-connect.html) Instead use [rsconnect](https://github.com/rstudio/rsconnect). 

**git-backed**

Writing the manifest.json file (which in turn writes the requirements.txt file) enables [git backed publishing from inside the Connect UI](https://docs.rstudio.com/connect/user/git-backed/). 

```bash
rsconnect write-manifest quarto .
```

## Resources

- [RStudio Connect User Guide - Quarto (Python)](https://docs.rstudio.com/connect/user/publishing-cli-quarto/)
- [quarto cli](https://quarto.org/docs/publishing/rstudio-connect.html)
- [rsconnect](https://github.com/rstudio/rsconnect)
- [rsconnect-python](https://github.com/rstudio/rsconnect-python)
- [quarto projects](https://quarto.org/docs/projects/quarto-projects.html)
- [RStudio Connect User Guide - Git Backed Publishing ](https://docs.rstudio.com/connect/user/git-backed/)
- [Quarto Version Manager](https://github.com/dpastoor/qvm)
- [Lightbox Quarto Extension](https://github.com/quarto-ext/lightbox)


