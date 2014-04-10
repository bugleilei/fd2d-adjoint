% travel time kernel calculation routine

% MAKE SURE V_OBS IS PRESENT!!!

% run forward
cd ../code/
[v_rec,t,u_fw,v_fw,rec_x,rec_z]=run_forward;


cd ../tools/
% check what the seismograms look like
v_rec_3 = [v_rec.x; v_rec.y; v_rec.z;];
plot_seismograms(v_rec_3,t,'velocity');

% make adjoint sources
adstf = make_all_adjoint_sources(v_rec,v_obs,t,'waveform_difference');

% check the adjoint source time functions
plot_vrec_to_adjointstf(t,v_rec.x,squeeze(adstf(1,:,:)));
plot_vrec_to_adjointstf(t,v_rec.y,squeeze(adstf(2,:,:)));
plot_vrec_to_adjointstf(t,v_rec.z,squeeze(adstf(3,:,:)));

% run adjoint 
cd ../code/
K = run_adjoint(u_fw,v_fw,adstf,'waveform_difference');

Lx=;     % model extension in x-direction [m]
Lz=;     % model extension in z-direction [m]
nx=;     % grid points in x-direction
nz=;     % grid points in z-direction
stf_PSV=;
[X,Z,dx,dz]=define_computational_domain(Lx,Lz,nx,nz);
[mu,rho,lambda]=define_material_parameters(nx,nz,11);
set_figure_properties_doffer;

cd ../tools/
calculate_other_kernels;
plot_kernels_rho_mu_lambda_relative;