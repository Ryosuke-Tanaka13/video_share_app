FROM ruby:3.0.3

# 必要なパッケージをインストール
RUN apt-get update -y && \
    apt-get install -y wget gnupg2 && \
    # Google Chromeの直接ダウンロードとインストール
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb || apt-get install -f

# Node.jsとYarnのインストール
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm uninstall yarn -g && \
    npm install yarn -g -y

# 足りない依存関係を解決するために実行する。
RUN yarn add moment-timezone tempusdominus-core

# ルート直下にwebappという名前で作業ディレクトリを作成
RUN mkdir /webapp
WORKDIR /webapp

# ホストのGemfileとGemfile.lockをコンテナにコピー
ADD Gemfile /webapp/Gemfile
ADD Gemfile.lock /webapp/Gemfile.lock

# bundle installの実行
RUN bundle install -j4

# ホストのアプリケーションディレクトリ内をすべてコンテナにコピー
ADD . /webapp

# 3000ポートを公開
EXPOSE 3000

# コンテナ起動時のコマンドを指定
CMD bash -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"
