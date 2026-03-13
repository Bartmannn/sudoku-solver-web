package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

// SolveRequest represents the JSON we expect from React
type SolveRequest struct {
	Board [][]int `json:"board"`
}

// SolveResponse represents the JSON we will send back to React
type SolveResponse struct {
	Status string `json:"status"`
	Message string `json:"message,omitempty"` // omitempty hides this field if it's empty
	Board [][]int `json:"board,omitempty"`
}

func enableCORS(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:5173")
		w.Header().Set("Access-Control-Allow_Methods", "POST, GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next(w, r)
	}
}

func main() {
	// 1. Register the route and its handler function
	http.HandleFunc("/api/solve", enableCORS(solveHandler))

	// 2. Define the port (we use 8000 so it doesn't conflict with Prolog on 8080)
	port := ":8000"
	fmt.Printf("Golang API Gateway is running on port %s...\n", port)

	// 3. Start the server and log any fatal errors
	log.Fatal(http.ListenAndServe(port, nil))
}

func solveHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// 1. Parse the incoming JSON body from React into our Struct
	var reqBody SolveRequest
	err := json.NewDecoder(r.Body).Decode(&reqBody)
	if err != nil {
		http.Error(w, "Invalid JSON format", http.StatusBadRequest)
		return
	}

	// 2. Repackage the data to send to Prolog
	// bytes.Buffer is like a temporary memory space for our new JSON
	prologReqBytes, err := json.Marshal(reqBody)
	if err != nil {
		http.Error(w, "Failed to encode data for Prolog", http.StatusInternalServerError)
		return
	}

	// 3. Make the actual HTTP POST request to the Prolog Microservice
	// (Note: We use prolog-solver:8080 because Prolog is currenty exposed there via Docker)
	fmt.Println("Forwarding request to Prolog logic engine...")
	prologRes, err := http.Post("http://prolog-solver:8080/solve", "application/json", bytes.NewBuffer(prologReqBytes))
	if err != nil {
		// If Prolog is down or unreachable, we handle it gracefully
		http.Error(w, "Prolog service is unreachable", http.StatusServiceUnavailable)
		return
	}
	// Important Go habit: always close the response body when done!
	defer prologRes.Body.Close()

	// 4. Decode the response coming back from Prolog
	var resBody SolveResponse
	if err := json.NewDecoder(prologRes.Body).Decode(&resBody); err != nil {
		http.Error(w, "Failed to parse Prolog response", http.StatusInternalServerError)
		return
	}

	// 5. Send the JSON reponse back to the client
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resBody)
}