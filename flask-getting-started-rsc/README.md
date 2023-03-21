## Getting Started with Flask and Posit Connect

This application structure and set-up follows the steps outlined in the links below.

Two routes are defined:

- `/` renders an HTML template
- `/api/hello` returns a JSON object

![](https://github.com/sol-eng/python-examples/blob/master/flask-getting-started-rsc/getting-started-flask.png)

## Deploy

```
rsconnect deploy api . -n <SERVER-NICKNAME>
```

#### Resources

- [Posit Connect User Guide - Flask](https://docs.posit.co/connect/user/flask/)
- [Getting Started with Flask and Posit Connect](https://support.rstudio.com/hc/en-us/articles/360044700234)
- [Deploying Flask Applications to Posit Connect with Git and rsconnect-python](https://support.rstudio.com/hc/en-us/articles/360045224233)
- [Using Templates and Static Assets with Flask Applications on Posit Connect](https://support.rstudio.com/hc/en-us/articles/360045279313)
