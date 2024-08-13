# ---- Build Stage ----
FROM elixir:1.17-alpine AS builder

# Set environment variables for building the application
ENV MIX_ENV=prod \
    TEST=1 \
    LANG=C.UTF-8

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force


# Create the application build directory
WORKDIR /app

# Copy over all the necessary application files and directories
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .

# Fetch the application dependencies and build the application
RUN mix deps.get
RUN mix deps.compile
RUN mix release

# ---- Application Stage ----
FROM alpine AS runtime

ENV LANG=C.UTF-8

# Install openssl
RUN apk update && apk add openssl ncurses-libs libstdc++

# Copy over the build artifact from the previous step
COPY --from=builder /app/_build .
COPY entrypoint.sh .

ENTRYPOINT ["sh", "./entrypoint.sh"]
