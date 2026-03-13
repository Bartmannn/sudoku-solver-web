# --- Builder ---

FROM golang:1.22 AS builder

WORKDIR /app

# Copy the go.mod file first (for caching dependencies)
COPY go.mod ./

# Download all required dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Compile the Go app
# CGO_ENABLED=0 ensures a completely static binary
# GOOS=linux ensures we compile for Linux, regardless of your host OS
RUN CGO_ENABLED=0 GOOS=linux go build -o /api-gateway main.go

# --- Final minimal image ---

# We use Alpine Linux
FROM alpine:latest

# Install root certificates (needed if our API ever makes HTTPS requests)
RUN apk --no-cache add ca-certificates

# Set the working directory
WORKDIR /root/

# Copy only the compiled binary from the "builder" stage
COPY --from=builder /api-gateway .

# Expose the port our Go app runs on
EXPOSE 8000

# ommand to run the executable
CMD ["./api-gateway"]
