# Base image with micromamba for efficient environment management
FROM mambaorg/micromamba:1.5.10-noble
COPY --chown=$MAMBA_USER:$MAMBA_USER conda.yml /tmp/conda.yml
RUN micromamba install -y -n base -f /tmp/conda.yml \
    && micromamba install -y -n base conda-forge::procps-ng \
    && micromamba env export --name base --explicit > environment.lock \
    && echo ">> CONDA_LOCK_START" \
    && cat environment.lock \
    && echo "<< CONDA_LOCK_END" \
    && micromamba clean -a -y
USER root
ENV PATH="$MAMBA_ROOT_PREFIX/bin:$PATH"

# Copy Scaffold_QC.sh into /home/mambauser with correct ownership
COPY Scaffold_QC.sh /home/mambauser/Scaffold_QC.sh

RUN chmod +x /home/mambauser/Scaffold_QC.sh && \
    ln -s /home/mambauser/Scaffold_QC.sh /usr/local/bin/Scaffold_QC.sh && \
    ln -s /usr/local/bin/Scaffold_QC.sh /usr/local/bin/QC

# Switch to mamba user for QC
USER $MAMBA_USER

# Copy your real scaffold script
WORKDIR /home/usr

CMD ["/bin/bash"]