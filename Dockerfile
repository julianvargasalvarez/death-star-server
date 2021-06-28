FROM ruby:2.6.3

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get install -y postgresql-client-9.5 w3m bc && \
    rm -rf /var/lib/apt/lists/*
ENV APP_HOME /death-star-server
ENV RAILS_LOG_TO_STDOUT true
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ENV BUNDLE_PATH $APP_HOME/.gems
ENV BUNDLE_APP_CONFIG $APP_HOME/.bundle
ENV GEM_HOME $APP_HOME/.gems
COPY ./.ssh /root/.ssh/
