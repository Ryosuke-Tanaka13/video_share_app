FROM ruby:3.0.3

# Add Chrome installation
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -y \
    && apt-get -y install google-chrome-stable

RUN apt-get update -y && \
    apt-get install default-mysql-client nodejs npm vim graphviz -y && \
    npm uninstall yarn -g && \
    npm install yarn -g -y && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# ルート直下にwebappという名前で作業ディレクトリを作成（コンテナ内のアプリケーションディレクトリ）
RUN mkdir /webapp
WORKDIR /webapp

# ホストのGemfileとGemfile.lockをコンテナにコピー
ADD Gemfile /webapp/Gemfile
ADD Gemfile.lock /webapp/Gemfile.lock

# bundle installの実行
RUN bundle install -j4

# ホストのアプリケーションディレクトリ内をすべてコンテナにコピー
ADD . /webapp

# アセットのプリコンパイル
RUN SECRET_KEY_BASE=placeholder RAILS_ENV=production bundle exec rails assets:precompile \
 && yarn cache clean \
 && rm -rf node_modules tmp/cache

EXPOSE 3000

CMD bash -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"
