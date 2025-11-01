clc;clear;close all;
mdl_puma560;
p560 = SerialLink(p560);
q_sample = [0 -pi/4 -pi/4 0 pi/8 0];
T_sample = p560.fkine(q_sample);
qi_sample = p560.ikine(T_sample);
q_custom1 = [pi/4 -pi/2 pi/4 0 -pi/4 0];
q_custom2 = [0 pi/4 -pi/4 0 pi/2 0];
T_custom1 = p560.fkine(q_custom1);
T_custom2 = p560.fkine(q_custom2);
qi_custom1 = p560.ikine(T_custom1, 'tol', 1e-6);
qi_custom2 = p560.ikine(T_custom2, 'tol', 1e-6);
figure(1)
p560.plot(qz)
figure(2)
p560.plot(q_sample)
figure(3)
p560.plot(qi_custom1)
figure(4)
p560.plot(qi_custom2)
disp(q_custom1)
disp(qi_custom1)
disp(q_custom2)
disp(qi_custom2)
