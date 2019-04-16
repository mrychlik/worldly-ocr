function plotData = plotconfusion(param,fig,plotData,tt,yy,names,columnLabels)

% Need to guard against the case this was called without the columnLabels
% argument.
ComputeLabels = (nargin == 6);

numSignals = length(names);

t = tt{1}; if iscell(t), t = cell2mat(t); end
[numClassesShown,numSamples] = size(t);
numClassesShown = max(numClassesShown,2);
numColumns = numClassesShown+1;
% Rebuild figure
if (plotData.numSignals ~= numSignals) || (plotData.numClasses ~= numClassesShown)
    plotData.numSignals = numSignals;
    plotData.numClasses = numClassesShown;
    plotData.axes = zeros(1,numSignals);
    titleStyle = {'fontweight','bold','fontsize',nnplots.title_font_size;};
    plotcols = ceil(sqrt(numSignals));
    plotrows = ceil(numSignals/plotcols);
    set(fig,'NextPlot','replace')
    for plotrow=1:plotrows
        for plotcol=1:plotcols
            i = (plotrow-1)*plotcols+plotcol;
            if (i<=numSignals)
                a = subplot(plotrows,plotcols,i);
                set(a,'YDir','reverse','TickLength',[0 0],'Box','on')
                set(a,'DataAspectRatio',[1 1 1])
                hold on
                mn = 0.5;
                mx = numColumns+0.5;
                
                % Get the axes tick labels. If they weren't provided as an
                % argument to update_plot, calculate them here; otherwise,
                % use the right labels for this signal.
                if( ComputeLabels )
                    axesTickLabels = iComputeNumericalClassLabels(t, numClassesShown);
                else
                    % Get the existing labels from the input arguments.
                    axesTickLabels = columnLabels{i};
                end
                
                % Append an extra blank label to the end, for the
                % summary column.
                axesTickLabels = iEnsureLabelsAreCorrectLength(axesTickLabels, numClassesShown);
                axesTickLabels = iAppendLabelForSummary(axesTickLabels);              
                
                set(a,'XLim',[mn mx],'XTick',1:(numColumns+1));
                set(a,'YLim',[mn mx],'YTick',1:(numColumns+1));
                set(a,'XTickLabel',axesTickLabels);
                set(a,'YTickLabel',axesTickLabels);
                       
                xtickangle(45);  
                
                axisdata.number = zeros(numColumns,numColumns);
                axisdata.percent = zeros(numColumns,numColumns);
                for j=1:numColumns
                    for k=1:numColumns
                        if (j==numColumns) && (k==numColumns)
                            % Bottom right summary
                            c = [217 217 217]/255;
                            topcolor = [34 172 60]/255;
                            bottomcolor = [226 61 45]/255;
                            topbold = 'bold';
                            bottombold = 'bold';
                        elseif (j==k)
                            % Diagonal
                            c = [188 230 196]/255;
                            topcolor = [0 0 0];
                            bottomcolor = [0 0 0];
                            topbold = 'bold';
                            bottombold = 'normal';
                        elseif (j<numColumns) && (k<numColumns)
                            % Off-diagonal
                            c = [249 196 192]/255;
                            topcolor = [0 0 0];
                            bottomcolor = [0 0 0];
                            topbold = 'bold';
                            bottombold = 'normal';
                        elseif (j<numColumns)
                            % Column summary (cells at bottom)
                            c = [240 240 240]/255;
                            topcolor = [34 172 60]/255;
                            bottomcolor = [226 61 45]/255;
                            topbold = 'normal';
                            bottombold = 'normal';
                        else
                            % Row summary (cells at right)
                            c = [240 240 240]/255;
                            topcolor = [34 172 60]/255;
                            bottomcolor = [226 61 45]/255;
                            topbold = 'normal';
                            bottombold = 'normal';
                        end
                        fill([0 1 1 0]-0.5+j,[0 0 1 1]-0.5+k,c);
                        axisdata.number(j,k) = text(j,k,'', ...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','bottom',...
                            'FontWeight',topbold,...
                            'Color',topcolor); %,...
                        %'FontSize',8);
                        axisdata.percent(j,k) = text(j,k,'', ...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','top',...
                            'FontWeight',bottombold,...
                            'Color',bottomcolor); %,...
                        %'FontSize',8);
                    end
                end
                plot([0 0]+numColumns-0.5,[mn mx],'LineWidth',2,'Color',[0 0 0]+0.25);
                plot([mn mx],[0 0]+numColumns-0.5,'LineWidth',2,'Color',[0 0 0]+0.25);
                xlabel('Target Class',titleStyle{:});
                ylabel('Output Class',titleStyle{:});
                title([names{i} ' Confusion Matrix'],titleStyle{:});
                set(a,'UserData',axisdata);
                plotData.axes(i) = a;
            end
        end
    end
    if(~strcmp(fig.WindowStyle, 'docked'))
        screenSize = get(0,'ScreenSize');
        screenSize = screenSize(3:4);
        if numSignals == 1
            windowSize = [600 600];
        else
            windowSize = 700 * [1 (plotrows/plotcols)];
        end
        pos = [(screenSize-windowSize)/2 windowSize];
        set(fig,'Position',pos);
    end
