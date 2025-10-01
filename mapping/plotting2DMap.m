function plot = plotting2DMap(X, Y, PP, muscle, option)

    % Sort data
    [~, idx] = sortrows([X Y]);
    X_sorted = X(idx);
    Y_sorted = Y(idx);
    PP_sorted = PP(idx);
    
    % Get unique coordinates, i.e. [0, 1, 2]
    x_unique = unique(X_sorted);
    y_unique = unique(Y_sorted);
    
    [X_grid, Y_grid] = meshgrid(x_unique, y_unique);
    Z_grid = reshape(PP_sorted, length(y_unique), length(x_unique));
    mesh(X_grid, Y_grid, Z_grid);
    xlabel('X');
    ylabel('Y');
    zlabel('Mean');
    title('3D Mesh Plot');
    
    % Define a finer grid
    xq = linspace(min(X_grid(:)), max(X_grid(:)), 50);  
    yq = linspace(min(Y_grid(:)), max(Y_grid(:)), 50);  
    [Xq, Yq] = meshgrid(xq, yq);
    Zq = interp2(X_grid, Y_grid, Z_grid, Xq, Yq, 'cubic');  % 'linear', 'cubic', or 'spline'
    %%
    figure
    % creating the coloured map  
    subplot(2, 1, 1)
    contourf(xq, yq, Zq, 20, 'LineColor', 'none');  % 20 contour levels
    colorbar;
    xlabel('X'), ylabel('Y')
    % title('2D mapping');
    if nargin < 6 || isempty(option)
        title(['Plot of the mean cortical map for the ' muscle])
    else
        sessionNb = option;
        str_sessionNb = num2str(sessionNb);
        title(['Plot of the cortical map for the ' muscle ' for the session ' str_sessionNb])
    end
    
    % 3D plotting
    subplot(2, 1, 2)
    mesh(Xq, Yq, Zq)
    % title('3D mapping');   
    xlabel('X'), ylabel('Y')

    if nargin < 6 || isempty(option)
        title(['Plot of the 3D mean cortical map for the ' muscle])
    else
        sessionNb = option;
        str_sessionNb = num2str(sessionNb);
        title(['Plot of the 3D cortical map for the ' muscle ' for the session ' str_sessionNb])
    end
end