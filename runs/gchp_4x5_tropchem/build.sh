#!/bin/bash

#------------------------------------------------------------------------------
#                  GEOS-Chem Global Chemical Transport Model                  !
#------------------------------------------------------------------------------
#BOP
#
# !MODULE: build.sh
# 
# !DESCRIPTION: Cleans and/or compiles a GEOS-Chem High Performance (GCHP) 
#  source code. Accepts one keyword argument indicating combination of clean 
#  and compile settings. 
#\\
#\\
# !REMARKS:
#  (1) Implemented arguments options include:
#         help (lists options)
#         check_mpi
#         clean_gc
#         clean_nuclear
#         clean_all
#         clean_mapl
#         compile_debug
#         compile_standard
#         compile_mapl
#         compile_clean
#  (2) To add a new one simply add an 'elif' block in the clean section
#      and/or the compile section.
#
# !REVISION HISTORY: 
#  19 Oct 2016 - E. Lundgren - Initial version
#  Navigate to your unit tester directory and type 'gitk' at the prompt
#  to browse the revision history.
#EOP
#------------------------------------------------------------------------------
#BOC

###############################
###  Configurable Settings  ###
###############################
# Ask user to source and export a bashrc, if not already done
if [[ "x${BASHRC}" == x ]]; then
   LIST=`ls -1 *.bashrc*`
   echo "Set up your environment by picking one of the following existing bashrcs,"
   echo "or exit and create your own file ending in '.bashrc':"
   n=1
   for f in ${LIST}; do
      echo "  ${n}. $f"
      n="$((${n}+1))"
   done
   echo "Enter an integer in range [1,$((${n}-1))], or 0 to exit:"
   read answer
   if [[ "$answer" == "0" ]]; then
       exit 1
   fi
   n=1
   for f in ${LIST}; do
      if [[ "$answer" == "${n}" ]]; then
	  echo "Now do the following:"
	  echo "   1. copy and execute 'source ${f}' if you haven't already"
          echo "   2. copy and execute 'export BASHRC=${f}'"
          echo "   3. run again"
	  exit 1
      fi
      n="$((${n}+1))"
   done   
else 
   echo "WARNING: You are using settings in ${BASHRC}"
fi

# Set compiler
export ESMF_COMPILER=intel

# Set MPI implementation
export ESMF_COMM=openmpi
#export ESMF_COMM=mvapich2

# Set ESMF optimization (g=debugging, O=optimized)
export ESMF_BOPT=g

# WARNING: Code changes are necessary if switching from openmpi to MVAPICH2
#  To run GCHP with MVAPICH2, you must have the following updates:
#    (1) In GCHP/GIGC.mk, the OpenMPI lines for setting MPI_LIB are
#        uncommented out and the MVAPICH line are commented out
#    (2) In GCHP/Makefile, "export ESMF_COMM=openmpi" is uncommented
#        and "export ESMF_COMM=mvapich2" are commented out
#    (3) In build.sh within the run directory, BASHRC is set to a
#        bashrc that includes "openmpi" in the filename (such as this)
#        and the ESMF_COMM export is set to openmpi
#   NOTE: eventually these changes will be automatic

###############################
###       Help              ###
###############################
if [[ $1 == "help" ]]; then
  echo "Script name:"
  echo "   build.sh"
  echo "Arguments:"
  echo "   Accepts single argument indicating clean and/or compile settings."
  echo "   Currently implemented arguments include:"
  echo "      clean_gc         - classic only"
  echo "      clean_nuclear    - GCHP, ESMF, MAPL, FVdycore (be careful!)"
  echo "      clean_all        - classic, GCHP, ESMF, MAPL, FVdycore (be careful!)"
  echo "      clean_mapl       - mapl and fvdycore only"
  echo "      compile_debug    - turns on debug flags, no cleaning"
  echo "      compile_standard - no cleaning"
  echo "      compile_mapl     - includes fvdycore"
  echo "      compile_clean    - cleans and compiles everything (be careful!)"
  echo "Example usage:"
  echo "   ./build.sh compile_standard"
  exit 0
fi

##########################################
###  Check MPI settings in source code ###
##########################################
if [[ $1 == "check_mpi" ]]; then
  echo "*** MPI settings in CodeDir/GCHP/GIGC.mk ***"
  echo " "
  grep "MPI settings" -A 11 CodeDir/GCHP/GIGC.mk
  echo "*** MPI settings in CodeDir/GCHP/Makefile ***"
  echo " "
  grep "MPI type" -A 4 CodeDir/GCHP/Makefile
  exit 0
fi

###############################
###     General Setup       ###
###############################

# Set run directory
runDir=$PWD

