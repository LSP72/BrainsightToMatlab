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
    
    if nargin < 4 || isempty(option)
        option = "contour"; 
    end

    switch option
        case "contour"
            contourf(xq, yq, Zq, 20, 'LineColor', 'none');  % 20 contour levels
            colorbar;
            titleTxt = '2D mapping';
        case "mesh"
            mesh(Xq, Yq, Zq)
            titleTxt = '3D mapping';   
        otherwise
            error("Unknown option: %s", option);
    end

    xlabel('X'), ylabel('Y')
    title(titleTxt)
end