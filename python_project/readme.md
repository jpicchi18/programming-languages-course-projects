# ASSIGNMENT: implement a python proxy server heard to service mobile smartphone clients
 - full project spec: [project_spec.pdf](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/python_project/project_spec.pdf)
 - code files: [server.py](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/python_project/server.py) &
 [util.py]((https://github.com/jpicchi18/programming-languages-course-projects/blob/main/python_project/util.py)
 - project analysis, implementation description, and research report: [report.pdf]((https://github.com/jpicchi18/programming-languages-course-projects/blob/main/python_project/report.pdf)

## Language
python

## Description
- Implemented a server herd consisting of an arbitrary number of event-based servers that uses asyncio to serve client requests.
- Asyncio library calls are used to create and manage an event loop that asynchronously calls the *google places* API to provide requested geographical data to
users.
- Servers across the herd propagate messages to the rest of the servers in the herd in order to coordinate actions.
