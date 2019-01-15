FROM ubuntu

RUN apt-get update && apt-get install -y \
  software-properties-common \
  apt-transport-https

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
RUN add-apt-repository 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
RUN apt-get update -y && apt-get install osquery
