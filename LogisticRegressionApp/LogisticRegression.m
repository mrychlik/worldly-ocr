classdef LogisticRegression
    
    properties
        X                               % Training data
        T                               % Target data
        num_epochs=1000                 % Number of epochs
    end
    
    
    methods
        function this = LogisticRegression(app)
            this.app = app;
        end

        function train(this, app)
            [Y,NErrors,W] = train_patternnet(this,num_epochs);
        end
    end
end