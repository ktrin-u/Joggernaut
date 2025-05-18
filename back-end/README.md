![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Django](https://img.shields.io/badge/django-%23092E20.svg?style=for-the-badge&logo=django&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-4479A1.svg?style=for-the-badge&logo=mysql&logoColor=white)

# Joggernaut Backend API

This serves as the backend [REST API](https://docs.github.com/en/rest) for Joggernaut, allowing it process and relay to the database any information passed to it by the front end.
It was developed using [Python](https://github.com/python/) and [Django](https://github.com/django/django).

The database used was [MySQL](https://github.com/mysql) which was deployed on Amazon Web Services Relation Database Services. To avoid incurring additional costs, it has been taken down. In the event that no database details are detected in the environment or `.env` file, it will default to [Sqlite3](https://sqlite.org/index.html).

Authentication standard used is [OAuth2](https://auth0.com/intro-to-iam/what-is-oauth-2) thorugh the [Django-oauth-toolkit](https://github.com/jazzband/django-oauth-toolkit) module.

The API is designed to be [REST](https://docs.github.com/en/restful) compliant through the use of the [Django REST Framework (DRF)](https://github.com/encode/django-rest-framework) module.

An interactive web interface for the API Documentation was created using [Swagger](https://swagger.io) and accessible at `/api/` endpoint.

## Environment Variables
The following variables should be defined in the operating environment of the API.
The module `python-dotenv` is present and it will load `.env` files found in the `back-end/`
```sh
CLIENT_ID       =
CLIENT_SECRET   =
DJANGO_KEY      =
# Leave the following blank to use Sqlite3
DB_HOST         =
DB_DATABASE     =
DB_USER         =
DB_PASSWORD     =
DB_PORT         =
# Leaving the following blank will prevent the reset forgotten password feature
SMTP_HOST       =
SMTP_PORT       =
SMTP_USER       =
SMTP_PASSWORD   =
```

## How to run (for Development)

1. Clone the repo
2. Ensure [Python](https://github.com/python/) is version 3.13 and above
3. Install [Poetry](https://github.com/python-poetry/poetry), the dependency manager used for this project.
4. Open up a terminal
5. Change the working directory to `back-end` folder of the repository
6. Run `poetry install` in the terminal
7. To start the development server, run `poetry run python manage.py runserver`
8. Refer to the terminal output for further guidance
- Tests can be run by invoking `poetry run python manage.py test`

## Backend Endpoints Guide (for Local Development server)
- For Administration: http://localhost:8000/admin
- For API Documentation and available endpoints: http://localhost:8000/api/
- For Authentication: http://localhost:8000/api/auth