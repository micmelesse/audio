FROM docker

# # Register the ROCM package repository, and install rocm-dev package
# RUN apt update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl libnuma-dev gnupg \
#   && curl -sL http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | apt-key add - \
#   && printf "deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main" | tee /etc/apt/sources.list.d/rocm.list \
#   && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#   sudo \
#   libelf1 \
#   rocm-dev \
#   build-essential && \
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/*

RUN cat /etc/issue

RUN apk add git

