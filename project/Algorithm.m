function [x,x_best,d,dkp,t_arr,generationenSpeicher, best_zwischen_d, best_zwischen_x, best_d_of_t] = ... 
                                              Algorithm(n,F,CR,my,max_Iter)

%% Anmerkungen zum Algorithmus & zur Notation
%--------------------------------------------
%-Notation-
%"F": Skalierungsfaktor
%"my": Populationsgröße
%"n": Kugelanzahl
%"CR": Rekombinationsrate
%"max_Iter": maximale Anzahl an Generationen
%t: Generation (zeitlicher Einfluss auf die Population)
%x: Population (Schar aus Mittelpunktscharen) 
%i: Individuum (Schar an Mittelpunkten)
%j: Allel (Mittelpunkt)
%--------------------------------------------
%-Anmerkungen-
%Individuum: "x/u(i,j,x/y/z)"
%--------------------------------------------

%% Inline-Function's

%Funktion: Zufällige Auswahl von drei Individuen
%in: n.v.
%out: Indizes für Individuen "r1","r2","r3"
function [r1,r2,r3] = Individuen_Mutation()
    
    Wahl_erfolgreich = false;
    
    %Zufällige ungleiche Indizes für Individuen erzeugen
    while ~Wahl_erfolgreich
        
        r1 = ceil(rand * my);
        r2 = ceil(rand * my);
        r3 = ceil(rand * my);
        
        if r1 ~= r2 && r1 ~= r3 && r2 ~= r3 && r1 ~= 0 && r2 ~= 0 ... 
                                                                && r3 ~= 0
            
            Wahl_erfolgreich = true;
            
        end
        
    end

end

%Funktion: Legalisierung eines potentiellen Nachkommens
%in: aktueller potentieller Nachkomme "u_akt" und Elter "x_akt"
%out: legaler potentieller Nachkomme "u_legal"
function u_legal = legaler_Mittelpunkt(u_akt,x_akt)
    
    %u_akt = [x,y,z]
    %x_akt = [x,y,z]
    for k = 1:length(u_akt)
        
        if u_akt(:,:,k) > 1 
            
            u_akt(k) = (x_akt(k) + 1) / 2;
            
        elseif u_akt(:,:,k) < 0
            
            u_akt(k) = x_akt(k) / 2;
            
        end
        
    end
    
    u_legal = u_akt;
    
end

%Methode: Minimalen Durchmesser ermitteln
%in: Individuum "x"
%out: (geringster) euklidischer Abstand "d_min"
function d_min = kleinsterDurchmesser(x)

    kleinsteDistanz = inf;                                                  %Initialwert für den geringsten euklidischen Abstand erzeugen

    for l = 1 : size(x,2)                                                   %überprüfe alle weiteren möglichen euklidischen Abstände

        for m = (l + 1) : size(x,2)

            if Distanz(x(:,l),x(:,m)) < kleinsteDistanz                     %aktuellen euklidischen Abstand "Distanz(population(n),population(m))" mit geringsten euklidischen Abstand vergleichen 
                                                    
                kleinsteDistanz = Distanz(x(:,l),x(:,m));                   %neuen geringsten euklidischen Abstand speichern                

            end

        end

    end

    d_min = kleinsteDistanz;                                                %geringsten euklidischen Abstand des Individuums ausgeben

end

%Methode: Euklidischer Abstand zwischen zwei Mittelpunkten
%in: Mittelpunkte "m1","m2"
%out: euklidischer Abstand "dist"
function dist = Distanz(m1, m2)
    
    %m(1):x, m(2):y, m(3):z
    dist = sqrt((m1(1) - m2(1))^2 + (m1(2) - m2(2))^2 ...                   %euklidischen Abstand zwischen "obj1" & "obj2" bilden und ausgeben
                                                      + (m1(3) - m2(3))^2);

end

%% Initialisierung (Hilfs-)Parameter
t = 1;                                                                      %Generationszähler setzen
t_0 = 1;                                                                    %Initialwert des Generationszählers setzen
f_delta_t = 1;                                                              %Abbruchkriterium (Konvergenz)
Einheitswuerfel_Kantenlaenge = 1;                                           %Seitenlänge Würfel setzen


%% Initialisierung: Generierung der Parentalgeneration für "t = 1"
for i = 1 : my
    
    for j = 1 : n                                                           %Belegung der Anfangspopulation
        
        %Kugelkoordinaten erzeugen
        x(i,j,1) = rand * Einheitswuerfel_Kantenlaenge;
        x(i,j,2) = rand * Einheitswuerfel_Kantenlaenge;
        x(i,j,3) = rand * Einheitswuerfel_Kantenlaenge;
        
    end
    
end

t = 1;                                                                      %Generationszähler nach Initialisierung setzen

%% Zwischenspeicher initialisieren und allokieren
speicherAnz = 10;
generationenSpeicher = zeros(speicherAnz,my,n,3);
speicherzeit = floor(max_Iter/speicherAnz);
zwischen_d=zeros(speicherAnz,my);

