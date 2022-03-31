FROM gcr.io/deeplearning-platform-release/base-cpu
RUN apt-get update && apt-get -yq install locales locales-all
COPY provision.sh /tmp/provision.sh
COPY provision/ /tmp/provision/
RUN bash -x /tmp/provision.sh
ENV OPENLANE_ROOT=/OpenLane
ENV PATH=$OPENLANE_ROOT:$OPENLANE_ROOT/scripts:$PATH
