function plot = plotting3DMap(X, Y, PP, muscle, option)

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
    
    % Define a finer grid
    xq = linspace(min(X_grid(:)), max(X_grid(:)), 50);  
    yq = linspace(min(Y_grid(:)), max(Y_grid(:)), 50);  
    [Xq, Yq] = meshgrid(xq, yq);
    Zq = interp2(X_grid, Y_grid, Z_grid, Xq, Yq, 'cubic');  % 'linear', 'cubic', or 'spline'

    % 3D plotting
    mesh(Xq, Yq, Zq)  
    xlabel('X'), ylabel('Y')

    if nargin < 5 || isempty(option)
        title(['Plot of the 3D mean cortical map for the ' muscle])
    else
        sessionNb = option;
        str_sessionNb = num2str(sessionNb);
        title(['Plot of the 3D cortical map for the ' muscle ' for the session ' str_sessionNb])
    end
end