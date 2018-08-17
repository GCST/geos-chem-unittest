#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: gchp.gfortran_openmpi_odyssey.bashrc
#
# !DESCRIPTION: Source this bash file to compile and run GCHP with the GNU
#  Compiler Collection (GCC) v7.1.0 and MPI implementation OpenMPI on the 
#  Harvard University Odyssey cluster.
#\\
#\\
# !CALLING SEQUENCE:
#  source gchp.gfortran_openmpi_odyssey.bashrc
#
# !REMARKS
#
# !REVISION HISTORY:
#  26 Oct 2016 - S. Eastham  - Initial version
#  03 Feb 2017 - S. Eastham  - Updated for GCHP v1
#  05 Jan 2018 - E. Lundgren - Initial commit
#  See git commit history for subsequent revisions
#EOP
#------------------------------------------------------------------------------
#BOC

if [[ $- = *i* ]] ; then
  echo "Loading modules for GCHP on Odyssey, please wait ..."
fi

#==============================================================================
# Aliases (edit/add/remove based on your preferences)
#==============================================================================

# Clean run directory before a new run
# WARNING: will deleted gchp.log and contents of OutputDir
alias mco="make cleanup_output"       

# Recompile GC but not MAPL, ESMF, dycore
alias mcs="make compile_standard"     

# Submit a run as a batch job
alias gchprun="sbatch gchp.run"

# Follow log output on screen
alias tfl="tail --follow gchp.log -n 100"   

# Show current code git info
alias checkgit="make printbuildinfo"        

# Show build code git info
alias checkbuild="cat lastbuild" 

#==============================================================================
# Modules (specific to compute cluster)
#==============================================================================

module purge
module load git

# Modules for CentOS7
module load gcc/7.1.0-fasrc01
module load openmpi/3.1.1-fasrc01
module load netcdf/4.1.3-fasrc03

#==============================================================================
# Environment variables
#==============================================================================

# Specify compilers
export CC=gcc
export OMPI_CC=$CC

export CXX=g++
export OMPI_CXX=$CXX

export FC=gfortran
export F77=$FC
export F90=$FC
export OMPI_FC=$FC
export COMPILER=$FC
export ESMF_COMPILER=gfortran

# MPI Communication
export ESMF_COMM=openmpi
export MPI_ROOT=$MPI_HOME

# Base paths
export GC_BIN="$NETCDF_HOME/bin"
export GC_INCLUDE="$NETCDF_HOME/include"
export GC_LIB="$NETCDF_HOME/lib"

# Add to primary path
export PATH=${NETCDF_HOME}/bin:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_HOME}/lib

# If using NetCDF after the C/Fortran split (4.3+), then you will need to
# specify the following additional environment variables
#export GC_F_BIN="$NETCDF_FORTRAN_HOME/bin"
#export GC_F_INCLUDE="$NETCDF_FORTRAN_HOME/include"
#export GC_F_LIB="$NETCDF_FORTRAN_HOME/lib"
#export PATH=${NETCDF_FORTRAN_HOME}/bin:$PATH
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NETCDF_FORTRAN_HOME}/lib

# Set ESMF optimization (g=debugging, O=optimized (capital o))
export ESMF_BOPT=O

#==============================================================================
# Raise memory limits
#==============================================================================

ulimit -c unlimited              # coredumpsize
ulimit -l unlimited              # memorylocked
ulimit -u 50000                  # maxproc
ulimit -v unlimited              # vmemoryuse

#==============================================================================
# Print information for clarity
#==============================================================================

echo "Modules loaded:"
module list
echo ""
echo "Environment variables set:"
echo ""
echo "LD_LIBRARY_PATH: ${LD_LIBRARY_PATH}"
echo ""
echo "ESMF_COMM: ${ESMF_COMM}"
echo "ESMP_BOPT: ${ESMF_BOPT}"
echo "MPI_ROOT: ${MPI_ROOT}"
echo ""
echo "CC: ${CC}"
echo "OMPI_CC: ${OMPI_CC}"
echo ""
echo "CXX: ${CXX}"
echo "OMPI_CXX: ${OMPI_CXX}"
echo ""
echo "FC: ${FC}"
echo "F77: ${F77}"
echo "F90: ${F90}"
echo "OMPI_FC: ${OMPI_FC}"
echo "COMPILER: ${COMPILER}"
echo "ESMF_COMPILER: ${ESMF_COMPILER}"
echo ""
echo "GC_BIN: ${GC_BIN}"
echo "GC_INCLUDE: ${GC_INCLUDE}"
echo "GC_LIB: ${GC_LIB}"
echo ""
#echo "GC_F_BIN: ${GC_F_BIN}"
#echo "GC_F_INCLUDE: ${GC_F_INCLUDE}"
#echo "GC_F_LIB: ${GC_F_LIB}"
#echo ""
echo "Done sourcing ${BASH_SOURCE[0]}"