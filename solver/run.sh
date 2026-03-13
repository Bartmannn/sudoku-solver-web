#!/bin/bash

# exit script after error
set -e

# building container which name's `sudoku_solver`
docker build -t sudoku_solver .

# cleaning up old containers (if any)
docker rm -f sudoku_api_container 2>/dev/null || true

# running container, connecting current dir ($PWD) with app dir (/app) inside container
# --rm -> delete container after closing it
docker run --rm --name sudoku_api_container -p 8080:8080 -v "$PWD:/app" sudoku_solver
