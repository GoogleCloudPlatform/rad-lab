ARG PROJECT_ID
ARG OPENLANE_VERSION
FROM gcr.io/$PROJECT_ID/openlane-pdk:$OPENLANE_VERSION

RUN pip install jupyterlab
RUN groupadd --gid 1001 jupyter
RUN useradd --uid 1000 --gid 1001 jupyter
USER jupyter
EXPOSE 8080
ENV JUPYTER_PORT 8080

ENTRYPOINT ["/usr/local/bin/jupyter", "lab", "--ip", "0.0.0.0", "--allow-root", "--ServerApp.token=''", "--ServerApp.allow_origin_pat='^https?://.*\\.notebooks\\.googleusercontent\\.com'", "--ServerApp.allow_remote_access=True"]
