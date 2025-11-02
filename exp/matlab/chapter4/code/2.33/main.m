clc;clear;close all;
l1 = Link('d', 27, 'a', 0, 'alpha', -pi/2);
l2 = Link('d', 6,  'a', 15, 'alpha', 0, 'offset', pi/4);
l3 = Link('d', 0,  'a', 1,  'alpha', -pi/2);
l4 = Link('d', 18, 'a', 0,  'alpha', pi/2);
l5 = Link('d', 0,  'a', 0,  'alpha', pi/2);
l6 = Link('d', 0,  'a', 0,  'alpha', 0);
robot = SerialLink([l1 l2 l3 l4 l5 l6], 'name', 'PUMA562');
robot.display()
theta_deg = [0, 45, 0, 0, -45, 0];
theta_rad = deg2rad(theta_deg);
T_total = robot.fkine(theta_rad);
figure(1)
teach(robot, theta_rad)
hold on
plot3(0,0,0,'ro','MarkerSize',10)
q = theta_rad;
q1 = q(1); q2 = q(2); q3 = q(3); q4 = q(4); q5 = q(5); q6 = q(6);
% A = R_z*T_z*T_x*R_x
A1 = trotz(q1) * transl(0,0,27) * trotx(-pi/2);
