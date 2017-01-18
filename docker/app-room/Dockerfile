FROM oydeu/oyd-shiny:latest
MAINTAINER "Christoph Fabianek" christoph@ownyourdata.eu

RUN cd /srv/shiny-server \
        && rm -rf * \
        && git clone https://github.com/OwnYourData/app-room.git \ 
        && mv app-room/* . \
        && rm -r app-room \
        && R -e "source('init.r')"

EXPOSE 3838

CMD ["/usr/bin/shiny-server.sh"]
