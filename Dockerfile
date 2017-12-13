from continuumio/miniconda3

ARG CONDA_PKG=local
ENV CONDA_PKG ${CONDA_PKG}

RUN echo ${CONDA_PKG}
RUN which conda
RUN conda info
RUN mkdir -p /opt/conda/conda-bld/linux-64

## We have to add the pkgs and the build-system
COPY pkgs/* /opt/conda/pkgs/
COPY conda-bld/linux-64/${CONDA_PKG} /opt/conda/conda-bld/linux-64

RUN conda config --set always_yes yes --set changeps1 no
RUN conda config --add channels r
RUN conda config --add channels conda-forge
RUN conda config --add channels bioconda
RUN conda config --add channels nyuad-cgsb

RUN ls -lah /opt/conda/conda-bld/linux-64
RUN conda config --add channels file://opt/conda/conda-bld/linux-64
RUN conda index /opt/conda/conda-bld/linux-64
RUN conda install -y --use-local gencore_rnaseq
