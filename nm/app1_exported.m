classdef app1_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        minimizeMButton        matlab.ui.control.Button
        drawWCheckBox          matlab.ui.control.CheckBox
        drawZCheckBox          matlab.ui.control.CheckBox
        ShowduCheckBox         matlab.ui.control.CheckBox
        CurFvalEditField       matlab.ui.control.NumericEditField
        CurFvalEditFieldLabel  matlab.ui.control.Label
        CurTvalEditField       matlab.ui.control.NumericEditField
        CurTvalEditFieldLabel  matlab.ui.control.Label
        TZkritEditField        matlab.ui.control.NumericEditField
        TZkritEditFieldLabel   matlab.ui.control.Label
        du0EditField           matlab.ui.control.NumericEditField
        u0Label                matlab.ui.control.Label
        u0EditField            matlab.ui.control.NumericEditField
        u0EditFieldLabel       matlab.ui.control.Label
        MKCheckBox             matlab.ui.control.CheckBox
        BAEditFieldLabel       matlab.ui.control.Label
        BAEditField            matlab.ui.control.NumericEditField
        MFieldEditField        matlab.ui.control.NumericEditField
        MFieldEditFieldLabel   matlab.ui.control.Label
        MSlider                matlab.ui.control.Slider
        MSliderLabel           matlab.ui.control.Label
        KFieldEditField        matlab.ui.control.NumericEditField
        KFieldEditFieldLabel   matlab.ui.control.Label
        CFieldEditField        matlab.ui.control.NumericEditField
        CFieldEditFieldLabel   matlab.ui.control.Label
        TFieldEditField        matlab.ui.control.NumericEditField
        TFieldEditFieldLabel   matlab.ui.control.Label
        KSlider                matlab.ui.control.Slider
        KSliderLabel           matlab.ui.control.Label
        CSlider                matlab.ui.control.Slider
        CSliderLabel           matlab.ui.control.Label
        TSlider                matlab.ui.control.Slider
        TSliderLabel           matlab.ui.control.Label
        UIAxes2                matlab.ui.control.UIAxes
        UIAxes                 matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        k = real(2);
        c = real(0.01);
        t = real(1);
        m = real(1); %
        u0 = real(0.01);
        du0 = real(0);
        % Description
    end
    
    methods (Access = private)
        function b = B(app)
           zn = (app.m * app.m + app.k * app.k);
           b = zn * zn / 4 / app.k / app.k;
        end

        function redraw(app)
            
            function drawZ(t1,f)
%             ***Test functions***
%             a = exact1(t1);     
%             plot(app.UIAxes,t1,a,'-o')
%             hold(app.UIAxes,"on")
                if app.ShowduCheckBox.Value
                    p1 = plot(app.UIAxes,t1,f(:,1));
                    hold(app.UIAxes,"on")
                    p2 = plot(app.UIAxes,t1,f(:,2));
                    axis(app.UIAxes, 'tight');
                    hold(app.UIAxes,"off")
                    legend(app.UIAxes,[p1 p2],{'u','u`'})
                else
                    p1 = plot(app.UIAxes,t1,f(:,1));
                    axis(app.UIAxes, 'tight');
                    legend(app.UIAxes,p1,{'u'})
                end
                
            end
            function drawW(f)
                [X,Y] = meshgrid(0:0.05:app.k,0:0.05:1);
                w = f(end,1).*sin(pi.*app.m.*X./app.k).*sin(pi.*Y./app.k);
                p = surf(app.UIAxes2,X,Y,w);
                legend(app.UIAxes2,p,{'w',})
                
            end
            app.sync;
            [t1,f] = app.solveODE;
            
            app.TZkritEditField.Value = app.findZkrit(t1,f);
            app.CurFvalEditField.Value = f(end,1);
            app.CurTvalEditField.Value = t1(end);
            if app.drawZCheckBox.Value
                drawZ(t1,f);
            end

            if app.drawWCheckBox.Value
                drawW(f);
            end
            app.BAEditField.Value = app.krit;
        end
        
        function results = krit(app)
            zn = (app.m*app.m + app.k*app.k);
            results = zn * zn / 4 / app.k / app.k / app.m / app.m;
        end

        function sync(app)
            app.m = app.MFieldEditField.Value;
            app.MSlider.Value = app.MFieldEditField.Value;
            app.k = app.KFieldEditField.Value;
            app.KSlider.Value = app.KFieldEditField.Value;
            app.t = app.TFieldEditField.Value;
            app.TSlider.Value = app.TFieldEditField.Value;
            app.c = app.CFieldEditField.Value;
            app.CSlider.Value = app.CFieldEditField.Value;
            app.u0 = app.u0EditField.Value;
            app.du0 = app.du0EditField.Value;
        end
        
        function [t1,f] = solveODE(app)
