![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Django](https://img.shields.io/badge/django-%23092E20.svg?style=for-the-badge&logo=django&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-4479A1.svg?style=for-the-badge&logo=mysql&logoColor=white)

# Joggernaut Backend API

This serves as the backend [REST API](https://docs.github.com/en/rest) for Joggernaut, allowing it process and relay to the database any information passed to it by the front end.
It was developed using [Python](https://github.com/python/) and [Django](https://github.com/django/django).

The database used is [MySQL](https://github.com/mysql).

Authentication standard used is [OAuth2](https://auth0.com/intro-to-iam/what-is-oauth-2) thorugh the [Django-oauth-toolkit](https://github.com/jazzband/django-oauth-toolkit) module.

The API is designed to be [REST](https://docs.github.com/en/restful) through the use of the [Django REST Framework (DRF)](https://github.com/encode/django-rest-framework) module .

Detailed documentation is to follow.

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


## API Endpoints Guide(for Development server)
- For Administration: http://localhost:8000/admin

- For API: http://localhost:8000/api
    - **GET** `/` for testing connection only
    - **POST** `/register/` for submitting a register form, expected data: `JSON`
    ```json
    {
        "firstname": "FIRSTNAME HERE",
        "lastname": "LASTNAME HERE",
        "email": "EMAIL HERE",
        "phonenumber": "PHONENUMBER HERE",
        "password": "PASSWORD HERE"
    }
    ```
    - **GET, POST** `/user/profile` for submitting a user profile form and retrieving user profiles, query params: `userid` | expected data: `JSON`
    ```json
        "userid": USERID HERE,
        "accountname": ACCOUNTNAME HERE,
        "dateofbirth": DATE OF BIRTH HERE,
        "gender": GENDER HERE,
        "address": ADDRESS HERE,
        "height_cm": HEIGHT HERE,
        "weight_kg": WEIGHT HERE
    }
    ```
    See [DRF documentation](https://www.django-rest-framework.org/)

- For Authentication: http://localhost:8000/api/auth
    - **POST** `/auth/token/` for acquiring a Oauth2 token; a successful response should yield , expected data: `JSON`
    ```json
    {  // post data
        "grant_type": "password",
        "username": "USERNAME HERE",
        "password": "PASSWORD HERE",
        "client_id": "CLIENT_ID HERE",
        "client_secret": "CLIENT_SECRET HERE"
    }
    {  // successful auth response
        "access_token": ACCESS TOKEN HERE,
        "expires_in": SOME NUMBER HERE,
        "token_type": "Bearer",
        "scope": "read write",
        "refresh_token": REFRESH TOKEN HERE
    }
    {  // failed auth response
        "error": "invalid_grant",
        "error_description": SOMETHING HERE
    }
    ```

    To use the token, ensure all requests made by the client has the authorization header `Bearer <TOKEN HERE>`.

    No custom view has been defined for the authentication endpoint for now.
    See [Django-Oauth2-Toolkit documentation](https://test-oauth.readthedocs.io/en/latest/)