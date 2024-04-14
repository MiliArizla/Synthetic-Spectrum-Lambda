# Set Up Amazon Linux as builder Image
FROM amazonlinux:2 AS pfant

# Install dependencies
RUN yum install -y gcc-gfortran git make

# Clone and make PFANT
RUN git clone --depth 1 https://github.com/trevisanj/PFANT.git && \
    cd PFANT/fortran && ./make-linux.sh

# Add environment variables
ENV PFANT_HOME /PFANT
ENV PATH="$PATH:$PFANT_HOME/fortran/bin"

# Copy grid.moo
COPY grid.moo $PFANT_HOME/data/common/grid.moo

# Setting up Lambda Python as base image
FROM public.ecr.aws/lambda/python:3.9

# Define PFANT Directories
ARG PFANT_HOME=/var/PFANT
ARG PFANT_BIN=${PFANT_HOME}/fortran/bin
ARG PFANT_DATA=${PFANT_HOME}/data

# Copy from PFANT to Lambda
COPY --from=pfant /PFANT/fortran/bin ${PFANT_BIN}
COPY --from=pfant /PFANT/data ${PFANT_DATA}

# Add PFANT to PATH
ENV PATH="${PATH}:/tmp/PFANT/fortran/bin"

# Install SynSSP and pyfant dependencies
RUN yum install -y amazon-linux-extras git mesa-libGL
RUN PYTHON=python2 amazon-linux-extras install R4 -y

# Install pyfant
COPY requirements.txt .
RUN pip install -r requirements.txt

# Install SynSSP
RUN git clone --depth 1 https://github.com/marinatrevisan/SynSSP_PFANTnew

# Copy R Script
COPY call_synssp.R ./SynSSP_PFANTnew

# Copy Handler to Lambda
COPY lambda_function.py .

# Run Handler
CMD ["lambda_function.handler"]
