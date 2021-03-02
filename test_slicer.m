function test_slicer()

load mri D
D = squeeze(D);
D = imresize(D, 4);
L = zeros(size(D));
L(80 <= D) = 1;
L(50 <= D & D < 80) = 2;
L(20 <= D & D < 50) = 3;
L = categorical(L, "ordinal", true);
included = unique(L);
included = included(2 : end);
sh = Slicer(D, L, included);

end