end

% Fill axes
for i=1:numSignals
    a = plotData.axes(i);
    set(fig,'CurrentAxes',a);
    axisdata = get(a,'UserData');
    y = yy{i}; if iscell(y), y = cell2mat(y); end
    t = tt{i}; if iscell(t), t = cell2mat(t); end
    known = find(~isnan(sum(t,1)));
    y = y(:,known);
    t = t(:,known);
    numSamples = size(t,2);
    [c,cm] = confusion(t,y);
    numClassesInThisSignal = length(cm);
    iValidateNumberOfClassesToPlot(numClassesInThisSignal, numClassesShown, names{i});
    for j=1:numColumns
        for k=1:numColumns
            if (j==numColumns) && (k==numColumns)
                correct = sum(diag(cm));
                perc = correct/numSamples;
                top = percent_string(perc);
                bottom = percent_string(1-perc);
            elseif (j==k)
                num = cm(j,k);
                top = num2str(num);
                perc = num/numSamples;
                bottom = percent_string(perc);
            elseif (j<numColumns) && (k<numColumns)
                num = cm(j,k);
                top = num2str(num);
                perc = num/numSamples;
                bottom = percent_string(perc);
            elseif (j<numColumns)
                correct = cm(j,j);
                total = sum(cm(j,:));
                perc = correct/total;
                top = percent_string(perc);
                bottom = percent_string(1-perc);
            else
                correct = cm(k,k);
                total = sum(cm(:,k));
                perc = correct/total;
                top = percent_string(perc);
                bottom = percent_string(1-perc);
            end
            set(axisdata.number(j,k),'String',top);
            set(axisdata.percent(j,k),'String',bottom);
        end
    end
end
end

function ps = percent_string(p)
if (p==1)
    ps = '100%';
else
    ps = [sprintf('%2.1f',p*100) '%'];
end
end

function iValidateNumberOfClassesToPlot(numClassesInThisSignal, numClassesShown, signalName)
% The axes are drawn with a number of classes set by the number of labels
% in the first signal. There are 2 problems when there's multiple signals being plotted:
% - If there are more classes in the first signal than in this signal, a
% loop over all those classes will cause an index-out-of-range error.
% - If there are fewer classes in the first signal than in this signal,
% then the extra classes in this signal will be ignored, without warning.

if( numClassesShown > numClassesInThisSignal )
   error(message('nnet:confusion:TooFewClasses'));
end

if( numClassesShown < numClassesInThisSignal )
   warning(message('nnet:confusion:TooManyClasses'));
end

end

function [trueArray, predArray, classLabels] = iConvertToOneHot(trueLabels, predLabels)
% This returns a one-hot array, when given an input of a suitable type. To
% ensure we have consistent error handling with the existing code, we take
% the following approach: 
% - Pass anything that isn't a categorical straight
% back out with no validation, and rely on existing error handling. 
% - If it's a categorical, do error checking ourselves.

if( iscategorical(trueLabels) || iscategorical(predLabels) )
    % Convert categoricals to one-hot, and handle any errors.
    try
        [trueArray, predArray, classLabels] = iConvertCategoricalInputToOneHot(trueLabels, predLabels);
    catch err
        throwAsCaller(err);
    end
else
    % Pass anything else straight through.
    trueArray = trueLabels;
    predArray = predLabels;
    
    % Return the labels as a cellstr.
    numClasses = size(trueLabels, 1);
    classLabels = iComputeNumericalClassLabels(trueLabels, numClasses);
end

end

function [trueArray, predArray, classLabels] = iConvertCategoricalInputToOneHot(trueLabels, predLabels)
% Given at least one categorical input, validates input then converts to
% one-hot form.

