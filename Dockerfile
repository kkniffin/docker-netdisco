FROM phusion/baseimage
ENV NETDISCO_DB_USER ""
ENV NETDISCO_DB_PASS ""
ENV NETDISCO_DOMAIN ""
ENV NETDISCO_RO_COMMUNITY ""
ENV NETDISCO_WR_COMMUNITY ""
ENV NETDISCO_HOME "/netdisco"

RUN apt-get -yq update \
    && apt-get install -yq --no-install-recommends libdbd-pg-perl libsnmp-perl build-essential libnet-ldap-perl \
    postgresql-client curl && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir $NETDISCO_HOME
WORKDIR $NETDISCO_HOME
RUN curl -k -L http://cpanmin.us/ | perl - --notest --local-lib $NETDISCO_HOME/perl5 App::Netdisco
RUN cd /tmp && curl -o oui.txt http://linuxnet.ca/ieee/oui.txt
ENV PATH $NETDISCO_HOME/perl5/bin:$PATH
ADD startup.sh /
RUN chmod 755 /startup.sh
VOLUME /netdisco/environments
EXPOSE 5000
ENTRYPOINT ["/startup.sh"]
