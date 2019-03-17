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
        % Due to the pecularity of MATLAB Deep Learning Toolkit, We receive
        % targets as vectors of dimension equal to the size of the extended
        % alphabet. The columns are vectors of the standard basis (one-hot
        % encoding), with the last vector [0 0 0 ... 1] expressing the
        % blank. Blanks in the target are used for padding, so that the
        % targets can be expressed as a matrix.  Thus, in CTC calculations,
        % this padding should be dropped.
        % 
        % For sequence-to-sequence mapping, the documentation says that T is
        % 3-D array of size K-by-N-by-S, where K is the number of classes, N
        % is the mini-batch size, and S is the sequence length.
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
            assert(all(size(Y) == size(T)));

            [K, N, S] = size(T);

            for n = 1 : N
                [label, blank] = CTCLayer.target2label(squeeze(T(:,n,:)))
                for t = 1:S
                    lPrime = layer.paddWith(l, blank)
                    alpha(1,1) = Y(1, blank);
                    alpha(1,2) = Y(1, lPrime(1));
                    for s = 2 : length(lPrime)
                        alpha(1,s) = 0;
                    end
                    for t = 2 : numTimeSteps
                        for s = 1 : length(lPrime)
                            temp = alpha(t-1,s) + alpha(t-1,s-1);
                            if lPrime(s) == blank || ...
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


        function idx = toIndex(layer, l)
            idx = zeros(size(l));
            for j=1:length(idx);
                idx(j) = find(l(j)==layer.Alphabet, 1);
            end
        end
    end


    methods(Static)
        function [label, blank] = target2label(T)
            [label, blank] = vec2ind(T);
            label = label(label~=blank);
        end

        function lPrime = paddWith(l, blank)
            lPrime = zeros(1,2*length(l)+1);
            lPrime(:)=blank;
            lPrime(2:2:2*length(l)) = l;
        end
    end
end