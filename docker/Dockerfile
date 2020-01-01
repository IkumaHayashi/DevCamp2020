FROM centos:7

# rubyとrailsのバージョンを指定
ENV ruby_ver="2.5.0"
ENV rails_ver="5.2.2"

# 必要なパッケージをインストール
RUN yum -y update
RUN yum -y install git make autoconf curl wget vim
RUN yum -y install -y gcc-c++ openssl-devel readline-devel zlib-devel bzip2 gcc sqlite-devel
RUN curl -sL https://rpm.nodesource.com/setup_8.x | bash - ; yum -y install nodejs

# rbenvとruby-bundleをダウンロード
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build

# コマンドでrbenvが使えるように設定
RUN echo 'export RBENV_ROOT="/usr/local/rbenv"' >> /etc/profile.d/rbenv.sh
RUN echo 'export PATH="${RBENV_ROOT}/bin:${PATH}"' >> /etc/profile.d/rbenv.sh
RUN echo 'eval "$(rbenv init --no-rehash -)"' >> /etc/profile.d/rbenv.sh

# rubyとrailsをインストール
RUN source /etc/profile.d/rbenv.sh; rbenv install ${ruby_ver}; rbenv global ${ruby_ver}
RUN source /etc/profile.d/rbenv.sh; gem update --system; gem install --version ${rails_ver} --no-document rails; gem install bundle