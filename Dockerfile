FROM oiax/rails6-deps:latest

ARG UID=1000
ARG GID=1000

# RUN apk update && apk add --no-cache nodejs
# apkパッケージを最新のものにアップデート
RUN apk update && apk upgrade

# Node.jsのインストールとアップデート
RUN apk add --no-cache nodejs npm
RUN npm install -g n && n latest

# RUN apt-get update -qq && apt-get install -y nodejs 

# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#   && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
#   && apt-get update -qq \
#   && apt-get install -y nodejs yarn
RUN mkdir /var/mail
RUN groupadd -g $GID devel
RUN useradd -u $UID -g devel -m devel
RUN echo "devel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /tmp
COPY init/Gemfile /tmp/Gemfile
COPY init/Gemfile.lock /tmp/Gemfile.lock
RUN bundle install

COPY ./apps /apps

RUN apk add --no-cache openssl shared-mime-info

USER devel

RUN openssl rand -hex 64 > /home/devel/.secret_key_base
RUN echo $'export SECRET_KEY_BASE=$(cat /home/devel/.secret_key_base)' \
  >> /home/devel/.bashrc

WORKDIR /apps
CMD ["npm", "start"]
