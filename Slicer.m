classdef Slicer < handle
    properties
        imfuse_method (1,1) string = "falsecolor"
        overlay_colormap (:, 3) double = Slicer.COLORS % no effect on fused pairs
    end
    
    methods
        function obj = Slicer(image, overlay, included_labels)
            if nargin < 2
                overlay = [];
            end
            
            if nargin < 3
                included_labels = "all";
            end
            
            if ~(isnumeric(included_labels) || iscategorical(included_labels))
                included_labels = string(included_labels);
                assert(isscalar(included_labels));
                assert(ismember(included_labels, ["all"]));
            end
            
            if ~isempty(overlay)
                assert(all(size(overlay) == size(image)));
            end
            
            if isempty(overlay)
                mode = Slicer.NO_OVERLAY;
            elseif iscategorical(overlay) || islogical(overlay)
                mode = Slicer.LABEL_OVERLAY;
            else
                mode = Slicer.FUSION_OVERLAY;
            end
            
            if mode == Slicer.LABEL_OVERLAY
                if isstring(included_labels)
                    all_labels = unique(overlay);
                else
                    all_labels = included_labels;
                end
            else
                all_labels = [];
            end
            
            if mode ~= Slicer.LABEL_OVERLAY
                overlay = rescale(overlay);
            end
            
            MIN_VALUE = 0.0;
            MAX_VALUE = 1.0;
            image = rescale(image, MIN_VALUE, MAX_VALUE);
            
            sz = size(image, [1 2]);
            slices = size(image, 3);
            start = round(slices / 2);
            
            fh = uifigure();
            fh.Position = [50 50 sz(1) + 80 sz(2)];
            fh.WindowScrollWheelFcn = @obj.window_scrolled_fcn;
            fh.Resize = "off";
            
            axh = axes(fh);
            ih = imagesc(image(:, :, start), "parent", axh);
            axis(axh, "off");
            axh.Units = "pixels";
            axh.InnerPosition = [0 0 sz(1) sz(2)];
            axh.XLim = [0, sz(1)];
            axh.YLim = [0, sz(2)];
            colormap(axh, gray);
            caxis(axh, [MIN_VALUE MAX_VALUE]);
            hold(axh, "on");
            
            sh = uislider(fh);
            sh.Orientation = "vertical";
            sh.Position([1 2 4]) = [sz(1) + 20, 20, sz(2) - 40];
            sh.Limits = [1 slices];
            sh.Value = start;
            sh.ValueChangedFcn = @obj.slider_changed_fcn;
            
            obj.figure_handle = fh;
            obj.axes_handle = axh;
            obj.image_handle = ih;
            obj.slider_handle = sh;
            obj.image = image;
            obj.overlay = overlay;
            obj.overlay_mode = mode;
            obj.all_labels = all_labels;
            
            obj.update();
        end
    end
    
    properties (Access = private)
        figure_handle matlab.ui.Figure
        axes_handle matlab.graphics.axis.Axes
        image_handle matlab.graphics.primitive.Image
        slider_handle matlab.ui.control.Slider
        
        image (:, :, :) double = [] % expected to be intensity image
        overlay (:, :, :) % may be intensity image for imfuse, or categorical/logical for labels
        
        overlay_mode (1,1) string = Slicer.NO_OVERLAY
        all_labels (:,1) = []
    end
    
    properties (Access = private, Constant)
        NO_OVERLAY = "none"
        LABEL_OVERLAY = "label"
        FUSION_OVERLAY = "fuse"
        COLORS = [ % Okabe/Ito from https://jfly.uni-koeln.de/color/
        % 0.00, 0.00, 0.00;  % black
        0.90, 0.60, 0.00;  % orange
        0.00, 0.45, 0.70;  % blue
        0.95, 0.90, 0.25;  % yellow
        0.80, 0.60, 0.70;  % reddish purple
        0.35, 0.70, 0.90;  % sky blue
        0.80, 0.40, 0.00;  % vermillion
        0.00, 0.60, 0.50;  % bluish green
    ]
    end
    
    methods (Access = private)
        function update(obj)
            data = obj.generate_image();
            obj.image_handle.CData = data;
        end
        
        function data = generate_image(obj)
            im = obj.image(:, :, obj.get_slice());
            switch obj.overlay_mode
                case obj.NO_OVERLAY
                    data = im;
                case obj.LABEL_OVERLAY
                    ov = obj.overlay(:, :, obj.get_slice());
                    data = labeloverlay(...
                        im, ov, ...
                        "includedlabels", obj.all_labels, ...
                        "colormap", obj.overlay_colormap ...
                        );
                case obj.FUSION_OVERLAY
                    ov = obj.overlay(:, :, obj.get_slice());
                    data = imfuse(im, ov, obj.imfuse_method, "scaling", "none");
                otherwise
                    assert(false);
            end
        end
        
        function value = get_slice(obj)
            value = obj.slider_handle.Value;
        end
        
        function slider_changed_fcn(obj, ~, ~)
            slice = round(obj.slider_handle.Value);
            slice = max(slice, obj.slider_handle.Limits(1));
            slice = min(slice, obj.slider_handle.Limits(2));
            obj.slider_handle.Value = slice;
            obj.update();
        end
        
        function window_scrolled_fcn(obj, ~, event)
            new = obj.slider_handle.Value - event.VerticalScrollCount;
            if new < obj.slider_handle.Limits(1) || obj.slider_handle.Limits(2) < new
                return;
            end
            obj.slider_handle.Value = new;
            obj.update();
        end
    end
end

