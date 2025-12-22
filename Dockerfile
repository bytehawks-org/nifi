# By deafult we set NIFI_VERSION to 2.7.2, but you can override it during build time
ARG NIFI_VERSION=2.7.0

# Using this FROM statement e can build the latest release of Apache NiFi 2.x
# simply creating a new tag/release in GitHub repository with the semantic form vX.Y.Z.
# GitHub Action is made to start automated build on Docker Hub when a new tag is created.
FROM apache/nifi:${NIFI_VERSION}

# Metadata standard OCI (Open Container Initiative)
LABEL org.opencontainers.image.title="Bytehawks NiFi custom image with Python Support"
LABEL org.opencontainers.image.description="Apache NiFi ${NIFI_VERSION} configured with Python 3 venv and libraries (Pandas, Azure SDK) for advanced data processing."
LABEL org.opencontainers.image.authors="Matteo Kutufa <mk@bytehawks.org>"
LABEL org.opencontainers.image.source="https://github.com/bytehawks-org/bytehawks-nifi"
LABEL org.opencontainers.image.version="${NIFI_VERSION}"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# We neeed to install Python, pip and some utilities (eg. curl and wget)
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure NiFi Python environment
USER nifi
WORKDIR /opt/nifi/nifi-current

ENV CUSTOM_PYTHON_ENV=/opt/nifi/nifi-current/custom-python/.venv
RUN python3 -m venv $CUSTOM_PYTHON_ENV
ENV PATH="$CUSTOM_PYTHON_ENV/bin:$PATH"
RUN mkdir /opt/nifi/nifi-current/custom-python/scripts && \
    chown -R nifi:nifi /opt/nifi/nifi-current/custom-python && \
    chmod 755 /opt/nifi/nifi-current/custom-python

# Install Python3 libraries from requirements.txt file
# (make sure to have a requirements.txt file in the same directory as this Dockerfile)
COPY --chown=nifi:nifi requirements.txt /opt/nifi/nifi-current/custom-python/requirements.txt
RUN python3 -m pip install --upgrade pip && \ 
    python3 -m pip install --no-cache-dir -r /opt/nifi/nifi-current/custom-python/requirements.txt
