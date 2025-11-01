clear; clc; close all;
Rx = @(ang) [1 0 0 0; 0 cosd(ang) -sind(ang) 0; 0 sind(ang) cosd(ang) 0; 0 0 0 1];
Rz = @(ang) [cosd(ang) -sind(ang) 0 0; sind(ang) cosd(ang) 0 0; 0 0 1 0; 0 0 0 1];
Txyz = @(x,y,z) [1 0 0 x; 0 1 0 y; 0 0 1 z; 0 0 0 1];
PB = [1; 5; 4; 1];
UTB = Rz(90) * Rx(90) * Txyz(0,0,3) * Txyz(0,5,0);
PA_final = UTB * PB;
N = 60;
axisLen = 2.2;
minV = [ inf  inf  inf];
maxV = [-inf -inf -inf];
for i=0:N
	T = Rx(90*i/N);
	p = T*PB; o=T*[0;0;0;1]; xx=T*[axisLen;0;0;1]; yy=T*[0;axisLen;0;1]; zz=T*[0;0;axisLen;1];
	pts = [ p(1:3)'; o(1:3)'; xx(1:3)'; yy(1:3)'; zz(1:3)' ];
	minV = min([minV; pts], [], 1); maxV = max([maxV; pts], [], 1);
end
T1 = Rx(90);
for i=0:N
	T = T1 * Txyz(0,0,3*i/N);
	p = T*PB; o=T*[0;0;0;1]; xx=T*[axisLen;0;0;1]; yy=T*[0;axisLen;0;1]; zz=T*[0;0;axisLen;1];
	pts = [ p(1:3)'; o(1:3)'; xx(1:3)'; yy(1:3)'; zz(1:3)' ];
	minV = min([minV; pts], [], 1); maxV = max([maxV; pts], [], 1);
end
T2 = T1 * Txyz(0,0,3);
for i=0:N
	T = Rz(90*i/N) * T2;
	p = T*PB; o=T*[0;0;0;1]; xx=T*[axisLen;0;0;1]; yy=T*[0;axisLen;0;1]; zz=T*[0;0;axisLen;1];
	pts = [ p(1:3)'; o(1:3)'; xx(1:3)'; yy(1:3)'; zz(1:3)' ];
	minV = min([minV; pts], [], 1); maxV = max([maxV; pts], [], 1);
end
T3 = Rz(90) * T2;
for i=0:N
	T = T3 * Txyz(0,5*i/N,0);
	p = T*PB; o=T*[0;0;0;1]; xx=T*[axisLen;0;0;1]; yy=T*[0;axisLen;0;1]; zz=T*[0;0;axisLen;1];
	pts = [ p(1:3)'; o(1:3)'; xx(1:3)'; yy(1:3)'; zz(1:3)' ];
	minV = min([minV; pts], [], 1); maxV = max([maxV; pts], [], 1);
end
span = max(maxV - minV, [1 1 1]);
pad = 0.15 * span;
xl = [minV(1)-pad(1), maxV(1)+pad(1)];
yl = [minV(2)-pad(2), maxV(2)+pad(2)];
zl = [minV(3)-pad(3), maxV(3)+pad(3)];
figure('Color','w','Position',[100 100 960 720]);
ax = axes('NextPlot','add'); grid on; box on; axis equal
xlabel('X'); ylabel('Y'); zlabel('Z'); view(45,25);
xlim(xl); ylim(yl); zlim(zl);
drawFrame(eye(4), 'k', 2.5, 2, '参考系A');
hFrameB = drawFrame(eye(4), [0.85 0.33 0.10], 2.2, 1.6, '移动系B');
trail = plot3(NaN,NaN,NaN,'-','Color',[0 0.45 0.74],'LineWidth',2,'DisplayName','点P轨迹');
hP = plot3(NaN,NaN,NaN,'o','MarkerSize',8,'MarkerFaceColor',[0.85 0.33 0.10],...
	'Color',[0.85 0.33 0.10],'DisplayName','点P当前');
legend('Location','northeast','AutoUpdate','off');
function hFrameB = updateScene(T, hFrameB, PB, hP, trail)
	persistent xs ys zs
	if isempty(xs); xs=[]; ys=[]; zs=[]; end
	PA = T * PB;
	xs(end+1)=PA(1); ys(end+1)=PA(2); zs(end+1)=PA(3);
	set(hP,'XData',PA(1),'YData',PA(2),'ZData',PA(3));
	set(trail,'XData',xs,'YData',ys,'ZData',zs);
	delete(hFrameB); hFrameB = drawFrame(T, [0.85 0.33 0.10], 2.2, 1.6, '移动系B');
	drawnow;
end
for i = 0:N
	T1 = Rx(90*i/N);
	hFrameB = updateScene(T1, hFrameB, PB, hP, trail);
end
T1 = Rx(90);
for i = 0:N
	T = T1 * Txyz(0,0,3*i/N);
	hFrameB = updateScene(T, hFrameB, PB, hP, trail);
end
T2 = T1 * Txyz(0,0,3);
for i = 0:N
	T = Rz(90*i/N) * T2;
	hFrameB = updateScene(T, hFrameB, PB, hP, trail);
end
T3 = Rz(90) * T2;
for i = 0:N
	T = T3 * Txyz(0,5*i/N,0);
	hFrameB = updateScene(T, hFrameB, PB, hP, trail);
end
T_final = T3 * Txyz(0,5,0);
disp('最终齐次变换 U_TB：');
disp(T_final);
disp('U_TB * P_B =');
disp(T_final * PB);
function h = drawFrame(T, color, len, lw, displayName)
	o = T*[0;0;0;1];
	x = T*[len;0;0;1]; y = T*[0;len;0;1]; z = T*[0;0;len;1];
	h(1) = plot3([o(1) x(1)],[o(2) x(2)],[o(3) x(3)],'-','Color',color,'LineWidth',lw,'DisplayName',displayName);
	h(2) = plot3([o(1) y(1)],[o(2) y(2)],[o(3) y(3)],'-','Color',color,'LineWidth',lw,'HandleVisibility','off');
	h(3) = plot3([o(1) z(1)],[o(2) z(2)],[o(3) z(3)],'-','Color',color,'LineWidth',lw,'HandleVisibility','off');
end
