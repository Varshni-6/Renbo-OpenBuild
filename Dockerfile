# Use Python base image
FROM python:3.9-slim

WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the code
COPY . .

# Expose the port
EXPOSE 8080

# Run the app (Change "app:app" if your Flask instance is named differently)
CMD ["python", "app.py"]