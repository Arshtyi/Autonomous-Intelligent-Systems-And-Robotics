clear; clc; close all;
Rot_z = [0 -1 0 0;
         1  0 0 0;
         0  0 1 0;
         0  0 0 1];
Trans = [1 0 0  4;
         0 1 0 -3;
         0 0 1  7;
         0 0 0  1];
Rot_y = [ 0 0 1 0;
          0 1 0 0;
         -1 0 0 0;
          0 0 0 1];
p0 = [7; 3; 1; 1];
n_frames = 40;
figure('Color', 'w', 'Position', [100 100 900 700]);
hold on; grid on; box on;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(45, 25);
axis equal;
xlim([-5 12]); ylim([-5 10]); zlim([-3 10]);
drawCoordinateSystem(eye(4), 'k', 2.5, 2);
trail_x = p0(1); trail_y = p0(2); trail_z = p0(3);
h_trail = plot3(trail_x, trail_y, trail_z, 'r-', 'LineWidth', 2);
h_point = plot3(p0(1), p0(2), p0(3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', '当前点位置');
h_text = text(p0(1), p0(2), p0(3)+0.5, sprintf('(%.1f,%.1f,%.1f)', p0(1:3)), ...
              'FontSize', 10, 'Color', 'r');
h_frame = drawCoordinateSystem(eye(4), 'r', 2, 1.5);
set(h_trail, 'DisplayName', '运动轨迹');
legend('Location', 'northeast', 'AutoUpdate', 'off');
pause(1);
fprintf('初始点:        P0 = (%.1f, %.1f, %.1f)\n', p0(1:3));
for i = 1:n_frames
    angle = (i/n_frames) * 90;
    Rot_z_temp = [cosd(angle) -sind(angle) 0 0;
                  sind(angle)  cosd(angle) 0 0;
                  0            0           1 0;
                  0            0           0 1];
    p_temp = Rot_z_temp * p0;
    trail_x(end+1) = p_temp(1);
    trail_y(end+1) = p_temp(2);
    trail_z(end+1) = p_temp(3);
    set(h_trail, 'XData', trail_x, 'YData', trail_y, 'ZData', trail_z, 'Color', 'b');
    delete(h_point); delete(h_text); delete(h_frame);
    h_point = plot3(p_temp(1), p_temp(2), p_temp(3), 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b', 'DisplayName', '当前点位置');
    h_text = text(p_temp(1), p_temp(2), p_temp(3)+0.5, sprintf('(%.1f,%.1f,%.1f)', p_temp(1:3)), ...
                  'FontSize', 10, 'Color', 'b');
    h_frame = drawCoordinateSystem(Rot_z_temp, 'b', 2, 1.5);
    drawnow;
    pause(0.04);
end
p1 = Rot_z * p0;
fprintf('绕Z轴旋转90°:  P1 = (%.1f, %.1f, %.1f)\n', p1(1:3));
pause(0.5);
for i = 1:n_frames
    ratio = i/n_frames;
    Trans_temp = [1 0 0  4*ratio;
                  0 1 0 -3*ratio;
                  0 0 1  7*ratio;
                  0 0 0  1];
    p_temp = Trans_temp * p1;
    trail_x(end+1) = p_temp(1);
    trail_y(end+1) = p_temp(2);
    trail_z(end+1) = p_temp(3);
    set(h_trail, 'XData', trail_x, 'YData', trail_y, 'ZData', trail_z, 'Color', 'g');
    delete(h_point); delete(h_text); delete(h_frame);
    h_point = plot3(p_temp(1), p_temp(2), p_temp(3), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', 'DisplayName', '当前点位置');
    h_text = text(p_temp(1), p_temp(2), p_temp(3)+0.5, sprintf('(%.1f,%.1f,%.1f)', p_temp(1:3)), ...
                  'FontSize', 10, 'Color', 'g');
    h_frame = drawCoordinateSystem(Trans_temp * Rot_z, 'g', 2, 1.5);
    drawnow;
    pause(0.04);
end

p2 = Trans * p1;
fprintf('平移[4,-3,7]:  P2 = (%.1f, %.1f, %.1f)\n', p2(1:3));
pause(0.5);
for i = 1:n_frames
    angle = (i/n_frames) * 90;
    Rot_y_temp = [ cosd(angle) 0 sind(angle) 0;
                   0           1 0           0;
                  -sind(angle) 0 cosd(angle) 0;
                   0           0 0           1];
    p_temp = Rot_y_temp * p2;
    trail_x(end+1) = p_temp(1);
    trail_y(end+1) = p_temp(2);
    trail_z(end+1) = p_temp(3);
    set(h_trail, 'XData', trail_x, 'YData', trail_y, 'ZData', trail_z, 'Color', 'm');
    delete(h_point); delete(h_text); delete(h_frame);
    h_point = plot3(p_temp(1), p_temp(2), p_temp(3), 'mo', 'MarkerSize', 10, 'MarkerFaceColor', 'm', 'DisplayName', '当前点位置');
    h_text = text(p_temp(1), p_temp(2), p_temp(3)+0.5, sprintf('(%.1f,%.1f,%.1f)', p_temp(1:3)), ...
                  'FontSize', 10, 'Color', 'm');
    h_frame = drawCoordinateSystem(Rot_y_temp * Trans * Rot_z, 'm', 2, 1.5);
    drawnow;
    pause(0.04);
end
p3 = Rot_y * p2;
fprintf('绕Y轴旋转90°:  P3 = (%.1f, %.1f, %.1f)\n', p3(1:3));
fprintf('\n最终结果: P_final = (%.1f, %.1f, %.1f)\n', p3(1:3));
function handles = drawCoordinateSystem(T, color, len, linewidth)
    origin = T * [0; 0; 0; 1];
    x_axis = T * [len; 0; 0; 1];
    y_axis = T * [0; len; 0; 1];
    z_axis = T * [0; 0; len; 1];
    handles = zeros(3, 1);
    handles(1) = plot3([origin(1) x_axis(1)], [origin(2) x_axis(2)], [origin(3) x_axis(3)], ...
                       'Color', color, 'LineWidth', linewidth, 'HandleVisibility', 'off');
    handles(2) = plot3([origin(1) y_axis(1)], [origin(2) y_axis(2)], [origin(3) y_axis(3)], ...
                       'Color', color, 'LineWidth', linewidth, 'HandleVisibility', 'off');
    handles(3) = plot3([origin(1) z_axis(1)], [origin(2) z_axis(2)], [origin(3) z_axis(3)], ...
                       'Color', color, 'LineWidth', linewidth, 'HandleVisibility', 'off');
end
