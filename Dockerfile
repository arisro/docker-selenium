FROM centos:centos7
MAINTAINER Buzachis Aris <buzachis.aris@gmail.com>

ENV http_proxy http://buc-net-proxy.ubisoft.org:3128
ENV https_proxy http://buc-net-proxy.ubisoft.org:3128

# Setup the docker user (for boot2docker)
RUN groupadd staff \
    && useradd -M -u 1000 -g 50 docker \
    && usermod -a -G staff docker

# Get rid of FTP mirrors (boot2docker issue)
RUN sed -i '/^mirrorlist=.*/s/^/#/g' /etc/yum.repos.d/CentOS-Base.repo \
    && sed -i '/^#baseurl=.*/s/^#//g' /etc/yum.repos.d/CentOS-Base.repo

# Add epel repo
RUN rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN echo 1
COPY chrome/google-chrome.repo /etc/yum.repos.d/

RUN yum -y update \
    && yum clean all

# Install supervisor
RUN yum -y install python-pip && pip install pip --upgrade
RUN pip install --ignore-installed --pre supervisor
RUN /usr/bin/echo_supervisord_conf > /etc/supervisord.conf \
    && mkdir -p /var/log/supervisor \
    && sed -i -e "s/^nodaemon=false/nodaemon=true/" /etc/supervisord.conf \
    && mkdir /etc/supervisord.d \
    && echo [include] >> /etc/supervisord.conf \
    && echo 'files = /etc/supervisord.d/*.ini' >> /etc/supervisord.conf

# selenium
RUN yum install -y Xvfb libXfont Xorg firefox unzip google-chrome-stable java-1.7.0-openjdk
RUN curl -o /tmp/selenium-server-standalone.jar http://selenium-release.storage.googleapis.com/2.46/selenium-server-standalone-2.46.0.jar
RUN curl -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/2.16/chromedriver_linux64.zip \
    && unzip /tmp/chromedriver_linux64.zip -d /tmp/ \
    && ln -fs /tmp/chromedriver /usr/bin/chromedriver
RUN echo 202cb962ac59075b964b07152d234b70 > /etc/machine-id

# vnc
RUN yum -y install http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
RUN echo 4
RUN yum install -y x11vnc ffmpeg
RUN rpm -i http://rpmfind.net/linux/centos/6.6/os/x86_64/Packages/xorg-x11-twm-1.0.3-5.1.el6.x86_64.rpm
RUN x11vnc -storepasswd vnc /tmp/vncpass

# Enable sudo with no passwd
RUN yum install -y sudo
RUN groupadd sudo \
    && echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && gpasswd -a docker sudo

# Copy configs
RUN echo "RandomPlacement" >> ~/.twmrc
COPY supervisor/*.ini /etc/supervisord.d/

COPY scripts/run.sh /run.sh
RUN chmod +x /run.sh

RUN mkdir -p /var/log/shared/screenshots
RUN chown -R docker:staff /var/log/shared

VOLUME /var/log/shared
EXPOSE 4444 5900

CMD ["/run.sh"]
