
% Define initial parameters
initParams = {
    'exponent', 'Exponent', 2, [1, 4, 0.1];
    'iterations', 'Iterations', 10, [1, 100, 1];
    'colormap', 'Color Map', 'jet', {'jet', 'hot', 'cool', 'gray'}
};

% Create a GUI for adjusting parameters and drawing the Mandelbrot set
paramui(initParams, @drawMandelbrot);

function drawMandelbrot(Prm)
    % Set up the grid of complex numbers
    imgSize = 200;
    x = linspace(-2, 1, imgSize);
    y = linspace(-1, 1, imgSize);
    [X, Y] = meshgrid(x, y);
    C = X + 1i * Y;

    % Initialize the Mandelbrot set matrix
    M = zeros(size(C));

    % Calculate the Mandelbrot set
    Z = C;
    for n = 1:Prm.iterations
        Z = Z.^Prm.exponent + C;
        M(abs(Z) > 2) = n;
    end

    % Plot the Mandelbrot set
    imagesc(x, y, M);
    axis equal;
    axis tight;
    colormap(Prm.colormap);
    title(['Mandelbrot Set (Exponent: ' num2str(Prm.exponent) ', Iterations: ' num2str(Prm.iterations) ')']);
    xlabel('Re');
    ylabel('Im');

    % Update the display
    drawnow();
end
