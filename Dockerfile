FROM elixir:1.7-alpine
RUN mix local.hex --force
RUN mix local.rebar --force
WORKDIR /app
ADD . /app
RUN mix deps.get
RUN mix deps.compile
RUN mix compile
CMD mix phx.server
EXPOSE 4000
