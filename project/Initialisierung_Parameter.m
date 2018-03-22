function [n_init,F_init,CR_init,my_init,max_Iterationen_init,F_min,F_max,CR_min,CR_max,Ver] = Initialisierung_Parameter() 

%% Parameter setzen
n_init = 10;
F_init = 0.15;
CR_init = 0.15;
my_init = 10*n_init;
max_Iterationen_init = 1000;
Ver = 'V1.0'

%% Grenzen
F_min = 0;
F_max = 1;
CR_min = 0;
CR_max = 1;

end