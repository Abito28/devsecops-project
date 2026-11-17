FROM python:3.12-slim

ARG USERNAME=user
ARG GROUPNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${GROUPNAME} \
    && useradd -u ${UID} -g ${GROUPNAME} -m ${USERNAME}

COPY --from=ghcr.io/astral-sh/uv:0.13.8 /uv /bin/uv

WORKDIR /app

COPY pyproject.toml uv.lock .python-version ./

RUN uv sync --locked --no-dev --no-install-project

COPY main.py .

ENV PATH="/app/.venv/bin:$PATH"

USER ${UID}:${GID}

CMD ["fastapi", "run", "main.py", "--host", "0.0.0.0", "--port", "8000"]