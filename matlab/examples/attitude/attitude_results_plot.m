function [] = attitude_results_plot(ukf_states, ukf_Ps, states, omegas, dt)
%ATTITUDE_RESULTS_PLOT plot
%
% Syntax: [] = attitude_results_plot(ukf_states, ukf_Ps, states, ...
%               omegas, dt)

set(groot,'defaulttextinterprete','latex');  
set(groot, 'defaultAxesTickLabelInterprete','latex');  
set(groot, 'defaultLegendInterprete','latex');

% get true state
state_table = struct2table(states);
Rots = state_table.Rot;
N = length(Rots);
t = linspace(0, dt*N, N);

% get estimation state
ukf_state_table = struct2table(ukf_states);
ukf_Rots = ukf_state_table.Rot;

% compare to a vanilla dead-reckoning
dr_states = states(1);
w = zeros(3);
for n = 2:N
    dr_states(n) = attitude_f(dr_states(n-1), omegas(n-1), w, dt);
end
dr_state_table = struct2table(dr_states);
dr_Rots = dr_state_table.Rot;

% get roll, pitch, yaw and orientation error
rpys = zeros(3, N);
ukf_err = zeros(3, N);
dr_err = zeros(3, N);
for n = 1:N
    rpys(:, n) = so3_to_rpy(Rots{n});
    ukf_err(:, n) = so3_log(ukf_Rots{n}'*Rots{n});
    dr_err(:, n) = so3_log(dr_Rots{n}'*Rots{n});
end
ukf_three_sigma = 3*[sqrt(ukf_Ps(:, 1, 1))';
    sqrt(ukf_Ps(:, 2, 2))';
    sqrt(ukf_Ps(:, 3, 3))'];

% plot


fig = figure;
hold on;
title('Orientation')
xlabel('$t$ (s)')
ylabel('orientation (deg)')
hold on;
grid on;
plot(t, 180/pi*rpys(1, :), 'r');
plot(t, 180/pi*rpys(2, :), 'y');
plot(t, 180/pi*rpys(3, :), 'k');
legend('roll', 'pitch', 'yaw');
print(fig, 'matlab/examples/html/main_attitude_01', '-dpng', '-r600')

fig = figure;
hold on;
title('Roll error')
xlabel('$t$ (s)')
ylabel('Roll error (deg)')
hold on;
grid on;
plot(t, 180/pi*ukf_err(1, :), 'b');
plot(t, 180/pi*dr_err(1, :), 'm');
plot(t, 180/pi*ukf_three_sigma(1, :), 'b--');
plot(t, -180/pi*ukf_three_sigma(1, :), 'b--');
legend('UKF error', 'dead reckoning error', '$3\sigma$ UKF');
print(fig, 'matlab/examples/html/main_attitude_02', '-dpng', '-r600')

fig = figure;
hold on;
title('Pitch error')
xlabel('$t$ (s)')
ylabel('Pitch error (deg)')
hold on;
grid on;
plot(t, 180/pi*ukf_err(2, :), 'b');
plot(t, 180/pi*dr_err(2, :), 'm');
plot(t, 180/pi*ukf_three_sigma(2, :), 'b--');
plot(t, -180/pi*ukf_three_sigma(2, :), 'b--');
legend('UKF error', 'dead reckoning error', '$3\sigma$ UKF');
print(fig, 'matlab/examples/html/main_attitude_03', '-dpng', '-r600')

fig = figure;
hold on;
title('Yaw error')
xlabel('$t$ (s)')
ylabel('Yaw error (deg)')
hold on;
grid on;
plot(t, 180/pi*ukf_err(3, :), 'b');
plot(t, 180/pi*dr_err(3, :), 'm');
plot(t, 180/pi*ukf_three_sigma(3, :), 'b--');
plot(t, -180/pi*ukf_three_sigma(3, :), 'b--');
legend('UKF error', 'dead reckoning error', '$3\sigma$ UKF');
print(fig, 'matlab/examples/html/main_attitude_04', '-dpng', '-r600')
end
