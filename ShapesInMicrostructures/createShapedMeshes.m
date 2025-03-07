function createShapedMeshes
% Define the initial data
D0.c = [1,1,1];
D0.theta = [0,60,120];
D0.divUnit = 25;
D0.filename = 'DiamondTest.m';
MC = MeshCreator(D0);
MC.computeMeshNodes();
MC.drawMesh();
MC.plotIndicesOfNodes();
end