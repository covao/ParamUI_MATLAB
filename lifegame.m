function lifegame()
    % Life Game parameters
    ParameterTable = {'GridSize', 'Grid Size', 50, [10, 1000, 1]; ...
                      'Speed', 'Simulation Speed', 0.1, [0.01, 1, 0.01]; ...
                      'AliveRatio', 'Initial Alive Ratio', 0.3, [0, 1, 0.01]; ...
                      'SurviveMin', 'Survive Min Neighbors', 2, [0, 8, 1]; ...
                      'SurviveMax', 'Survive Max Neighbors', 3, [0, 8, 1]; ...
                      'BornMin', 'Born Min Neighbors', 3, [0, 8, 1]; ...
                      'BornMax', 'Born Max Neighbors', 3, [0, 8, 1]; ...
                      'Restart', 'Restart Life Game', false, 'button'; ...
                      'Glider', 'Spawn Glider', false, 'button'};
    pu = paramui(ParameterTable);
    hFig = figure('Name', 'Life Game', 'NumberTitle', 'off', 'MenuBar', 'none');
    hAx = axes(hFig, 'XLim', [0, pu.Prm.GridSize], 'YLim', [0, pu.Prm.GridSize], 'XTick', [], 'YTick', []);
    grid(hAx, 'on');
    hold(hAx, 'on');
    
    lifeGrid = init_life_grid(pu.Prm.GridSize, pu.Prm.AliveRatio);
    hCells = imagesc(hAx, lifeGrid);
    colormap(hAx, [1 1 1; 0 0.6 0]);

    while pu.IsAlive
        if pu.Prm.Restart
            set(hAx, 'XLim', [0, pu.Prm.GridSize], 'YLim', [0, pu.Prm.GridSize], 'XTick', [], 'YTick', []);
            lifeGrid = init_life_grid(pu.Prm.GridSize, pu.Prm.AliveRatio);
            hCells = imagesc(hAx, lifeGrid);
            colormap(hAx, [1 1 1; 0 0.6 0]);
            pu.Prm.Restart = false;
        elseif pu.Prm.Glider
            lifeGrid = spawn_glider(lifeGrid);
            pu.Prm.Glider = false;
        else
            lifeGrid = update_life_grid(lifeGrid, pu.Prm.SurviveMin, pu.Prm.SurviveMax, pu.Prm.BornMin, pu.Prm.BornMax);
        end
        hCells.CData = lifeGrid;
        pause(pu.Prm.Speed);
    end
    close(hFig);
end

function lifeGrid = init_life_grid(gridSize, aliveRatio)
    lifeGrid = rand(gridSize) < aliveRatio;
end

function lifeGrid = spawn_glider(lifeGrid)
    glider = [0 1 0; 0 0 1; 1 1 1];
    [x, y] = size(lifeGrid);
    x = randi(x - 2);
    y = randi(y - 2);
    lifeGrid(x:x+2, y:y+2) = glider;
end

function lifeGrid = update_life_grid(lifeGrid, surviveMin, surviveMax, bornMin, bornMax)
    countNeighbors = conv2(double(lifeGrid), [1 1 1; 1 0 1; 1 1 1], 'same');
    survive = (lifeGrid == 1) & (countNeighbors >= surviveMin) & (countNeighbors <= surviveMax);
    born = (lifeGrid == 0) & (countNeighbors >= bornMin) & (countNeighbors <= bornMax);
    lifeGrid = survive | born;
end
