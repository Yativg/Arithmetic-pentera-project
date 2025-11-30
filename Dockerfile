# Use Python slim image for minimal size
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy application code
COPY src/*.py .

# Expose port
EXPOSE 5555

# Run server
CMD ["python3", "server.py"]
