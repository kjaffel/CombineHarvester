
# Load LCG environment
source /cvmfs/sft.cern.ch/lcg/views/LCG_105/x86_64-el9-gcc11-opt/setup.sh

export PATH=${PATH}:${PWD}/build/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PWD}/build/lib
export PYTHONPATH=${PYTHONPATH}:${PWD}/build/lib/python

mkdir build
cd build

# Configure the build, pointing to the CombineTools directory
cmake ../. -DCMAKE_INSTALL_PREFIX=$PWD/../install

make -j 8

# Install the compiled code (optional)
make install
