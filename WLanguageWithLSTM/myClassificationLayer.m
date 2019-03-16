classdef myClassificationLayer < nnet.layer.ClassificationLayer
% A layer to test what is passed on from previous layers
% Implements zero loss function.
        
    properties
        % (Optional) Layer properties.

        % Layer properties go here.
    end
 
    methods
        function layer = myClassificationLayer()           
            % (Optional) Create a myClassificationLayer.

            % Layer constructor function goes here.
                layer.Name = 'Dummy Classification Layer'
        end

        function loss = forwardLoss(layer, Y, T)
            % Return the loss between the predictions Y and the 
            % training targets T.
            %
            % Inputs:
            %         layer - Output layer
            %         Y     – Predictions made by network
            %         T     – Training targets
            %
            % Output:
            %         loss  - Loss between Y and T

            % Layer forward loss function goes here.
                display(Y);
                pause(5);
                loss = single(0);
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
    end
end