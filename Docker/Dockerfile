FROM ubuntu:latest

RUN apt-get purge openjdk* &&  apt-get autoremove
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 5CB26B26 && echo "deb http://www.duinsoft.nl/pkg debs all" |  tee -a /etc/apt/sources.list.d/duinsoft.list && apt-get update
RUN apt-get install -y software-properties-common lsof
RUN add-apt-repository ppa:webupd8team/java && apt-get update
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN apt-get clean


RUN mkdir nukkit
COPY nukkit-1.0-SNAPSHOT.jar /nukkit
COPY server.properties /nukkit
COPY pocketmine.yml /nukkit
COPY nukkit.yml /nukkit
COPY run.sh /nukkit

EXPOSE 8080
CMD sh /nukkit/run.sh
