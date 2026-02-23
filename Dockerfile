############################################
# Use official lightweight Python image
############################################
FROM python:3.12-slim

############################################
# Set environment variables
############################################
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

############################################
# Set working directory
############################################
WORKDIR /app

############################################
# Install system dependencies (if needed)
############################################
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

############################################
# Install Python dependencies first (better caching)
############################################
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

############################################
# Copy application code
############################################
COPY . .

############################################
# Create non-root user for security
############################################
RUN useradd -m appuser
USER appuser

############################################
# Default command
############################################
CMD ["python", "celsius-to-fahrenheit.py"]