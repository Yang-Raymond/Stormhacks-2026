FROM node:22-bookworm-slim AS node
RUN npm install -g typescript@5.9 && npm cache clean --force

# Bookworm: every toolchain below (OpenJDK 17, GCC 12, Mono, cJSON, nlohmann-json) is packaged for it.
FROM python:3.12-slim-bookworm
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        default-jdk-headless \
        gcc g++ libc6-dev libcjson-dev nlohmann-json3-dev \
        mono-mcs libmono-system-core4.0-cil \
    && rm -rf /var/lib/apt/lists/*
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules/typescript /opt/typescript

RUN useradd --create-home --uid 10001 runner
WORKDIR /app
COPY server.py harness.py tracer.py sandbox.py ./
COPY languages ./languages
# Precompile the C++ prelude (bits/stdc++ + nlohmann/json); flags must match CXXFLAGS in languages/cpp.py.
RUN g++ -std=gnu++17 -O1 -x c++-header languages/cpp_prelude.hpp -o languages/cpp_prelude.hpp.gch
USER runner
EXPOSE 8000
CMD ["python", "server.py"]
