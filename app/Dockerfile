FROM python:3.12-slim

ARG USERNAME=user
ARG GROUPNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${GROUPNAME} \
    && useradd -u ${UID} -g ${GROUPNAME} -m ${USERNAME}

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

USER ${USERNAME}:${GROUPNAME}

CMD ["fastapi", "run", "main.py", "--host", "0.0.0.0", "--port", "8000"]