function MicroExampleRun

%Microstructure
filename = 'test2d_micro';
%filename = 'IrrHexagon50x25x50';
s = createParameters(filename);
density = createDensity(s.mesh);

mI = createMaterialInterpolation(s.mesh,density);
mat = createMaterial(s.mesh,mI);

fem = FEM.create(s);
fem.setC(mat.C);
fem.computeChomog();
%fem.print(filename);

printInGiD(fem,s.mesh,filename,density)


% %MacroExample
% filename = 'test2d_triangle';
% s = createParameters(filename);
% fem = FEM.create(s);
% fem.solve();
% fem.print(filename);
end

function printInGiD(fem,mesh,filename,density)
quad = Quadrature.set(mesh.type);
quad.computeQuadrature('LINEAR');
dI = createPostProcessDataBase(mesh,filename);
dI.ndim   = 2;
dI.pdim   = '2D';
dI.ptype  = 'ELASTIC';
dI.name = '';
dI.printers = {'HomogenizedTensor','DensityGauss'};
p = Postprocess('NumericalHomogenizer',dI);
dP.fields{1} = fem.variables2print;
dP.fields{2} = density;
dP.quad   = quad;
iter = 0;
p.print(iter,dP);
end

function dE = createDensity(mesh)
s.type = 'Density';
s.mesh = mesh;
s.value = [];
s.initialCase = 'circleInclusion';
s.creatorSettings.type = 'FromLevelSet';
s.creatorSettings.fracRadius = 0.5;
d = Density(s);

s.mesh = mesh;
s.field = d.value;
p = NodalFieldPlotter(s);
p.plot()


sF.connec = mesh.connec;
sF.type   = mesh.type;
sF.fNodes = d.value;
d = FeFunction(sF);
dE = d.computeValueInCenterElement();
end

function mat = createMaterial(mesh,mI)
s.ptype = 'ELASTIC';
s.pdim  = '2D';
s.nelem = mesh.nelem;
s.mesh  = mesh;
s.kappa = mI.kappa;
s.mu    = mI.mu;
mat = Material.create(s);
mat.compute(s);
end


function mI = createMaterialInterpolation(mesh,dE)
sD.ngaus = 1;
sD.mesh  = mesh;
sD.pdim  = '2D';
d = DimensionVariables(sD);
d.compute();
s.dim = '2D';
s.typeOfMaterial = 'ISOTROPIC';
s.interpolation  = 'SIMPALL';
s.constitutiveProperties.rho_plus = 1;
s.constitutiveProperties.rho_minus = 1e-3;
s.constitutiveProperties.E_plus = 1;
s.constitutiveProperties.E_minus = 1e-3;
s.constitutiveProperties.nu_minus = 1/3;
s.constitutiveProperties.nu_plus = 1/3;
s.nElem = mesh.nelem;
m = MaterialInterpolation.create(s);
mI = m.computeMatProp(dE);
end


% %% Thermal
% filename = 'test_thermal';
% s = createFEMparameters(filename);
% fem = FEM.create(s);
% fem.solve();
% fem.print(filename)

%% Functions
function s = createParameters(file)
gidParams = createGiDparameters(file);
s.dim       = gidParams.pdim;
s.type      = gidParams.ptype;
s.scale     = gidParams.scale;
s.mesh      = gidParams.mesh;
s.dirichlet = gidParams.dirichlet;
s.pointload = gidParams.pointload;
end

function gidParams = createGiDparameters(file)
gidReader = FemInputReader_GiD();
gidParams = gidReader.read(file);
end

function postProcess(fileName)
dI = obj.createPostProcessDataBase(fileName);
postprocess = Postprocess('ScalarNodal',dI);
q = obj.element.quadrature;
d.fields = obj.variables;
d.quad = q;
postprocess.print(obj.iter,d);
end

function d = createPostProcessDataBase(mesh,fileName)
dI.mesh    = mesh;
dI.outFileName = fileName;
ps = PostProcessDataBaseCreator(dI);
d = ps.create();
end
