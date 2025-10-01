function Z_grid = MEPGrid(X, Y, PP)
    [~, idx] = sortrows([X Y]);
    X_sorted = X(idx);
    Y_sorted = Y(idx);
    PP_sorted = PP(idx);
    
    % Get unique coordinates, i.e. [0, 1, 2]
    x_unique = unique(X_sorted);
    y_unique = unique(Y_sorted);
    
    [X_grid, Y_grid] = meshgrid(x_unique, y_unique);
    Z_grid = reshape(PP_sorted, length(y_unique), length(x_unique));
end