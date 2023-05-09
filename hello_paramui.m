%Hello ParamUI for MATLAB
ParameterTable = { 
    'A', 'Parameter A', 0.5, [0, 1, 0.1];
    'B', 'Parameter B', 150, [100, 500, 10];
    'F1', 'Flag 1', true, [];
    'F2', 'Flag 2', false, [];
    'S1', 'Select 1','Two',{'One','Two','Three'};
    'S2', 'Select 2','Three',{'One','Two','Three'};
    'Name1','Name 1','Taro', [];
    'Name2','Name 2','Jiro', [];
    'File1','File 1','', '*.m; *.asv';
    'Folder','Folder1','', 'folder';
    'Run', 'Run!', false, 'button';
 };

%Example 1 Run by UI Event 
paramui(ParameterTable, @usrFunc);

%Define user function
function usrFunc(prm)
    if ~prm.Run
        return;
    end
    disp(prm);
end
