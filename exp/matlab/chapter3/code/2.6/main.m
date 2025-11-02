clc; clear; close all;
F_ori = [0.527 -0.574 0.628 5;
         0.369  0.819 0.439 3;
        -0.766  0     0.643 8;
         0      0     0     1];
T_y = transl(0, 10, 0);
T_z = transl(0, 0, 5);
F_mid = T_y * F_ori
F_fin = T_z * F_mid
n1 = 60;
n2 = 60;
Fs1 = ctraj(F_ori, F_mid, n1);
Fs2 = ctraj(F_mid, F_fin, n2);
Fs = cat(3, Fs1, Fs2(:,:,2:end));
N = size(Fs,3);
figure('Color','w');
axis equal; grid on; hold on;
xlabel('X'); ylabel('Y'); zlabel('Z'); view(3);
pts = squeeze(Fs(1:3,4,:));
minP = min(pts,[],2) - 1; maxP = max(pts,[],2) + 1;
axis([minP(1) maxP(1) minP(2) maxP(2) minP(3) maxP(3)]);
warnState = warning; warning('off','all');
h_start = trplot(F_ori, 'frame', 'Start', 'color', 'b', 'length', 1.0);
h_mid   = trplot(F_mid, 'frame', 'After Y', 'color', [0.85 0.33 0.1], 'length', 1.0);
h_goal  = trplot(F_fin, 'frame', 'Goal',  'color', 'g', 'length', 1.0);
warning(warnState);
h_traj = plot3(NaN,NaN,NaN, '-r', 'LineWidth', 1.6);
traj = nan(3, N);
for i = 1:N
    Fi = Fs(:,:,i);
    warning('off','all');
    h_frame = trplot(Fi, 'frame', sprintf('F_%d', i), 'color', [0.5 0 0.5], 'length', 1.0);
    warning(warnState);
    traj(:,i) = Fi(1:3,4);
    set(h_traj, 'XData', traj(1,1:i), 'YData', traj(2,1:i), 'ZData', traj(3,1:i));
    drawnow;
    pause(0.04);
    if i < N
        delete(h_frame);
    end
end
h_moving = h_frame;
legend([h_start h_mid h_goal h_traj h_moving], {'起始坐标系','After Y','目标坐标系','轨迹','移动坐标系'}, 'Location','best');
