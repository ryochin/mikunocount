FROM debian:stable-slim

ENV APP_DIR /app
WORKDIR $APP_DIR

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
  perl gcc curl make \
  && apt-get clean

RUN curl -L https://cpanmin.us | /usr/bin/perl - App::cpanminus

COPY cpanfile $APP_DIR

RUN /usr/local/bin/cpanm --notest Carton \
  && /usr/local/bin/carton install \
  && rm -rf /root/.cpanm/

COPY . $APP_DIR
RUN mkdir -p output

CMD ["/usr/local/bin/carton", "exec", "perl", "--", "create_count_json.pl", "-v", "-o", "output/count.json"]
