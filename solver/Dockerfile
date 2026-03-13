# Downloading latest version of prolog
FROM swipl:latest

# Working dir inside contener
WORKDIR /app

COPY server.pl .

# Default command executed after contener's start
CMD ["swipl", "-s", "server.pl"]