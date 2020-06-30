FROM centos:7 as base

RUN yum install -y epel-release
RUN yum install -y gcc gcc-gfortran gcc-c++ perl make cmake3 netcdf-devel

RUN mkdir /install_eco1280

WORKDIR /workdir

ADD http://www.fftw.org/fftw-3.3.8.tar.gz .
RUN tar xf fftw-3.3.8.tar.gz
RUN mkdir build_fftw && cd build_fftw && \
/workdir/fftw-3.3.8/configure --enable-single --enable-shared --prefix=/install_eco1280/libraries/fftw_lib && make && make install && \
/workdir/fftw-3.3.8/configure --enable-shared --prefix=/install_eco1280/libraries/fftw_lib && make && make install

ADD https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.12.5-Source.tar.gz .
RUN tar xf eccodes-2.12.5-Source.tar.gz
RUN mkdir build_eccodes && cd build_eccodes && \
cmake3 /workdir/eccodes-2.12.5-Source -DCMAKE_INSTALL_PREFIX=/install_eco1280/libraries/eccodes_lib -DENABLE_NETCDF=yes -DBUILD_SHARED_LIBS=ON -DENABLE_EXTRA_TESTS=ON -DNETCDF_PATH=/usr && make && make install

ADD https://confluence.ecmwf.int/download/attachments/3473472/libemos-4.5.9-Source.tar.gz .
RUN tar xf libemos-4.5.9-Source.tar.gz
RUN mkdir build_libemos && cd build_libemos && \
cmake3 /workdir/libemos-4.5.9-Source -DCMAKE_INSTALL_PREFIX=/install_eco1280/libraries/emoslib_lib -DFFTW_PATH=/install_eco1280/libraries/fftw_lib/lib -DECCODES_PATH=/install_eco1280/libraries/eccodes_lib -DENABLE_INSTALL_TOOLS=ON && \
make && make install


FROM centos:7

ENV intTool /libemos_tools/int
ENV grb2ncTool /install_eco1280/libraries/eccodes_lib/bin/grib_to_netcdf
ENV PATH=$PATH:/ECO1280_int_scripts 

RUN yum install -y epel-release
RUN yum install -y gcc-gfortran netcdf-devel

COPY --from=base /install_eco1280 /install_eco1280
COPY --from=base /workdir/build_libemos/tools /libemos_tools

ADD https://www.cira.colostate.edu/wp-content/uploads/2018/10/ECO1280_int_scripts.tar .
RUN mkdir /ECO1280_int_scripts && \
tar xf ECO1280_int_scripts.tar -C /ECO1280_int_scripts && \
rm ECO1280_int_scripts.tar

WORKDIR /ECO1280_int_scripts
