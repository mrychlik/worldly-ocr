classdef CTCLayer < nnet.layer.ClassificationLayer
    
    properties
        % (Optional) Layer properties.
        % Layer properties go here.
    end
    
    properties(Dependent)

    end
    
    methods
        function layer = CTCLayer()
        % (Optional) Create a CTCLayer.
            layer.Name = 'CTCLayer';
        end

        function loss = forwardLoss(~, Y, T)
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

            [~, N, S] = size(T);

            for n = 1 : N
                T1 = squeeze(T(:,n,:));
                Y1 = squeeze(Y(:,n,:));
                alpha = CTCLayer.update_alpha(Y1, T1);

                [label, ~, blank] = CTCLayer.target2label(T1);
                lPrime = CTCLayer.paddWith(label, blank);
                p = alpha(S, length(lPrime)); 
                if length(lPrime) > 1
                    p = p + alpha(S, length(lPrime) - 1);
                end
                p = p + eps;
        
                loss = loss - log(p);
            end

            loss = loss ./ N;
        end

        function dLdY = backwardLoss(~, Y, T)
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
            assert(all(size(Y) == size(T)));

            [~, N, S] = size(T);
            
            dLdY = zeros(size(Y),'single');

            for n = 1 : N
                T1 = squeeze(T(:,n,:));
                Y1 = squeeze(Y(:,n,:));

                alpha = CTCLayer.update_alpha(Y1, T1);
                beta = CTCLayer.update_beta(Y1, T1);
                
                [label, period, blank, ~] = CTCLayer.target2label(T1);
                lPrime = CTCLayer.paddWith(label, blank);
                p = alpha(S, length(lPrime)); 
                if length(lPrime) > 1
                    p = p + alpha(S, length(lPrime) - 1);
                end
                p = p + eps;

                dp = zeros(size(Y),'single');
                for t = 1:S
                    for k=1:period
                        for s=1:length(lPrime)
                            if lPrime(s) == k
                                dp(k,t) = dp(k,t) + alpha(t,s) .* ...
                                          beta(t, s)./Y(k, n, t).^2;
                            end
                        end
                    end
                end
                % Since loss = loss - p*log(p) - (1-p).*log(1-p);
                % the derivative is d loss / dp = -log(p) -1 + log(1-p) +
                % 1 = log(1-p)/p)

                dLdY = dLdY - dp ./ p;
            end
            dLdY = dLdY ./ N;
        end
    end

    methods(Access=private,Static)
        function alpha = update_alpha(Y, T)
            [~, S] = size(T);

            [label, period, blank, len] = CTCLayer.target2label(T);
            lPrime = CTCLayer.paddWith(label, blank);
            
            alpha = zeros([S,length(lPrime)],'single');

            alpha(1,1) = Y(blank, 1);
            alpha(1,2) = Y(lPrime(1), 1);

            for s = 2 : length(lPrime)
                alpha(1,s) = 0;
            end
            
            for t = 2 : S
                for s = 1 : length(lPrime)
                    if s == 1 
                        tmp = alpha(t-1,s);
                        alpha(t,s) = Y(lPrime(s), t) * tmp;
                    elseif lPrime(s) == blank || s == 2 || lPrime(s) == lPrime(s-2)
                        tmp = alpha(t-1, s) + alpha(t-1,s-1);
                        alpha(t,s) = Y(lPrime(s), t) * tmp;
                    elseif lPrime(s) == period && lPrime(s-2) == period
                        alpha(t, s) = Y(lPrime(s), t) * alpha(t, s-2);
                    else
                        tmp = alpha(t-1, s) + (alpha(t-1,s) + alpha(t-1,s-1) + alpha(t-1, s-2));
                        alpha(t,s) = Y(lPrime(s), t) * tmp;
                    end
                end
            end
        end

        function beta = update_beta(Y, T)
            [~, S] = size(T);

            [label, period, blank, len] = CTCLayer.target2label(T);
            lPrime = CTCLayer.paddWith(label, blank);

            beta = zeros([S,length(lPrime)],'single');

            beta(S,length(lPrime)) = Y(blank, S);
            if ~isempty(label)
                beta(S,length(lPrime)-1) = Y(label(end), S);
            end

            for s=1:(length(lPrime)-2)
                beta(S,s) = 0;
            end
            
            for t = (S-1):-1:1
                for s = 1 : length(lPrime)
                    if s == length(lPrime)
                        tmp = beta(t+1,s);
                        beta(t,s) = Y(lPrime(s), t) * tmp;
                    elseif lPrime(s) == blank || s == length(lPrime)-1 || lPrime(s) == lPrime(s+2)
                        tmp = beta(t+1, s) + beta(t+1,s+1);
                        beta(t,s) = Y(lPrime(s), t) * tmp;
                    elseif lPrime(s) == period && lPrime(s+2) == period
                        beta(t,s) = Y(lPrime(s), t) * beta(t,s+2);
                    else
                        tmp = beta(t+1, s) + (beta(t+1,s) + beta(t+1,s+1) + beta(t+1, s+2));
                        beta(t,s) = Y(lPrime(s), t) * tmp;
                    end
                end
            end
        end
        
    end


    methods(Static)
        function [label, blank] = target2label(T)
        %Translate targets to label indices (with respect to the alphabet)
        % [LABEL, BLANK, LEN] = TARGET2LABEL(T) returns the label
        % matrix with the same number of columns as T and each column
        % (which is a one-hot encoded symbol) to the symbol index.
        % Additionally BLANK is the highest index, corresponding to
        % Grave's blank.
            [label, n] = vec2ind(T);
            blank = n;
            assert(all(label ~= blank));
            r = find(label==blank,1);
            len = r - 1;
            assert(all(label(r:end) == blank));
        end

        function lPrime = paddWith(l, blank)
            lPrime = zeros(1,2*length(l)+1);
            lPrime(:) = blank;
            lPrime(2:2:2*length(l)) = l;
        end
    end
end