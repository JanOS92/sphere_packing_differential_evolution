function Kugelplot(axes_handles,d,xC,yC,zC,dKP,F,CR,my,max_Iter)
    
    %% Startroutine
    Kugelplot_loeschen(axes_handles);
    
    %% Dimensionskontrolle
    if length(xC) == length(yC) && length(xC) == length(zC) && ...
                                                   length(zC) == length(yC)
        
        arr_laenge = length(xC);                                            %gemeinsame Array-L�nge festlegen
        
        for index = 1:1:arr_laenge
           
            %% Kugelplot
            r = d/2;
            [x,y,z] = sphere();                                             %erzeuge eine Einheitskugel
            s = surf(x*r+xC(index),y*r+yC(index),z*r+zC(index), ...         %skaliere und verschiebe die Enheitskugel
                                                    'parent',axes_handles); 
            
            %% Kugelplot-Konfiguration
            set(s,'FaceColor',[0 0 1],'FaceAlpha',0.5,...
                                                   'EdgeColor',[.9 .9 .9]);
            hold on;
            axis equal;
            xlabel('x');
            ylabel('y');
            zlabel('z');
            title '';
            grid on;
            
        end
        
    end
    
    w = Wuerfelplot(axes_handles,[-r,-r,-r],1+d,1+d,1+d,'none');            %einschlie�enden W�rfel erzeugen
    
    %Kugelplot in neues Fenster �berf�hren
    h = figure('NumberTitle','off','name',datestr(now), 'Color', [1 1 1]);
    a = copyobj(get(s,'parent'),h);
    title(a,['Packungsdichte: ' num2str(dKP) ' F: ' num2str(F) ...
        ' CR: ' num2str(CR) ' �: ' num2str(my) ...
                                 ' max. Iterationen: ' num2str(max_Iter)]);
    
end