# Use a lightweight Python base image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first to leverage Docker caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download the NLTK VADER lexicon data
# This ensures the container is ready to go without needing internet at runtime
RUN python -m nltk.downloader vader_lexicon

# Copy the rest of your application code
COPY . .

# Set environment variables
ENV PORT=10000

# Expose the port Render will use
EXPOSE 10000

# Use Gunicorn (a production-grade server) instead of the Flask dev server
# 'app:app' refers to 'app.py' and the 'app' variable inside it
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app"]