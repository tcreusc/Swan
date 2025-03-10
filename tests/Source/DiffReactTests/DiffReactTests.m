classdef DiffReactTests < matlab.unittest.TestCase

    properties (TestParameter)
%         file = {'testDiffReactHexagon', 'testDiffReactTorus', 'testDiffReactCube'}
        file = {'testDiffReactHexagon'}
        file3d = {'testDiffReactTorus', 'testDiffReactCube'}
        LHStype = {'DiffReactNeumann', 'DiffReactRobin'}
    end

    methods (Test, TestTags = {'DiffReact', '2D'})

        function testHexagon(testCase, file, LHStype)
            s   = testCase.createFEMparameters(file, LHStype);
            field = testCase.createField(s.mesh);
            RHS = testCase.createRHS(s.mesh, field);
            fem = FEM.create(s);
            fem.computeLHS(0.1857);
            fem.computeVariables(RHS);
%             fem.print(filename)
            err = testCase.computeError(file, LHStype, fem);
            tol = 1e-6;
            testCase.verifyLessThanOrEqual(err, tol)
        end

    end

    methods (Test, TestTags = {'DiffReact', '3D'})

        function test3D(testCase, file3d)
            lhstype = 'DiffReactNeumann';
            s   = testCase.createFEMparameters(file3d, lhstype);
            field = testCase.createField(s.mesh);
            RHS = testCase.createRHS(s.mesh, field);
            fem = FEM.create(s);
            fem.computeLHS(0.1857);
            fem.computeVariables(RHS);
%             fem.print(filename)
            err = testCase.computeError(file3d, lhstype, fem);
            tol = 1e-6;
            testCase.verifyLessThanOrEqual(err, tol)
        end

    end

    methods (Access = private)

        function error = computeError(testCase, file, LHStype, fem)
            file2load = append(file, '_', LHStype);
            cV = fem.variables.x;
            sV = load(file2load).x;
            error = norm(sV - cV)/norm(sV);
        end

        function name = loadFile(testCase, file, LHStype)
            name = append(file, '_', LHStype);
        end

        function s = createFEMparameters(testCase, file, LHStype)
            gidParams = testCase.createGiDparameters(file);
            s.dim       = gidParams.pdim;
            s.type      = gidParams.ptype;
            s.scale     = gidParams.scale;
            s.mesh      = gidParams.mesh;
            s.LHStype   = LHStype;
        end
        
        function gidParams = createGiDparameters(testCase, file)
            gidReader = FemInputReader_GiD();
            gidParams = gidReader.read(file);
        end
        
        function field = createField(testCase, msh)
            s.mesh               = msh;
            s.ndimf              = 1;
            s.interpolationOrder = 'LINEAR';
            s.quadratureOrder    = 'QUADRATICMASS';
            s.scale              = 'MACRO';
            field = Field(s);
        end
        
        function rhs = createRHS(testCase, mesh, dim)
            M = testCase.computeM(mesh, dim);
            u = testCase.createDisplacement(M);
            rhs = M*u;
        end
        
        function M = computeM(testCase, mesh, field)
            s.type  = 'MassMatrix';
            s.mesh  = mesh;
            s.field = field;
            LHS = LHSintegrator.create(s);
            M = LHS.compute();
        end
        
        function u = createDisplacement(testCase, M)
            sizeM = size(M,1);
            sizeI = floor(sizeM/2);
            sizeJ = sizeM - sizeI;
            u = [ones(sizeI, 1); zeros(sizeJ, 1)];
        end

    end

end