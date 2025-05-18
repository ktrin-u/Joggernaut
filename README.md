# Joggernaut

This is a course requirement for CS 191/CS192 Software Engineering Courses of the Department of Computer Science,
College of Engineering, University of the Philippines, Diliman under
the guidance of Prof. Ma. Rowena C. Solamo for the AY 2024-2025.

## Team Members:
Formerly `CS191 WFV - Group 5`

- Andres, Lance
- Crisostomo, Alessandro
- De Leon, Angelo
- Jimenez, Rafael
- Trinidad, Kevin

## Instructions
Due to costs, the database is no longer deployed.
Simply installing the `.apk` file will no longer work.

To run this application now, extra steps are needed,

1. A local instance of the API server should be running.
    -  Visit `back-end/README.md` for instructions on how to run it locally.

2. The mobile application's API URL needs to be updated.
    - In `front-end/flutter_joggernaut/lib/utils/urls.dart`, set the variable `hostURL` to the address of the local API server.
    - Further instructions for running the app within Android Studio can be found in `front-end/README.md`
