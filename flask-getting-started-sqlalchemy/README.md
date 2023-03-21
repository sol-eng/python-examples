## Using Flask-SQLAlchemy with Flask Applications on Posit Connect

This application structure and set-up follows the steps outlined in
[Using Flask-SQLAlchemy with Flask Applications on Posit Connect](https://support.rstudio.com/hc/en-us/articles/360045926213):

- Creating a minimal application based on the Flask-SQLAlchemy quickstart guide
- Define the database model to use
- Initialize a SQLite database
- Commit data to the database
- Deploy the application to Posit Connect with rsconnect-python

And, optionally:

- Switch to a PostgreSQL database server
- Add `pyscopg2` dependency to the Python environment
- Add the database server connection string as an environment variable in Posit Connect
- Redeploy the application

---
## Setup

Run the following to create the sqlite database used by the application:

```
python seed_db.py
```

## Deploy

```
rsconnect deploy api . -n <SERVER-NICKNAME>
```

### Additional Resources

- [Getting Started with Flask and Posit Connect](https://support.rstudio.com/hc/en-us/articles/360044700234)
- [Deploying Flask Applications to Posit Connect with Git and rsconnect-python](https://support.rstudio.com/hc/en-us/articles/360045224233)
- [Using Templates and Static Assets with Flask Applications on Posit Connect](https://support.rstudio.com/hc/en-us/articles/360045279313)
