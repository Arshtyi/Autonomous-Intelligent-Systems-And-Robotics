clear; clc;close all;
pB = [2; 3; 4];
thetaEnd = pi/2;
N = 90;
thetas = linspace(0, thetaEnd, N);
figure(1); clf; hold on; grid on; axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
xlim([-6 6]); ylim([-6 6]); zlim([-6 6]);
view(45, 25);
L = 5;
hAx = plot3([0 L],[0 0],[0 0],'r-','LineWidth',1.6);    % A_x
hAy = plot3([0 0],[0 L],[0 0],'g-','LineWidth',1.6);    % A_y
hAz = plot3([0 0],[0 0],[0 L],'b-','LineWidth',1.6);    % A_z
bx = plot3([0 L],[0 0],[0 0],'r--','LineWidth',1.2);
by = plot3([0 0],[0 0],[0 0],'g--','LineWidth',1.2);
bz = plot3([0 0],[0 0],[0 0],'b--','LineWidth',1.2);
hPath = plot3(nan, nan, nan, 'm-');
hPt   = plot3(nan, nan, nan, 'mo', 'MarkerFaceColor','m');
hTxt  = text(0,0,0,'','Color',[0.3 0 0.3],'FontSize',10,'HorizontalAlignment','left');
PA = zeros(3, N);
for k = 1:N
    th = thetas(k);
    R = [1 0 0;
         0 cos(th) -sin(th);
         0 sin(th)  cos(th)];
    pA = R * pB;
    PA(:,k) = pA;
    yb = R * [0;1;0];
    zb = R * [0;0;1];
    set(by,'XData',[0 L*yb(1)],'YData',[0 L*yb(2)],'ZData',[0 L*yb(3)]);
    set(bz,'XData',[0 L*zb(1)],'YData',[0 L*zb(2)],'ZData',[0 L*zb(3)]);
    set(hPt,  'XData',pA(1), 'YData',pA(2), 'ZData',pA(3));
    set(hPath,'XData',PA(1,1:k), 'YData',PA(2,1:k), 'ZData',PA(3,1:k));
    set(hTxt, 'Position', pA+0.2, 'String', sprintf('p_A = [%.2f, %.2f, %.2f]^T', pA));
    drawnow; pause(0.02);
end
pA_final = PA(:,end);
fprintf('旋转后点在参考系A中的坐标：[%g %g %g]^T\n', pA_final);
legend([hAx,hAy,hAz,bx,by,bz,hPt,hPath], ...
    {'A_x','A_y','A_z','B_x','B_y','B_z','p_A','轨迹'}, ...
    'Location','northeast');
