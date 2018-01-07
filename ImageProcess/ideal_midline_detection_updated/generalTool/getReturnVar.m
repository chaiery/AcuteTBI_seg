function R = getReturnVar()
% rev related all codes

R.success = 0;

%% ventricle feature ( 10 <= rev < 30 )
R.ventricle = 10;

% the rev related with ideal midline like 11-15
R.idealmidline = 11;

% the rev related with actual midline like 16-19
R.actualmidline = 12;

%% Gray matter and White matter feature
% the rev related with GM and WM like 2*
R.GMandRM = 20;
R.GM = 21;
R.WM = 22;

%% Hemotoma feature ( 30 < = rev < 40 )
% the rev related with hemotoma like 3*
R.hemotoma = 30;

%% Other feature

end

