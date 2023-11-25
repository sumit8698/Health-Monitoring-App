# First stage: Builder
FROM python:3.7.7-slim-buster as builder

WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY . .

RUN pip install --upgrade pip && \
    pip install django djangorestframework twilio

# Uncomment if you need to run collectstatic
# RUN python3 manage.py collectstatic --noinput --verbosity 2

# Second stage: Distroless
FROM gcr.io/distroless/python3-debian10

# Copy application and dependencies from the builder stage
# Since we installed globally, there's no need to copy /root/.local
COPY --from=builder /usr/local/lib/python3.7/site-packages /usr/local/lib/python3.7/site-packages
COPY --from=builder /app /app

# Set the working directory
WORKDIR /app
ENV PYTHONPATH=/usr/local/lib/python3.7/site-packages:$PYTHONPATH
# The CMD needs to be a list of arguments. Here we specify Python to run the manage.py script.
CMD ["manage.py", "runserver", "0.0.0.0:8000"]
