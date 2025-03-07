classdef ConvergenceVarsDispatcher < handle
    
    methods (Access = public, Static)
        
        function names = dispatchNames(cParams)
            switch cParams.type
                case {'AlternatingPrimalDual','DualNestedInPrimal'}
                    names = {'\Deltacost';'Norm L2';'Line Search';'Line Search trials'};
                    switch cParams.primal
                        case 'SLERP'
                            names{end+1} = '\theta';
                        otherwise
                    end
                case 'MMA'
                    names = {'kktnorm';'outit'};
                case 'IPOPT'
                    names = {'inf_{pr}','inf_{du}','Norm L2'};
                case 'fmincon'
                    switch cParams.alg
                        case 'sqp'
                            names = {'Norm L2','First order optimal condition','Step length'};
                        case 'interior-point'
                            names = {'Norm L2','First order optimal condition','Trust region radius'};
                        otherwise
                    end
                otherwise
                    error('Invalid optimizer name');
            end
        end
        
    end
end