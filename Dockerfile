# Use a base image with Wine
FROM scottyhardy/docker-wine:stable-5.0.2-nordp

# Wine setup
ENV WINEARCH=win32
ENV WINEPREFIX=/home/wineuser/.wine
RUN /usr/bin/entrypoint xvfb-run wineboot --init && \
    /usr/bin/entrypoint xvfb-run winetricks -q vcrun2015

# Install Miniconda and Mamba
ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean --all -f -y && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    /opt/conda/bin/conda install -n base -c conda-forge mamba -y

# Copy `environment.yml` first to take advantage of Docker's cache
COPY environment.yml /tmp/environment.yml
# Install Conda dependencies first
RUN /opt/conda/bin/mamba env update --name base --file /tmp/environment.yml \
    && rm /tmp/environment.yml \
    && /opt/conda/bin/mamba clean --all -f -y

# Install Pip packages separately
RUN /opt/conda/bin/pip install \
    pyqt5 pyqt5.sip h5py natsort lxml rastermap tifffile scanimage-tiff-reader \
    pyqtgraph importlib-metadata paramiko pynwb sbxreader suite2p click-pathlib
# Copy only the execution script (without affecting the environment cache)
COPY runscript.sh /apps/runscript.sh
CMD /apps/runscript.sh

# Copy the code afterward to avoid invalidating the dependency cache
COPY . /apps/two-photon/
RUN pip install /apps/two-photon
