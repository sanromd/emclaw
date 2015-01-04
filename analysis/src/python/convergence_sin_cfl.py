import os
from convergence import Errors1D

matpath = '../matlab/results'
matsrc  = '_sin_nc_65536.mat'

testdir = '/simdesk/sandbox/emclaw/results/1D/_convergence_sin_src_averaged_homogeneous_cfl'
compare_dir = '/simdesk/sandbox/emclaw/results/1D/_convergence_sin'
basedir = '_output_'
basemin = 7
basemax = 13
frame   = 5

savedir = os.path.join(testdir,'_summary')

error = Errors1D(testdir,basedir,savedir,frame)

error.matsrc  = os.path.join(matpath,matsrc)
error.finesrc = os.path.join(testdir,basedir+'13')
error.basemin = basemin
error.basemax = basemax
error.debug   = True
error.homogeneous = True
error.p_line_range = [1,7]
error.compare_dir = compare_dir
error.compare = False

error.convergence()
