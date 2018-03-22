function w = Wuerfelplot(axes_handles,origin,X,Y,Z,color)

%% Startroutine
ver =  [1 1 0;
        0 1 0;
        0 1 1;
        1 1 1;
        0 0 1;
        1 0 1;
        1 0 0;
        0 0 0];

fac =  [1 2 3 4;
        4 3 5 6;
        6 7 8 5;
        1 2 8 7;
        6 7 1 4;
        2 3 5 8];

%% Plot
cube = [ver(:,1) * X + origin(1),ver(:,2) * Y + origin(2),ver(:,3) ...
                                                          * Z + origin(3)];
                                                      
w = patch('Faces',fac,'Vertices',cube,'FaceColor',color, ...
                                                    'parent',axes_handles);

end

