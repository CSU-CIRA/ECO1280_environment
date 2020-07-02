
## Overview

Obtain and build the [EMOSLIB](https://confluence.ecmwf.int//display/EMOS/), [ecCodes](https://confluence.ecmwf.int//display/ECC/), and [FFTW](http://www.fftw.org/) software required to convert the ECMWF Nature Run GRIB files to NetCDF files containing data that has been converted to a latitude/longitude grid. More information about the Nature Run data can be found on the [CIRA website](https://www.cira.colostate.edu/imagery-data/ecmwf-nature-run/#conditions).

## Obtaining the code
Clone this repository to your local machine using `git clone https://github.com/CSU-CIRA/ECO1280_environment.git`

## Run instructions
### Environment set up
The conversion tools are intended to run in an environment described by
the Dockerfile in this repository. To minimize the size of the final
image, the Dockerfile is set up as a multistage build, with the first
stage downloading and building the EMOSLIB, ecCodes, and FFTW software
and the second stage shedding the build tools and artifacts and installing
the conversion tools. To build and use the Docker image, your machine
will need [Docker](https://www.docker.com/products/docker-desktop) installed.

### Building the image
Build the image using the command `docker build -t eco1280_convert:1.0 .`
Although the tag (`-t`) is optional, it will assign a name and version to
the resulting image which will make it easily locatable and also provide
a mechanism to have multiple versions available for testing and using
upgrades. Note the `.` assumes you are working in the directory that
contains the Dockerfile. To provide an alternate path, trade the period
out for `-f /path/to/the/Dockerfile`

### Creating a container from the image
Although the default Docker behavior will create a container that runs
as root, it is best practice to declare your own user when you create
the container to avoid messy security issues. For compatability with
the host machine, you can use your user and preferred group ids in the
container, or if compatability is not an issue, you may simply create a new user:group identification for the container. To get your user and group id
on the host (provided that you are working in a linux-like environment), use
`id -u [user name]` and `id -g [group name]`.

To create and run a container from the image, use
`docker run -it --name eco1280_convert -u uid:gid -v /path/to/data/on/host:/path/to/data/in/the/container eco1280_convert:1.0`,
adding -v flags before the image name as necessary to provide any data mounts
needed for the code to be able to access the necessary input data.
Again, the `--name` is optional but makes the container easily locatable.

### Entering the container
The `-it` flag in the `docker build` command will start an interactive
session within the container, where you will be dropped in the
`/ECO1280_int_scripts` directory where the conversion scripts are located.
If the container is stopped (you can check by running `docker ps`),
start it by running `docker start eco1280_convert` and then enter it
using `docker exec -it eco1280_convert /bin/bash`.

### Running the lat/lon converter
The main script for interpolation and conversion is `convert2ll`. It takes
input file from standard in and its output location as a command line
argument. A sample call looks like:
`echo /path/to/input/gxuz_ml_reducgg_0.grb | ./convert2ll -O /path/for/output/netcdf`



