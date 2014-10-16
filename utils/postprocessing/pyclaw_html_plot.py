import os
import sys
import shutil
import errno
from glob import glob
from clawpack.petclaw import plot
import matplotlib
matplotlib.use('Agg')
matplotlib.rcParams.update({'font.size': 10})

def copy(src, dest):
    try:
        shutil.copytree(src, dest)
    except OSError as e:
        # If the error was caused because the source wasn't a directory
        if e.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else:
            print('Directory not copied. Error: %s' % e)

def html_plot(src):
    plot.html_plot(outdir=src)

def main_plot(outdir='./_output',multiple=False,overwrite=False,savedir=None):
    if multiple:
        outdir = outdir+'*'
    
    outdirs = sorted(glob(outdir))
    print outdirs
    for dirs in outdirs:
        print dirs
        if overwrite or not os.path.exists('./_plots'):
            plot.html_plot(outdir=dirs)
        if savedir is None:
            savedir = os.path.join(dirs)
        if not os.path.exists(savedir):
            os.makedirs(os.path.join(savedir))
        copy('./_plots',os.path.join(savedir,'_plots'))
        shutil.rmtree('./_plots')

if __name__ == "__main__":
    from clawpack.pyclaw import util
    # kwargs={'outdir':'./','outbase':'_'}
    args,app_args = util._info_from_argv(sys.argv)
    # outbase = '_output'
    # outdir  = './'
    print app_args
    main_plot(**app_args)

    
