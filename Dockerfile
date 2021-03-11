FROM elixir

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get install -y nodejs

RUN apt-get install -y inotify-tools

RUN mix local.hex --force
RUN mix local.rebar --force

ENV APP_HOME /usr/src/app
WORKDIR $APP_HOME

EXPOSE 4000

CMD ["mix", "phx.server"]
