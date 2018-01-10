FROM ruby:2.5

MAINTAINER whywaita <https://github.com/whywaita>

RUN mkdir /app
WORKDIR /app
ADD Gemfile /app
ADD Gemfile.lock /app
RUN bundle install
COPY . /app

EXPOSE 4567

ENTRYPOINT ["rerun", "--background", "app.rb"]
