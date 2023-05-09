classdef paramui < handle
% paramui(ParameterTable, UsrFunc)
% - Processing: Create UI from ParameterTable, assign UI parts values to Prm structure, call user function
% - Input: ParameterTable, UsrFunc
%   - ParameterTable: Containing the following Columns
%     PrameterVariable, ParameterLabel, InitialValue, Range(Slider:[Min,Max,Step], Selecter:{'A','B'...}, FileName:'*.txt;*.doc', Folder:'folder')
%   - Example:  PrameterVariable = {'A1','Num 1',0.5, [0, 1, 0.1];'F1','Flag 1',true,[];'Run','Run !',false,'button';'S1','Select 1','Two',{'One','Two','Three'};'Name','Name 1','Taro',[]; }
%     - Prm structure definition Prm.(ParameterVariable)
%       Example: Prm.A1=0.5, Prm.F1=false, Prm.Text='Taro',Prm.S1='Two', Prm.Run=true
%   - UsrFunc: Function handle Example: UserFunc = @(Prm) disp(Prm)
% - Usage 1: Run on UI event
% paramui(ParameterTable, @UsrFunc)
% - Usage 2: Loop & get UI parameters
% pu = paramui(ParameterTable);
% while pu.IsAlive
%    disp(pu.Prm);
% end


    properties
        UsrFunc;
        IsUsrFunc = false;
        IsAlive = false;
        Prm = {};
        UIFig;
        UsrCloseFunc = @() (true);
        UIName = 'ParamUI';
        UIWidth = 360;
        UIMaxHeight = 600;
        UIYSpace = 30;
    end
    methods
        function obj = paramui(ParameterTable, UsrFunc)
            if nargin == 1
                UsrFunc = @(p) true;
                obj.IsUsrFunc = false;
            else
               obj.IsUsrFunc = true;
           end
            if nargin >= 1
                obj.create_ui(ParameterTable, UsrFunc);
            end
        end

        function delete(obj)
            obj.UsrCloseFunc();
            delete(obj.UIFig);
        end

        function create_ui(obj, ParameterTable, UsrFunc)
            obj.IsAlive = true;
            obj.UsrFunc = UsrFunc;
            obj.Prm = struct();
            UIHeight = numel(ParameterTable(:, 1)) * obj.UIYSpace + obj.UIYSpace;
            FigHeight = min(UIHeight, obj.UIMaxHeight);
            obj.UIFig = uifigure('Name',obj.UIName, 'Scrollable','on', 'CloseRequestFcn', @(~,~) obj.UIClose);
            obj.UIFig.Position = [100, 100, obj.UIWidth, FigHeight];
            fig = obj.UIFig;
            for i = 1:size(ParameterTable, 1)
                paramVar = ParameterTable{i, 1};
                paramLabel = ParameterTable{i, 2};
                initialValue = ParameterTable{i, 3};
                stepVal = ParameterTable{i, 4};
                obj.Prm.(paramVar) = initialValue;
                posY = obj.UIYSpace * i;
                if ~isempty(initialValue) && isnumeric(initialValue)
                    minVal = stepVal(1);
                    maxVal = stepVal(2);
                    step_val = stepVal(3);
                    uislider(fig, 'Position', [120, UIHeight - posY- 10, 120, 3], 'Tag', paramVar,...
                        'Limits', [minVal, maxVal], 'Value', initialValue, 'MajorTicks', [], 'MinorTicks', [], ...
                        'ValueChangedFcn', @(src, ~) obj.sliderUpdate(src, paramVar));
                    uispinner(fig, 'Position', [250, UIHeight - posY - 20, 80, 20], 'Tag', [paramVar '_Spinner'], ...
                        'Limits', [minVal, maxVal], 'Value', initialValue, 'Step', step_val, ...
                        'ValueChangedFcn', @(src, ~)  obj.spinnerUpdate(src, paramVar));
                    uilabel(fig, 'Position', [20, UIHeight - posY - 20, 100, 20], 'Text', paramLabel, 'Tooltip',paramLabel);

                elseif islogical(initialValue) && ischar(stepVal) && strcmp(stepVal,'button')
                    uibutton(fig, 'Position', [120, UIHeight - posY - 20, 150, 20], 'Text', paramLabel, 'Tag', paramVar,...
                        'ButtonPushedFcn', @(src, ~) obj.actionButtonUpdate(src, paramVar));
                    obj.Prm.(paramVar) = false;

                elseif islogical(initialValue) && isempty(stepVal)
                    uicheckbox(fig, 'Position', [20, UIHeight - posY - 20, 150, 20], 'Text', paramLabel,'Tag', paramVar, ...
                        'Value', initialValue, 'ValueChangedFcn', @(src, ~) obj.checkboxUpdate(src, paramVar));

                elseif iscell(stepVal)
                    uidropdown(fig, 'Position', [120, UIHeight - posY - 20, 150, 20], 'Items', stepVal,'Tag', paramVar,  ...
                        'Value', initialValue, 'ValueChangedFcn', @(src, ~) obj.dropdownUpdate(src, paramVar));
                    uilabel(fig, 'Position', [20, UIHeight - posY - 20, 100, 20], 'Text', paramLabel,'Tooltip',paramLabel);

                elseif ischar(initialValue)
                    uieditfield(fig, 'Position', [120, UIHeight - posY - 20, 150, 20], 'Tag', paramVar,...
                        'Value', initialValue, 'ValueChangedFcn', @(src, ~) obj.editFieldUpdate(src, paramVar));
                    uilabel(fig, 'Position', [20, UIHeight - posY - 20, 100, 20], 'Text', paramLabel, 'Tooltip',paramLabel );
                    filePattern = '\*\.|folder';
                    if ischar(stepVal) && ~isempty(regexp(stepVal, filePattern, 'once'))
                        uibutton(fig, 'Position', [280, UIHeight - posY - 20, 50, 20], 'Text', 'Browse',...
                            'ButtonPushedFcn', @(src, ~)  obj.browseButtonUpdate(src, paramVar, stepVal));
                    end

                end
            end
            obj.UsrFunc(obj.Prm);
        end

        function sliderUpdate(obj, src, paramVar)
            spinner = findobj(src.Parent, 'Tag', [paramVar '_Spinner']);
            v = round(src.Value / spinner.Step) * spinner.Step;
            v = round(v,  floor(1-log10(spinner.Step)));
            src.Value = v;
            obj.Prm.(paramVar) = v;
            spinner.Value = v;
            obj.UsrFunc(obj.Prm);
        end

        function spinnerUpdate(obj, src, paramVar)
            v = round(src.Value / src.Step) * src.Step;
            v = round(v,  floor(1-log10(src.Step)));
            src.Value = v;
            obj.Prm.(paramVar) = v;
            slider = findobj(src.Parent, 'Tag', paramVar);
            slider.Value = v;
            obj.UsrFunc(obj.Prm);
        end

        function checkboxUpdate(obj, src, paramVar)
            obj.Prm.(paramVar) = src.Value;
            obj.UsrFunc(obj.Prm);
        end

        function dropdownUpdate(obj, src, paramVar)
            obj.Prm.(paramVar) = src.Value;
            obj.UsrFunc(obj.Prm);
        end

        function editFieldUpdate(obj, src, paramVar)
            obj.Prm.(paramVar) = src.Value;
            obj.UsrFunc(obj.Prm);
        end

        function browseButtonUpdate(obj, src, paramVar, stepVal)
            if strcmp(stepVal,'folder')
                path = uigetdir(stepVal, 'Select folder');
            else
                [file, path] = uigetfile(stepVal, 'Select file');
                if path ~= 0
                    path = fullfile(path, file);
                end
            end

            if path ~= 0
                editField = findobj(src.Parent, 'Tag', paramVar);
                editField.Value = path;
                obj.Prm.(paramVar) = path;
            end
            obj.UsrFunc(obj.Prm);
        end

        function actionButtonUpdate(obj, ~, paramVar)
            if obj.IsUsrFunc
                obj.UsrFunc(obj.Prm);
                obj.Prm.(paramVar) = false;
            else
                 obj.Prm.(paramVar) = true;
            end

        end

        function UIClose(obj)
            obj.IsAlive = false;
            if obj.UsrCloseFunc()
                obj.UIFig.delete();
            end

        end
    end
end
