from continuumio/miniconda3

ARG CONDA_PKG=local
ENV CONDA_PKG ${CONDA_PKG}
RUN echo ${CONDA_PKG}
