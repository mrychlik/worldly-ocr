classdef CTCLayer < nnet.layer.ClassificationLayer
    
    properties
        % (Optional) Layer properties.
        % Layer properties go here.
        Alphabet='XO-';                 % Extended alphabet; the last character is blank
    end
    
    properties(Dependent)
        AlphabetLength;                 % Number of symbols in the alphabet
    end
    
    methods
        function layer = CTCLayer()
        % (Optional) Create a CTCLayer.
            layer.Name = 'CTCLayer';
        end

        function loss = forwardLoss(layer, Y, T)
        % Return the loss between the predictions Y and the 
        % training targets T.
        %
        % For CTC layer, the loss is the log-likelihood
        % of all training targets, which are label sequences.
        % 
        % Due to the pecularity of MATLAB Deep Learning Toolkit,
        % We receive targets as vectors of dimension equal to the
        % size of the extended alphabet. The columns are vectors
        % of the standard basis, with the last vector [0 0 0 ... 1]
        % expressing the blank. Blanks in the target are used for
        % padding, so that the targets can be expressed as a matrix.
        % Thus, in CTC calculations, the padding is dropped.
        %
        % Inputs:
        %         layer - Output layer
        %         Y     – Predictions made by network
        %         T     – Training targets
        %
        % Output:
        %         loss  - Loss between Y and T

        % Layer forward loss function goes here.
            loss = 0;
            % For sequence to sequence mapping, Y and T is a 3-D array
            % with K-by-N-by-D dimensions, where K is the number
            % of classes, N is the minibatch size and D is the number
            % of time steps
            [K, N, D] = size(Y);

            for n = 1 : N
                for t = 1:D
                    label = layer.Alphabet(T(:,n,t));
                    
                    lPrime = layer.paddWithBlanks(l)
                    alpha(1,1) = Y(1, layer.BlankIndex);
                    alpha(1,2) = Y(1, lPrime(1));
                    for s = 2 : length(lPrime)
                        alpha(1,s) = 0;
                    end
                    for t = 2 : numTimeSteps
                        for s = 1 : length(lPrime)
                            temp = alpha(t-1,s) + alpha(t-1,s-1);
                            if lPrime(s) == layer.BlankIndex || ...
                                          s == 2 || ...
                                          lPrime(s) == lPrime(s-2)
                                alpha(t,s) = Y(t, lPrime(s)) * temp;
                            else
                                alpha(t,s) = Y(t, lPrime(s)) * (temp + alpha(t-1, s-2));
                            end
                        end
                    end
                    p = alpha(numTimeSteps, length(lprime)) + ...
                        alpha(numTimeSteps, length(lprime) - 1);

                    loss = loss - log2(p);
                end
            end
        end

        function dLdY = backwardLoss(layer, Y, T)
        % Backward propagate the derivative of the loss function.
        %
        % Inputs:
        %         layer - Output layer
        %         Y     – Predictions made by network
        %         T     – Training targets
        %
        % Output:
        %         dLdY  - Derivative of the loss with respect to the predictions Y

        % Layer backward loss function goes here.
            dLdY = zeros(size(Y),'single');
        end

        function layer = set.AlphabetLength(layer)
            layer.AlphabetLength = length(layer.Alphabet);
        end

        function AlphabetLength = get.AlphabetLength(layer)
            AlphabetLength = length(layer.Alphabet);
        end

        function BlankIndex = get.BlankIndex(layer)
            BlankIndex = layer.AlphabetLength + 1;
        end

        function idx = toIndex(layer, l)
            idx = zeros(size(l));
            for j=1:length(idx);
                idx(j) = find(l(j)==layer.Alphabet, 1);
            end
        end
    end

    methods(Static)
        function lPrime = paddWithBlanks(l)
            lPrime = zeros(1,2*length(l)+1);
            lPrime(2:2:2*length(l)) = l;
        end
    end
end