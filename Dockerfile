FROM python:latest

# Display python version
RUN python --version

# Copy wheel files to /app
WORKDIR /app
COPY build/*.whl .

# Install packages. This will ensure that all dependencies of wheels are installed
RUN pip install --find-links /app/*.whl api-*.whl

# Remove all wheels to save space
RUN rm -rf *.whl

# Run the API
CMD ["python", "-m", "api"]
