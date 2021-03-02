# MATLAB Slicer
Image stack slice viewer/scroller utility.

This little application is meant for quick-and-dirty exploration of stacks of 2D images, or 3D images with a dominant axis. To use, simply run `slicer(V, L, included_labels)` to view volume `V` with labels `L` and labels of interest `included_labels`. Run and examine `test_slicer` to see an example.

The first argument is required, the second is optional and should be either a grayscale image (`imfuse` is used internally in this case) or an image of type `categorical`. The third argument is only used if the second is of type `categorical` and requires a list of `categorical` labels to display. Other labels are set to fully transparent.

The default categorical colormap is adapted from https://jfly.uni-koeln.de/color/, for accessibility. Use the return value from `Slicer()` and set `overlay_colormap` to use a different colormap. I recommend using discretized maps from: http://www.fabiocrameri.ch/colourmaps.php, which are also available in MATLAB at https://github.com/wwarriner/matlab_colormaps.

Set `imfuse_method` to change the method used by `imfuse` when the second argument is a grayscale image.
