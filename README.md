# Sudoku Solver: Full-Stack Microservices Architecture

## 🔗 Demo

https://github.com/user-attachments/assets/cf7c9e15-924d-4a8f-9ce6-833b52730e1a

## 📖 Motivation & Educational Context
This project started as an exercise to improve upon a classic, purely Python-based backtracking [Sudoku solver](https://github.com/Bartmannn/sudoku-solver) I wrote in the past. My goal was to completely rethink the architecture, focusing on performance, scalability, and modern industry standards. 

To maximize the learning experience, this project was developed in a "pair-programming" setup with the Gemini Chat AI. Instead of using automated CLI generators, I used Gemini as an educational mentor to deep-dive into the raw implementation details of Docker networking, React state management, HTTP protocols, and API Gateway patterns. This approach allowed me to deeply understand every line of code and the architectural "why" behind it.

## 🏗️ Architecture & Tech Stack
The application is built as a **Monorepo** containing three distinct, containerized microservices. 

* **Frontend:** React + Vite + Tailwind CSS
  * **Why:** Vite provides lightning-fast HMR compared to CRA. React ensures a robust, component-driven UI, while Tailwind allows for rapid, utility-first styling without leaving the JSX. The state management focuses heavily on strict immutability.
* **API Gateway:** Go (Golang)
  * **Why:** Go's standard net/http library allows for incredibly fast, concurrent request handling without heavy frameworks. It acts as a secure shield (Single Point of Entry), handling CORS preflight requests and safely proxying data to the internal logic engine. It is compiled into a static, ultra-lightweight binary using a multi-stage Docker build.
* **Logic Engine:** SWI-Prolog
  * **Why:** Instead of writing manual `for` loops and backtracking algorithms (like in Python or C++), Prolog uses **CLP(FD)** (Constraint Logic Programming over Finite Domains). By simply defining the mathematical rules of Sudoku, the underlying engine uses constraint propagation to prune decision trees instantly, resulting in blazing-fast execution times.
* **Infrastructure:** Docker & Docker Compose
  * **Why:** Ensures 100% environment parity. The Prolog engine is deliberately kept isolated inside a private Docker bridge network with no published external ports, making it secure and inaccessible from the outside world except through the Go Gateway.

## ⚙️ Implementation Details
* **Internal Networking:** The Go API communicates with the Prolog service via Docker's internal DNS resolution (using container names as hostnames), completely bypassing the host machine's network.
* **Security & CORS:** The Go Gateway is explicitly configured to handle OPTIONS preflight requests and whitelist specific origins, preventing unauthorized cross-origin requests.
* **Statelessness:** The entire system is stateless, making it ready for horizontal scaling in the cloud.

## 🚀 How to Run Locally
If you want to test the raw infrastructure on your machine, you only need Docker installed. No local installations of Node, Go, or Prolog are required.

1. Clone the repository.
2. Run the following command in the root directory:
   `docker compose up --build`
3. Open your browser and navigate to `http://localhost:5173` (or the port defined in docker-compose).