%          ***Test functions***
%             function results = sysr(t,x)
%                 f1 = - x(2) + t * t + 6 * t + 1;
%                 f2 =  x(1) - 3* t * t + 3 * t + 1;
%                 results = [f1;f2];
%             end
%             function results = exact1(t)
%                 q = 3 .* t .* t - t - 1 + cos(t) + sin(t);
%                 qq =  t .* t + 2 - cos(t) + sin(t);
%                 results = [q qq];
%             end

            function l = lamda(t)
               l = app.B() - app.m * app.m * t;
            end
            function s = sys(t,x)
                % x(1) = u
                % x(2) = e = u`
                f1 = x(2);
                f2 = - lamda(t) * x(1) /  app.c;
                s = [f1; f2];
            end
            [t1,f] = ode45(@sys,[0 app.t],[app.u0 app.du0]);     
        end
        
        function t = findZkrit(app,t1,f)
            t = 0;
            for i = 1:size(f(:,1))
                if f(i,1) > 2
                    t = t1(i);
                    break;
                end
            end
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: KFieldEditField
        function KFieldEditFieldValueChanged(app, event)
            value = app.KFieldEditField.Value;
            if app.MKCheckBox.Value == true
                app.MFieldEditField.Value = value;
            end
            app.redraw
        end

        % Value changed function: CFieldEditField
        function CFieldEditFieldValueChanged(app, event)
            app.redraw
        end

        % Value changed function: TFieldEditField
        function TFieldEditFieldValueChanged(app, event)
            app.redraw
        end

        % Value changing function: KSlider
        function KSliderValueChanging(app, event)
            changingValue = event.Value;
            app.KFieldEditField.Value = changingValue;
            if app.MKCheckBox.Value == true
                app.MFieldEditField.Value = changingValue;
            end
            app.redraw
        end

        % Value changing function: CSlider
        function CSliderValueChanging(app, event)
            changingValue = event.Value;
            if changingValue < 0.01
                changingValue = 0.01;
            end
            app.CFieldEditField.Value = changingValue;
            app.redraw
        end

        % Value changing function: TSlider
        function TSliderValueChanging(app, event)
            changingValue = event.Value;
            if changingValue < 0.01
                changingValue = 0.01;
            end
            app.TFieldEditField.Value = changingValue;
            app.redraw
        end

        % Value changing function: MSlider
        function MSliderValueChanging(app, event)
            changingValue = event.Value;
            if changingValue < 0.01
                changingValue = 0.01;
            end
            app.MFieldEditField.Value = changingValue;
            app.redraw
        end

        % Value changed function: MFieldEditField
        function MFieldEditFieldValueChanged(app, event)
            app.redraw
        end

        % Value changed function: du0EditField
        function du0EditFieldValueChanged(app, event)
            app.redraw
        end

        % Value changed function: u0EditField
        function u0EditFieldValueChanged(app, event)
            app.redraw
        end

        % Value changed function: ShowduCheckBox
        function ShowduCheckBoxValueChanged(app, event)
            app.redraw
        end

        % Value changed function: drawWCheckBox
        function drawWCheckBoxValueChanged(app, event)
            app.redraw
        end

        % Value changed function: drawZCheckBox
        function drawZCheckBoxValueChanged(app, event)
            app.redraw
        end

        % Button pushed function: minimizeMButton
        function minimizeMButtonPushed(app, event)
            curM = app.m;
            tf = app.TZkritEditField.Value;
            for i = 0:0.1:20
                app.m = i;
                [t1,f] = app.solveODE;
                tt = app.findZkrit(t1,f);
                if tf < 2 && tt > 2
                    tf = tt;
                end
                if tt > 2 && (tt <= tf)
                    curM = i;
                    tf = tt;
                end
            end
            
            app.MFieldEditField.Value = curM;
            app.redraw;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1149 636];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Dzetta')
            xlabel(app.UIAxes, 't')
            ylabel(app.UIAxes, 'f')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [0 325 433 303];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'W')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [509 238 625 390];

            % Create TSliderLabel
            app.TSliderLabel = uilabel(app.UIFigure);
            app.TSliderLabel.HorizontalAlignment = 'right';
            app.TSliderLabel.Position = [0 195 25 22];
            app.TSliderLabel.Text = 'T';

            % Create TSlider
            app.TSlider = uislider(app.UIFigure);
            app.TSlider.Limits = [0.01 20];
            app.TSlider.ValueChangingFcn = createCallbackFcn(app, @TSliderValueChanging, true);
            app.TSlider.Position = [46 204 655 3];
            app.TSlider.Value = 1;

            % Create CSliderLabel
            app.CSliderLabel = uilabel(app.UIFigure);
            app.CSliderLabel.HorizontalAlignment = 'right';
            app.CSliderLabel.Position = [-7 146 25 22];
            app.CSliderLabel.Text = 'C';

            % Create CSlider
            app.CSlider = uislider(app.UIFigure);
            app.CSlider.Limits = [0.1 100];
            app.CSlider.ValueChangingFcn = createCallbackFcn(app, @CSliderValueChanging, true);
            app.CSlider.Position = [39 155 658 3];
            app.CSlider.Value = 0.1;

            % Create KSliderLabel
            app.KSliderLabel = uilabel(app.UIFigure);
            app.KSliderLabel.HorizontalAlignment = 'right';
            app.KSliderLabel.Position = [-7 93 25 22];
            app.KSliderLabel.Text = 'K';

            % Create KSlider
            app.KSlider = uislider(app.UIFigure);
            app.KSlider.Limits = [1 9];
            app.KSlider.ValueChangingFcn = createCallbackFcn(app, @KSliderValueChanging, true);
            app.KSlider.Position = [39 102 430 3];
            app.KSlider.Value = 2;

            % Create TFieldEditFieldLabel
            app.TFieldEditFieldLabel = uilabel(app.UIFigure);
            app.TFieldEditFieldLabel.HorizontalAlignment = 'right';
            app.TFieldEditFieldLabel.Position = [0 282 38 22];
            app.TFieldEditFieldLabel.Text = 'TField';

            % Create TFieldEditField
            app.TFieldEditField = uieditfield(app.UIFigure, 'numeric');
            app.TFieldEditField.Limits = [0.01 100];
            app.TFieldEditField.ValueChangedFcn = createCallbackFcn(app, @TFieldEditFieldValueChanged, true);
            app.TFieldEditField.Position = [53 282 77 22];
            app.TFieldEditField.Value = 0.01;

            % Create CFieldEditFieldLabel
            app.CFieldEditFieldLabel = uilabel(app.UIFigure);
            app.CFieldEditFieldLabel.HorizontalAlignment = 'right';
            app.CFieldEditFieldLabel.Position = [0 237 40 22];
            app.CFieldEditFieldLabel.Text = 'CField';

            % Create CFieldEditField
            app.CFieldEditField = uieditfield(app.UIFigure, 'numeric');
            app.CFieldEditField.Limits = [0.1 100];
            app.CFieldEditField.ValueChangedFcn = createCallbackFcn(app, @CFieldEditFieldValueChanged, true);
            app.CFieldEditField.Position = [55 237 77 22];
            app.CFieldEditField.Value = 1;

            % Create KFieldEditFieldLabel
            app.KFieldEditFieldLabel = uilabel(app.UIFigure);
            app.KFieldEditFieldLabel.HorizontalAlignment = 'right';
            app.KFieldEditFieldLabel.Position = [151 282 39 22];
            app.KFieldEditFieldLabel.Text = 'KField';

            % Create KFieldEditField
            app.KFieldEditField = uieditfield(app.UIFigure, 'numeric');
            app.KFieldEditField.Limits = [1 9];
            app.KFieldEditField.ValueChangedFcn = createCallbackFcn(app, @KFieldEditFieldValueChanged, true);
            app.KFieldEditField.Position = [205 282 77 22];
            app.KFieldEditField.Value = 1;

            % Create MSliderLabel
            app.MSliderLabel = uilabel(app.UIFigure);
            app.MSliderLabel.HorizontalAlignment = 'right';
            app.MSliderLabel.Position = [0 51 25 22];
            app.MSliderLabel.Text = 'M';

            % Create MSlider
            app.MSlider = uislider(app.UIFigure);
            app.MSlider.Limits = [0.1 20];
            app.MSlider.ValueChangingFcn = createCallbackFcn(app, @MSliderValueChanging, true);
            app.MSlider.Position = [46 60 661 3];
            app.MSlider.Value = 0.1;

            % Create MFieldEditFieldLabel
            app.MFieldEditFieldLabel = uilabel(app.UIFigure);
            app.MFieldEditFieldLabel.HorizontalAlignment = 'right';
            app.MFieldEditFieldLabel.Position = [151 237 42 22];
            app.MFieldEditFieldLabel.Text = 'MField';

            % Create MFieldEditField
            app.MFieldEditField = uieditfield(app.UIFigure, 'numeric');
            app.MFieldEditField.Limits = [0.1 20];
            app.MFieldEditField.ValueChangedFcn = createCallbackFcn(app, @MFieldEditFieldValueChanged, true);
            app.MFieldEditField.Position = [208 237 74 22];
            app.MFieldEditField.Value = 2;

            % Create BAEditField
            app.BAEditField = uieditfield(app.UIFigure, 'numeric');
            app.BAEditField.Position = [636 82 60 22];

            % Create BAEditFieldLabel
            app.BAEditFieldLabel = uilabel(app.UIFigure);
            app.BAEditFieldLabel.HorizontalAlignment = 'right';
            app.BAEditFieldLabel.Position = [596 82 25 22];
            app.BAEditFieldLabel.Text = 'B/A';

            % Create MKCheckBox
            app.MKCheckBox = uicheckbox(app.UIFigure);
            app.MKCheckBox.Text = 'M = K';
            app.MKCheckBox.Position = [509 82 54 22];

            % Create u0EditFieldLabel
            app.u0EditFieldLabel = uilabel(app.UIFigure);
            app.u0EditFieldLabel.HorizontalAlignment = 'right';
            app.u0EditFieldLabel.Position = [316 237 25 22];
            app.u0EditFieldLabel.Text = 'u0';

            % Create u0EditField
            app.u0EditField = uieditfield(app.UIFigure, 'numeric');
            app.u0EditField.Limits = [0 Inf];
            app.u0EditField.ValueChangedFcn = createCallbackFcn(app, @u0EditFieldValueChanged, true);
            app.u0EditField.Position = [356 237 80 22];
            app.u0EditField.Value = 0.01;

            % Create u0Label
            app.u0Label = uilabel(app.UIFigure);
            app.u0Label.HorizontalAlignment = 'right';
            app.u0Label.Position = [313 282 26 22];
            app.u0Label.Text = 'du0';

            % Create du0EditField
            app.du0EditField = uieditfield(app.UIFigure, 'numeric');
            app.du0EditField.Limits = [0 Inf];
            app.du0EditField.ValueChangedFcn = createCallbackFcn(app, @du0EditFieldValueChanged, true);
            app.du0EditField.Position = [354 282 79 22];

            % Create TZkritEditFieldLabel
            app.TZkritEditFieldLabel = uilabel(app.UIFigure);
            app.TZkritEditFieldLabel.HorizontalAlignment = 'right';
            app.TZkritEditFieldLabel.Position = [982 125 36 22];
            app.TZkritEditFieldLabel.Text = 'TZkrit';

            % Create TZkritEditField
            app.TZkritEditField = uieditfield(app.UIFigure, 'numeric');
            app.TZkritEditField.Position = [1033 125 100 22];

            % Create CurTvalEditFieldLabel
            app.CurTvalEditFieldLabel = uilabel(app.UIFigure);
            app.CurTvalEditFieldLabel.HorizontalAlignment = 'right';
            app.CurTvalEditFieldLabel.Position = [972 174 47 22];
            app.CurTvalEditFieldLabel.Text = 'CurTval';

            % Create CurTvalEditField
            app.CurTvalEditField = uieditfield(app.UIFigure, 'numeric');
            app.CurTvalEditField.Position = [1034 174 100 22];

            % Create CurFvalEditFieldLabel
            app.CurFvalEditFieldLabel = uilabel(app.UIFigure);
            app.CurFvalEditFieldLabel.HorizontalAlignment = 'right';
            app.CurFvalEditFieldLabel.Position = [972 218 47 22];
            app.CurFvalEditFieldLabel.Text = 'CurFval';

            % Create CurFvalEditField
            app.CurFvalEditField = uieditfield(app.UIFigure, 'numeric');
            app.CurFvalEditField.Position = [1034 218 100 22];

            % Create ShowduCheckBox
            app.ShowduCheckBox = uicheckbox(app.UIFigure);
            app.ShowduCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShowduCheckBoxValueChanged, true);
            app.ShowduCheckBox.Text = 'Show du';
            app.ShowduCheckBox.Position = [467 236 70 22];

            % Create drawZCheckBox
            app.drawZCheckBox = uicheckbox(app.UIFigure);
            app.drawZCheckBox.ValueChangedFcn = createCallbackFcn(app, @drawZCheckBoxValueChanged, true);
            app.drawZCheckBox.Text = 'draw Z';
            app.drawZCheckBox.Position = [760 105 59 22];

            % Create drawWCheckBox
            app.drawWCheckBox = uicheckbox(app.UIFigure);
            app.drawWCheckBox.ValueChangedFcn = createCallbackFcn(app, @drawWCheckBoxValueChanged, true);
            app.drawWCheckBox.Text = 'draw W';
            app.drawWCheckBox.Position = [760 82 63 22];

            % Create minimizeMButton
            app.minimizeMButton = uibutton(app.UIFigure, 'push');
            app.minimizeMButton.ButtonPushedFcn = createCallbackFcn(app, @minimizeMButtonPushed, true);
            app.minimizeMButton.Position = [740 39 100 22];
            app.minimizeMButton.Text = 'minimize M';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app1_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end