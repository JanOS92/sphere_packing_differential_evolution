function Kugeldurchmesserplot(d,t,dKP,F,CR,my,max_Iter)

%% Startroutine


%% Durchmesserplot
h = figure('NumberTitle','off','name',datestr(now));
plot(t,d,'b-o');

%% Plot-Konfiguration
ylabel('Kugeldurchmesser d_n');
xlabel('Generation t');
title(['Packungsdichte: ' num2str(dKP) ' F: ' num2str(F) ...
    ' CR: ' num2str(CR) ' µ: ' num2str(my) ...
                                 ' max. Iterationen: ' num2str(max_Iter)]);
grid on;

end