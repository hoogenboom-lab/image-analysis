% This script requires 4 files: A list of all coordinates of MACs 
% relative to the reference image, the coordinates of the ends of a 
% straight line deliniating the centre of the cell in the reference image
% and a binary image showing the area of the cell. The final file has the 
% width of the image in nm at the begining of the filename. 
MainFolder = '';
FilePattern = strcat(MainFolder, '*centrecoords.txt');
AllFiles = dir(FilePattern);

% Set region sizes
edges = 0:0.2:1;
middles = edges(2:end) - 0.2/2;

allcounts = [];


for k = 1 : length(AllFiles)
    
    % Get equation for midline
    CentresCart = readmatrix(strcat(MainFolder, AllFiles(k).name));
    c = polyfit(CentresCart(:,2), CentresCart(:,3),1);
    % Get angle of midline
    Centretheta = atan(c(1));
    
    % Get filename with size in nm
    Parts = split(AllFiles(k).name, '_centrecoords');
    SampleName = Parts{1};
    SizeFiles = dir(strcat(AllFiles(k).folder, '\*_', SampleName, '_Area_only.tif'));

    %Get area outline 
    AreaOutlineFile = strcat(MainFolder, strrep(AllFiles(k).name, '_centrecoords.txt', '_Area_outline.tiiff.tif'));
    AreaOutlinergb = imread(AreaOutlineFile);
    if size(AreaOutlinergb,3)==3
        AreaOutlineBW = imbinarize(rgb2gray(AreaOutlinergb));
    else 
        AreaOutlineBW = imbinarize(AreaOutlinergb);
    end
    ImageSize = size(AreaOutlineBW);

    % Change ImageSize scale to nm
    SizeFile = strcat(AllFiles(k).folder, '\', SizeFiles(1).name);
    Parts2 = split(SizeFiles(1).name, '.');
    widthnm = str2double(Parts2{1});
    Parts3 = size(rgb2gray(imread(SizeFile)));
    widthpixels = Parts3(2);
    nmPerPixel = widthnm/widthpixels;

    % Convert area image to 1nm/pixel
    areanm = imresize(AreaOutlineBW, nmPerPixel);
    % Get coordinates of all pixels in area outline 
    [acarty, acartx] = find(areanm);

    % Move coordinates down to get midline to intersect 0
    acarty2 = acarty - c(2);
    % Rotate coordinates so midline is y = 0 
    [atheta,arho] = cart2pol(acartx,acarty2);
    atheta = atheta - Centretheta;
    [ax, ay] = pol2cart(atheta,arho);
    % Make all y distances absolute and normalise with maximum
    % This means that all distances are now proportion from midline to pole
    aynorm = (abs(ay))/max(abs(ay));
    % abinned is the number of nm squares in each segment
    % i.e. the area of each segment in nm^2
    [abinned,aed] = histcounts(aynorm,edges); 
    
    % Get coordinates 
    MACName = strrep(AllFiles(k).name, 'centrecoords', 'MAC_coords');
    MACCoordsCart = readmatrix(strcat(MainFolder, MACName));

    % Plot coordinates with midline
    plot(CentresCart(:,2), CentresCart(:,3));
    hold on
    scatter(MACCoordsCart(:,2), MACCoordsCart(:,3));

    % Move coordinates down to get midline to intersect 0
    MACcoordsy = MACCoordsCart(:,3) - c(2);
    % Rotate coordinates so midline is y = 0
    [theta,rho] = cart2pol(MACCoordsCart(:,2),MACcoordsy);
    theta = theta - Centretheta;
    [MACx, MACy] = pol2cart(theta,rho);

    % Plot
    scatter(MACx,MACy)
    hold off
    
    % Make all y distances absolute and normalise with maximum of area
    % This means that all distances are now proportion from midline to pole
    MACyabs = abs(MACy);
    MACynorm = MACyabs/max(abs(ay));
    % binned is the number of MACs in each segment
    [binned,ed] = histcounts(MACynorm,edges);
    % Normalise the counts to the area size 
    normcount = [];
    for n = 1 : length(binned)
        %normcount = [normcount;(binned(n)/(abinned(n)/1000000))];
        normcount = [normcount;(binned(n)/abinned(n))];
    end
    allcounts = [allcounts,normcount];

end



Meanbins = [];
SDbins = [];
for k = 1 : size(allcounts,1)
    Means = mean(allcounts(k,:));
    Meanbins = [Meanbins;Means];
    sds = std(allcounts(k,:));
    SDbins = [SDbins;sds];
end

MeansSDs = [middles.',Meanbins,SDbins];
%writematrix(MeansSDs, '');

allcounts = [middles.',allcounts];
%writematrix(allcounts, '');

