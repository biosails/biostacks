from continuumio/miniconda3

ARG CONDA_PKG=local
ENV CONDA_PKG ${CONDA_PKG}

RUN echo ${CONDA_PKG}
RUN which conda
RUN conda info


## We have to add the pkgs and the build-system
COPY pkgs/* /opt/conda/pkgs/
COPY conda-bld /opt/conda/conda-bld

#RUN conda config --set always_yes yes --set changeps1 no
#RUN conda config --add channels r
#RUN conda config --add channels conda-forge
#RUN conda config --add channels bioconda
#RUN conda config --add channels nyuad-cgsb
#
# conda config --add channels file://anaconda-conda-bld/linux-64