%% Schleife über Iterationsschritte
while t <= max_Iter                                                         %Abbruchkriterium (Konvergenz oder "max_Iter" erreicht)
    
    for i = 1 : my
        
        j_rand = round(rand * n);                                           %garantiere Crossover-Position im Indiviuum i zufällig erzeugen
        
        for j = 1 : n
            
            %Elter j des Individuums i speichern
            x_Elter_x(j) = x(i,j,1);
            x_Elter_y(j) = x(i,j,2);
            x_Elter_z(j) = x(i,j,3);
            
            %Mutation und Rekombination
            rand_j = rand;                                                  %zufälligen Wert zwischen 0 und 1 erzeugen
            if rand_j < CR || j == j_rand                                   %Mutationsbedingungen prüfen (wenn Eigenschaft vom Kind weitergeben wird, Binomialkriterium oder "j_rand")
                
                %Mutations-Individuen zufällig auswählen
                [r1,r2,r3] = Individuen_Mutation;           
                
                %Mutation
                u(i,j,:) = (x(r3,j,:) + F * (x(r1,j,:) - x(r2,j,:)));       %Nachkomme/Kind durch Mutation erzeugen                    
                
                u(i,j,:) = legaler_Mittelpunkt(u(i,j,:),x(r3,j,:));         %Mutation auf Legalität prüfen
                
            else
                
                u(i,j,:) = x(i,j,:);                                        %Nachkomme/Kind direkt aus Elter bilden
                
            end % if
            
            %Nachkomme j des Individuums i speichern
            x_Kind_x(j) = u(i,j,1);
            x_Kind_y(j) = u(i,j,2);
            x_Kind_z(j) = u(i,j,3);
            
        end % for j
        
        %Eltern und Nachkommen gesammelt abspeichern
        x_Kind = [x_Kind_x;x_Kind_y;x_Kind_z];
        x_Elter = [x_Elter_x;x_Elter_y;x_Elter_z];
        
        %Selektion
        if kleinsterDurchmesser(x_Kind) >= kleinsterDurchmesser(x_Elter)    %Fitnessfunktion: kleinsten Durchmesser maximieren
            
            x(i,:,:) = u(i,:,:);                                            %Nachkomme/Kind in die neue Generation/Population "t+1" übernehmen
            
            best_d_of_i(t,i) = kleinsterDurchmesser(x_Kind);                %(geringster) euklidischer Abstand "best_d_of_i" des Individuums "i" speichern
            
        else
            
            x(i,:,:) = x(i,:,:);                                            %Eltern unverändert in die neue Generation/Population "t+1" übernehmen
            
            best_d_of_i(t,i) = kleinsterDurchmesser(x_Elter);               %(geringster) euklidischer Abstand "best_d_of_i" des Individuums "i" speichern
            
        end % if
        
    end % for i
    
    best_d_of_t(t) = max(best_d_of_i(t,:));                                 %(geringster) euklidischer Abstand "best_d_of_t" der Generation "t" speichern
    
    %Zwischenspeichern 
    if mod(t, speicherzeit) == 0
        
        try
            
            generationenSpeicher(round(t/speicherzeit), :, :, :) ... 
                                                                = x(:,:,:);
            zwischen_d(round(t/speicherzeit),:) = best_d_of_i(t,:);
        
        catch
            msgID = 'Algorithm:kein_Speicher';
            msg = 'Zwischenspeichern der Population fehlgeschlagen';
            baseException = MException(msgID,msg);
            try
                
                assert(isinteger(mod(t, speicherzeit)), ...
                           'Algorithm: kein_int','Index ist kein Integer.')
                        
            catch causeException
                
                baseException = addCause(baseException,causeException);
                
            end
            
            if (mod(t, speicherzeit) > length(generationenSpeicher))
                
                msgID = 'Algorithm:incorrectSize';
                msg = 'Index is too high.';
                causeException2 = MException(msgID,msg);
                baseException = addCause(baseException,causeException2);
                
            end
            
            throw(baseException)
        
        end
        
    end
    
    t_arr(t) = t;                                                           %Generationszählerstand speichern
    
    t = t + 1;                                                              %Generationszähler "t" erhöhen
    
end %while

%% Ermittlung der besten Kugelsammlung
d = 0;

for idx = 1 : length(best_d_of_i(t-1,:))
    
    if best_d_of_i(t-1,idx) > d
        
        d = best_d_of_i(t-1,idx);
        x_best = x(idx,:,:);
        idx_best = idx;
        
    end

end

best_zwischen_d=zeros(speicherAnz,1);

for idx_t = 1 : speicherAnz
    for idx_sam = 1 : my
        if zwischen_d(idx_t,idx_sam) > best_zwischen_d(idx_t)

            best_zwischen_d(idx_t) = zwischen_d(idx_t,idx_sam);
            best_zwischen_x = generationenSpeicher(idx_t, idx_sam,:,:);
            best_zwischen_idx = idx;

        end
    end
    
end

if d ~= best_d_of_t(t-1)
    
    display('Fehler bei Bestimmung von max(d)');
    
end

%% Berechnung und Rückgabe der Packungsdichte
raumV = (1 + d)^3;
kugelV = 4 / 3 * pi * (d / 2)^3;
dkp = kugelV * double(n) / raumV;

%% Speichere Input und Output
inputvar = struct('n', n, 'F', F, 'CR', CR, 'my', my, ...
                                                    'max_Iter', max_Iter);
                                                
outputvar = struct('dkp', dkp,'d', d, 'x_best', x_best, 'idx_best', ...
            idx_best,'x', x, 'generationenSpeicher', ...
            generationenSpeicher, 'zwischen_d', zwischen_d, ...
            'best_zwischen_d', best_zwischen_d, 'best_zwischen_x', ...
            best_zwischen_x, 'best_zwischen_idx', best_zwischen_idx, ...
            'best_d_of_t', best_d_of_t);

c = clock;

inputfile = ['log/', 'input', '_', num2str(c(1)), '_', num2str(c(2)), ...
            '_', num2str(c(3)), '_', num2str(c(4)), '_', ...
            num2str(c(5)), '_', num2str(round(c(6))), '.mat'];
        
outputfile = ['log/', 'output', '_', num2str(c(1)), '_', num2str(c(2)), ...
            '_', num2str(c(3)), '_', num2str(c(4)), '_', ...
            num2str(c(5)), '_', num2str(round(c(6))), '.mat'];

save(inputfile, '-struct', 'inputvar');
save(outputfile, '-struct', 'outputvar');

end