# Error check
if [[ ! -e CodeDir ]]; then
  echo "First set up a softlink to your code directory named CodeDir, e.g."
  echo " ln -s path/to/code CodeDir"
  exit 1
elif [[ $# == 0 ]]; then
  echo "Must pass argument to compile.sh"
  exit 1
elif [[ ! -f ${BASHRC} ]]; then
  echo "Bashrc file in build.sh does not exist"
  exit 1
fi

# Go to the source code directory
cd ${runDir}/CodeDir

###############################
###       Clean             ###
###############################

# clean_gc
if [[ $1 == "clean_gc" ]]; then
    make HPC=yes realclean

# clean_nuclear
elif [[ $1 == "clean_nuclear" ]]; then
    cd GCHP
    make EXTERNAL_GRID=y DEVEL=y the_nuclear_option
    cd ..

# clean_all
elif [[ $1 == "clean_all" ]]; then
    make HPC=yes realclean
    cd GCHP
    make the_nuclear_option
    cd ..

# clean_mapl
elif [[ $1 == "clean_mapl" ]]; then
    make realclean
    cd GCHP
    make EXTERNAL_GRID=y  DEVEL=y       DEBUG=y   MET=geos-fp      \
         GRID=4x5         NO_REDUCED=y  UCX=n     wipeout_fvdycore
    make EXTERNAL_GRID=y  DEVEL=y       DEBUG=y   MET=geos-fp      \
         GRID=4x5         NO_REDUCED=y  UCX=n     wipeout_mapl
    cd ..

# compile_debug
elif [[ $1 == "compile_debug" ]]; then
    cd GCHP
    make clean
    cd ..

# compile_standard
elif [[ $1 == "compile_standard" ]]; then
    cd GCHP
    make clean
    cd ..

# compile_mapl
elif [[ $1 == "compile_mapl" ]]; then
    make realclean
    cd GCHP
    make EXTERNAL_GRID=y  DEVEL=y       DEBUG=y   MET=geos-fp      \
         GRID=4x5         NO_REDUCED=y  UCX=n     wipeout_fvdycore
    make EXTERNAL_GRID=y  DEVEL=y       DEBUG=y   MET=geos-fp      \
         GRID=4x5         NO_REDUCED=y  UCX=n     wipeout_mapl
    cd ..

# compile_clean
elif [[ $1 == "compile_clean" ]]; then
    make HPC=yes realclean
    cd GCHP
    make EXTERNAL_GRID=y  DEVEL=y  the_nuclear_option
    cd ..

else
  echo "Argument passed to util.sh is not defined"
  echo "Defined options include:"
  echo "   clean_gc         - classic only"
  echo "   clean_nuclear    - GCHP, ESMF, MAPL, FVdycore (be careful!)"
  echo "   clean_all        - classic, GCHP, ESMF, MAPL, FVdycore (be careful!)"
  echo "   clean_mapl       - mapl and fvdycore only"
  echo "   compile_debug    - turns on debug flags, no cleaning"
  echo "   compile_standard - no cleaning"
  echo "   compile_mapl     - includes fvdycore"
  echo "   compile_clean    - cleans and compiles everything (be careful!)"
  exit 1
fi
 # Remove executable, if it exists
rm -f ${runDir}/CodeDir/bin/geos

# Check CPATH
echo "CPATH is: $CPATH"

###############################
###       Compile           ###
###############################
if [[ $1 == "compile_debug" ]]; then
    make -j${SLURM_NTASKS} NC_DIAG=y   CHEM=tropchem  EXTERNAL_GRID=y  \
                           DEBUG=y     DEVEL=y        TRACEBACK=y      \
                           MET=geosfp  GRID=4x5       NO_REDUCED=y     \
                           UCX=n       BOUNDS=y       FPEX=y           \
                           EXTERNAL_FORCING=y         hpc
elif [[ $1 == "compile_standard" ]] || \
     [[ $1 == "compile_mapl"     ]] || \
     [[ $1 == "compile_clean"    ]]; then
    make -j${SLURM_NTASKS} NC_DIAG=y   CHEM=tropchem EXTERNAL_GRID=y   \
                           DEBUG=y     DEVEL=y       TRACEBACK=y       \
                           MET=geos-fp GRID=4x5      NO_REDUCED=y      \
                           UCX=n       hpc
fi

###############################
###       Cleanup           ###
###############################
# Change back to the run directory
cd ${runDir}

# Cleanup and quit
if [[ -e ${runDir}/CodeDir/bin/geos ]]; then
   echo '###################################'
   echo '### GCHP compiled successfully! ###'
   echo '###################################'
   cp CodeDir/bin/geos .
else
   echo '###################################################'
   echo '### WARNING: GCHP executable does not yet exist ###'
   echo '###################################################'
   unset runDir
fi

unset runDir

exit 0
