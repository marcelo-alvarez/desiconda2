# conda packages
echo Installing conda packages at $(date)
echo condadir is $CONDADIR

#&& \
#conda install --copy --yes -c defaults --override-channels \
conda install --copy --yes -c conda-forge --override-channels \
    fitsio \
    libblas=*=*mkl \
    dask \
    distributed \
    papermill \
    nose \
    requests \
    future \
    cython \
    cmake \
    numpy \
    scipy \
    mkl=2020.0 \
    matplotlib \
    seaborn \
    pyyaml \
    astropy \
    pytest-astropy \
    hdf5 \
    h5py \
    psutil \
    ephem \
    psycopg2 \
    pytest \
    pytest-cov \
    numba \
    sqlalchemy \
    scikit-learn \
    scikit-image \
    ipython \
    jupyter \
    ipywidgets \
    bokeh \
    wurlitzer \
    certipy \
    sphinx \
    iminuit \
    cudatoolkit \
&& mplrc="$CONDADIR/lib/python$PYVERSION/site-packages/matplotlib/mpl-data/matplotlibrc"; \
    cat ${mplrc} | sed -e "s#^backend.*#backend : TkAgg#" > ${mplrc}.tmp; \
    mv ${mplrc}.tmp ${mplrc} \
&& rm -rf $CONDADIR/pkgs/*

if [ $? != 0 ]; then
    echo "ERROR installing conda packages; exiting"
    exit 1
fi

conda list --export | grep -v conda > "$CONDADIR/pkg_list.txt"
