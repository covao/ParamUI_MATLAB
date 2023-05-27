% Define parameters
ParameterTable = {  
    'Speed', 'Simulation Speed', 0.3, [0.01, 1, 0.01]; 
    'N', 'Number of Spheres', 10, [1, 100, 1]; 
    'Radius', 'Sphere Radius', 0.2, [0.1, 1, 0.05]; 
    'BoxSize', 'Box Size', 10, [1, 100, 1]; 
    'Restart', 'Restart Simulation', false, 'button';
};

% Initialize UI
pu = paramui(ParameterTable);
hFig = figure;

% Initialize variables
N = pu.Prm.N; % Number of spheres is fixed until restart
pos = rand(N, 2) * pu.Prm.BoxSize; % positions
vel = randn(N, 2); % velocities

while pu.IsAlive
    if pu.Prm.Restart
        % Restart simulation
        N = pu.Prm.N; % Update number of spheres on restart
        pos = rand(N, 2) * pu.Prm.BoxSize; % positions
        vel = randn(N, 2); % velocities
        pu.Prm.Restart = false;
    end

    % Update positions
    pos = pos + pu.Prm.Speed * vel;

    % Check for collisions with walls and reverse velocity if necessary
    for i = 1:N
        if any(pos(i,:) < pu.Prm.Radius) || any(pos(i,:) > pu.Prm.BoxSize - pu.Prm.Radius)
            vel(i,:) = -vel(i,:);
        end
    end

    % Check for collisions between spheres
    for i = 1:N
        for j = i+1:N
            if norm(pos(i,:) - pos(j,:)) < 2 * pu.Prm.Radius
                % Swap velocities
                temp = vel(i,:);
                vel(i,:) = vel(j,:);
                vel(j,:) = temp;
            end
        end
    end

    % Plot spheres
    clf;
    hold on;
    axis([0 pu.Prm.BoxSize 0 pu.Prm.BoxSize]);
    for i = 1:N
        rectangle('Position', [pos(i,:) - pu.Prm.Radius, 2*pu.Prm.Radius, 2*pu.Prm.Radius], 'Curvature', [1 1]);
    end
    drawnow;

    % Pause
    pause(pu.Prm.Speed*0.01);
end

close(hFig);