% Throw errors if input is invalid for conversion to one-of-N.
iValidateCategoricalLabels(trueLabels, predLabels);

[trueLabels, predLabels] = iRemoveMissingData(trueLabels(:), predLabels(:));

% We need to know the total number of categories, as there may be some in
% trueLabels not in predLabels and vice versa. We have already validated
% that this concatenation is valid (e.g. the categoricals are not ordinals
% with different underlying categories).
combinedCategorical = [trueLabels(:); predLabels(:)];
classLabels = categories(combinedCategorical);
numTrueLabels = length(trueLabels);

% Convert the combined array to one-of-N.
combinedOneOfN = nnet.internal.data.convertCategoricalToOneOfN(combinedCategorical);

% Now, split the combined one-of-N array back into the 2 separate true and
% predicted arrays.
trueArray = combinedOneOfN(:, 1:numTrueLabels);
predArray = combinedOneOfN(:, numTrueLabels+1:end);

end

function iValidateCategoricalLabels(trueLabels, predLabels)
% Check that the provided categoricals are suitable for conversion to
% one-hot form.

% Check we don't have only one categorical input.
if( ~iscategorical(trueLabels) || ~iscategorical(predLabels) )
    error(message('nnet:confusion:MixingCategoricalInput'));
end

Attributes = {'nonempty', 'vector'};
validateattributes(trueLabels, {'categorical'}, Attributes, 'plotconfusion', 'targets');
validateattributes(predLabels, {'categorical'}, Attributes, 'plotconfusion', 'outputs');

% Make sure trueLabels and predLabels are the same size.
if( any(size(trueLabels) ~= size(predLabels)) )
    error(message('nnet:confusion:MismatchedCategoricalSize',...
        size(trueLabels, 1), size(trueLabels, 2),...
        size(predLabels, 1), size(predLabels, 2)));
end

% Make sure trueLabels and predLabels have the same type of ordinality,
% otherwise attempting to concatenate them will fail.
if( isordinal(trueLabels) ~=  isordinal(predLabels))
    error(message('nnet:confusion:MismatchedCategoricalOrdinality'));
end

% Make sure that, if both labels are ordinal, they have the same ordered
% categories, otherwise attempting to concatenate them will fail.
if( isordinal(trueLabels) && isordinal(predLabels))
    iValidateBothOrdinalCategoricalsHaveSameCategories(trueLabels, predLabels);
end

end

function [trueLabels, predLabels] = iRemoveMissingData(trueLabels, predLabels)
% If either of the categoricals has missing data, strip that observation
% out of both true and predicted labels.

% Find indices of <undefined> data, as a logical array. If the same
% observation is missing in both arrays, make sure that's only logical 1,
% not 2.
isMissingInEitherLabels = min(1, ismissing(trueLabels) + ismissing(predLabels));

trueLabels = trueLabels(~isMissingInEitherLabels);
predLabels = predLabels(~isMissingInEitherLabels);

end

function iValidateBothOrdinalCategoricalsHaveSameCategories(trueLabels, predLabels)
% If both input labels are ordinal categoricals, they have to have the same
% categories (including order). Otherwise, when they're concatenated to
% convert to one-of-N form, an error will be thrown. We instead want to
% throw our own, more helpful error here.

if( ~isequal(categories(trueLabels), categories(predLabels)) )
   error(message('nnet:confusion:OrdinalCategoriesDiffer'));
end

end

function labels = iComputeNumericalClassLabels(t, numClasses)

numClasses = max(numClasses, 2);

labels = cell(1,numClasses);
if size(t,1) == 1
    base = 0;
else
    base = 1;
end

for j=1:numClasses, labels{j} = num2str(base+j-1); end

% Return a row vector, so we're consistent with the shape of the labels for
% categorical arrays.
labels = labels';

end

function axesTickLabels = iEnsureLabelsAreCorrectLength(labels, numClassesToUse)
% There may be more labels than there are classes. This is because, if
% there are multiple plots, they'll all show a number of classes equal to the
% number of classes in the first plot. This may mean the class labels
% have to be truncated; only keep as many class labels as there are classes
% in the first dataset.

numClassesToUse = min(numClassesToUse, length(labels));

axesTickLabels = labels(1:numClassesToUse);

end

function axesTickLabels = iAppendLabelForSummary(labels)
% Append an empty string, used to label the summaries.

axesTickLabels = labels;
axesTickLabels{end+1} = '';

end