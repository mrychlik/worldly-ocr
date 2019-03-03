function [cluster_idx, num_clusters, cluster_reps] = fourier_clustering(objects, varargin)
%Cluster graphical objects by Fourier method (motion compensation).
%   [CLUSTER_IDX, NUM_CLUSTERS, CLUSTER_REPS] = FOURIER_CLUSTERING(OBJECTS)
% accepts an array of structures OBJECTS, which contains fields 'BWIMAGE'
% and 'GRAYSCALEIMAGE', which should be a binary and an intensity image. The
% images are cropped and centered in a box of uniform size. Then it is
% determined whether the objects are obtained by translation from each
% other, subject to noise.
%
% Objects are divided into approximate equivalence classes (clusters).
% The output value NUM_CLUSTERS is the number of clusters, and CLUSTER_IDX
% is a vector of integers 1:LENGTH(OBJECTS) which contains the assignment
% of objects to clusters (i.e. a number in the range 1:NUM_CLUSTERS.
% Additionally, CLUSTER_REPS lists indices of selected representatives
% for each class (a vector of length 1:NUM_CLUSTERS). Additionally, the
% following optional arguments are recognized:
%
%    Display       - display clusters ('on' or 'off'; default 'on')
%    Threshold     - threshold for the dissimilarity (a number in the
%                    range from 0 to 1; default: 0.75)
%

% Parse optional arguments
p = inputParser;

validObjects = @(x) isstruct(x) && isfield(x,'bwimage') && isfield(x, 'grayscaleimage');
addRequired(p,'objects',validObjects);

defaultDisplay = 'on'; 
validDisplay = @(x) strcmp(x,'on') || strcmp(x, 'off');
addParameter(p, 'Display', defaultDisplay, validDisplay);

defaultThreshold = .75;
validThreshold = @(x) isnumeric(x) && isscalar(x) && (x > 0);
addParameter(p, 'Threshold', defaultThreshold, validThreshold);

parse(p, objects, varargin{:});

threshold = p.Results.Threshold;
visualize = p.Results.Display;

% Find equivalent objects
n = length(objects);
Q = zeros(n,n);


classified = zeros(1,n);
cluster_reps = zeros(1,n);
for j = 1:(n-1)
    if classified(j)
        continue;
    end;
    classified(j)=1;
    cluster_reps(j)=1;
    fprintf('New object: %d, Number of classes: %d\n', j, length(find(cluster_reps)));
    for k = (j+1):n
        D = dissimilarity(objects(j), objects(k));
        if classified(k)
            continue;
        end
        if D > threshold
            Q(j,k)=1;
            classified(k) = 1;
        end
    end
end

if strcmp(visualize,'on')
    imagesc(Q),drawnow;
end
% Visualize classes

cluster_idx = zeros(1,n);
num_clusters = 0;
for j = 1:n
    if cluster_reps(j)
        idx = [j,find(Q(j,:))];
        num_clusters = num_clusters + 1;
        class_idx(idx) = num_clusters;
        if strcmp(visualize,'on')
            s = length(idx);
            t = ceil(sqrt(s));
            for k=1:s
                subplot(t,t,k), imagesc(objects(idx(k)).grayscaleimage);
            end
            drawnow, pause(1);
            clf;
        end
    end
end
cluster_reps=find(cluster_reps);