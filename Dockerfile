from continuumio/miniconda3

COPY /home/jillian/.eb/software/Anaconda3/5.0.1/pkgs /anaconda-pkg-cache
COPY /home/jillian/.eb/software/Anaconda3/5.0.1/conda-bld /anaconda-conda-bld

ENV CONDA_PKGS_DIRS /anaconda/pkg-cache 
ENV CONDA_BLD_PATH /anaconda-conda-bld 

RUN conda add --channels file://anaconda-conda-bld
RUN conda index /anaconda-conda-bld/linux-64 

RUN cat ~/.condarc

RUN conda install -y gencore_test
