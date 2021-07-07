#!/bin/bash

echo Starting desiconda installation at $(date)

# print commands as they are run so we know where we are if something fails
set -x

# Script directory

pushd $(dirname $0) > /dev/null
topdir=$(pwd)
popd > /dev/null

scriptname=$(basename $0)
fullscript="${topdir}/${scriptname}"

if [[ -z "${testrun}" ]]; then
  testrun=0
fi

if [[ -z "${cleanconda}" ]]; then
  cleanconda=0
fi

CONFDIR=$topdir/conf

CONFIGUREENV=$CONFDIR/$CONF-env.sh
INSTALLPKGS=$CONFDIR/$PKGS-pkgs.sh

CONDADIR=$PREFIX/conda
MODULEDIR=$PREFIX/modulefiles/desiconda

# delete any existing desiconda directory
if [ $cleanconda -gt 0 ]; then
  rm -rf $CONDADIR
fi

export PATH=$CONDADIR/bin:$PATH

# Initialize environment
source $CONFIGUREENV

# Install conda root environment
echo Installing conda root environment at $(date)

if [ ! -d $CONDADIR ]; then
  mkdir -p $CONDADIR/bin
  mkdir -p $CONDADIR/lib

  curl -SL $MINICONDA \
    -o miniconda.sh \
    && /bin/bash miniconda.sh -b -f -p $CONDADIR \
    && rm miniconda.sh \
    && rm -rf $CONDADIR/pkgs/* \
    && rm -f $CONDADIR/compiler_compat/ld

fi

source $CONDADIR/bin/activate

# Install packages
if [ $testrun -eq 0 ];
then
  which conda
  source $INSTALLPKGS
fi

# Compile python modules
echo Pre-compiling python modules at $(date)

python$PYVERSION -m compileall -f "$CONDADIR/lib/python$PYVERSION/site-packages"

# Set permissions
echo Setting permissions at $(date)

chgrp -R $GRP $CONDADIR
chmod -R u=rwX,g=rX,o-rwx $CONDADIR

# Install modulefile
echo Installing the desiconda modulefile at $(date)

MODULEDIR=$PREFIX/modulefiles/desiconda
mkdir -p $MODULEDIR

cp $topdir/modulefile.gen desiconda.module

sed -i 's@_CONDADIR_@'"$CONDADIR"'@g' desiconda.module
sed -i 's@_CONDAVERSION_@'"$CONDAVERSION"'@g' desiconda.module
sed -i 's@_PYVERSION_@'"$PYVERSION"'@g' desiconda.module

cp desiconda.module $MODULEDIR/$CONDAVERSION
cp desiconda.modversion $MODULEDIR/.version_$CONDAVERSION

chgrp -R $GRP $MODULEDIR
chmod -R u=rwX,g=rX,o-rwx $MODULEDIR

# All done
echo Done at $(date)
