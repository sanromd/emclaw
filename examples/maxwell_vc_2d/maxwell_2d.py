import sys
import os
import numpy as np
from emclaw.utils.materials import Material2D
from emclaw.utils.sources import Source2D
from emclaw.utils import basics

x_lower = 0.0
x_upper = 50.0

y_lower = 0.0
y_upper = 50.0

sy = y_upper-y_lower
sx = x_upper-x_lower

material = Material2D(shape = 'homogeneous', metal = False)
material.setup()
material._calculate_n()

def em2D(mx = 128, my = 128, num_frames = 10, use_petsc = True, reconstruction_order = 5, lim_type = 2,  cfl = 1.0, conservative = True,
         chi3 = 0.0, chi2 = 0.0, nl = False, psi = True, em = True, before_step = False, heading = 'x', shape = 'off', transversal_shape = 'plane', wavelength = 1.0, average_source = False,
         debug = False, outdir = './_output', output_style = 1, output_format='hdf5', write_aux = True, disable_output = False, keep_copy = True, verbosity = 3):
    
    import clawpack.petclaw as pyclaw
    import petsc4py.PETSc as MPI

    source = Source2D(material, shape = shape, wavelength = wavelength)
    source.amplitude[1] = source.amplitude[2] = 1000.0/material.zo
    
    if shape == 'off':
        source.offset.fill(5.0)
        if heading == 'xy':
            source.offset[0] = sy/2.0
            source.offset[1] = sx/2.0
    else:
        source.offset[0] = -5.0
        source.offset[1] = sy/2.0
        source.transversal_offset = sy/2.0
        source.transversal_width = sy
        source.transversal_shape = transversal_shape
    source.setup()
    source.heading = heading
    source.averaged = average_source

    #   grid pre calculations and domain setup
    _, _, dt, tf = basics.grid_basic([[x_lower,x_upper,mx], [y_lower,y_upper,my]], 
                                     cfl = cfl, co = material.co, v = source.v)

    if (debug and MPI.COMM_WORLD.rank==0):
        material.dump()
        source.dump()

    num_eqn   = 3
    num_waves = 2
    num_aux   = 6

    x = pyclaw.Dimension(x_lower, x_upper, mx, name = 'x')
    y = pyclaw.Dimension(y_lower, y_upper, my, name = 'y')

    domain = pyclaw.Domain([x,y])

#   Solver settings
    solver = pyclaw.SharpClawSolver2D()
    solver.num_waves  = num_waves
    solver.num_eqn    = num_eqn
    solver.reconstruction_order = reconstruction_order
    solver.lim_type = lim_type
    solver.dt_variable = True
    solver.dt_initial  = dt/2.0
    solver.dt_max      = dt
    solver.max_steps   = int(2*tf/dt)

#   Import Riemann and Tfluct solvers
    if conservative:
        from emclaw.riemann import maxwell_2d_rp
    else:
        from emclaw.riemann import maxwell_2d_nc_rp as maxwell_2d_rp

    solver.tfluct_solver = True
    solver.fwave = True

    solver.rp = maxwell_2d_rp

    if solver.tfluct_solver:
        if conservative:
            from emclaw.riemann import maxwell_2d_tfluct
        else:
            from emclaw.riemann import maxwell_2d_nc_tfluct as maxwell_2d_tfluct

    solver.tfluct = maxwell_2d_tfluct

    solver.cfl_max = cfl + 0.5
    solver.cfl_desired = cfl
    solver.reflect_index = [1,0]

#   boundary conditions
    if shape=='off':
        solver.bc_lower[0] = pyclaw.BC.wall
        solver.aux_bc_lower[0]= pyclaw.BC.wall
    else:
        solver.bc_lower[0] = pyclaw.BC.custom
        solver.aux_bc_lower[0]= pyclaw.BC.custom
        solver.user_bc_lower = source.scattering_bc
        solver.user_aux_bc_lower = material.setaux_lower

    solver.bc_lower[1] = pyclaw.BC.wall
    solver.bc_upper[0] = pyclaw.BC.wall
    solver.bc_upper[1] = pyclaw.BC.wall

    solver.aux_bc_lower[1] = pyclaw.BC.wall
    solver.aux_bc_upper[0] = pyclaw.BC.wall
    solver.aux_bc_upper[1] = pyclaw.BC.wall

#   before step configure
    if before_step:
        solver.call_before_step_each_stage = True
        solver.before_step = material.update_aux

#   state setup
    state = pyclaw.State(domain,num_eqn,num_aux)

    state.problem_data['chi2']  = material.chi2
    state.problem_data['chi3']  = material.chi3
    state.problem_data['vac1']  = material.eo
    state.problem_data['vac2']  = material.eo
    state.problem_data['vac3']  = material.mo
    state.problem_data['co'] = material.co
    state.problem_data['zo'] = material.zo
    state.problem_data['dx'] = state.grid.x.delta
    state.problem_data['dy'] = state.grid.y.delta
    state.problem_data['nl']     = nl
    state.problem_data['psi']    = psi

    source._dx = state.grid.x.delta
    source._dy = state.grid.y.delta

#   array initialization
    source.init(state)
    material.init(state)

    if conservative:
        state.q = state.q*state.aux[0:3,:,:]

#   controller
    claw = pyclaw.Controller()
    claw.solution = pyclaw.Solution(state,domain)
    claw.solver = solver
    claw.keep_copy = keep_copy
    claw.tfinal = tf
    claw.num_output_times = num_frames
    claw.output_style = output_style
    if np.logical_or(disable_output, output_format == None):
        claw.output_format = None
    else:
        claw.output_format = output_format
        claw.outdir = outdir
        claw.write_aux_always = write_aux
    
    if verbosity == False: verbosity = 0
    claw.verbosity = verbosity

    return claw

if __name__=="__main__":
    import sys
    from clawpack.pyclaw.util import run_app_from_main
    output = run_app_from_main(em2D)
