Mesh.Algorithm=8;              //delquad mesher
Mesh.RecombinationAlgorithm=1; //blossom

r1 = 0.1; // radius of inner cylinder
r2 = 0.2; // radius of outer cylinder
h  = 0.1; // height of cylinder

n1     = 4; // points along radial
n2     = 4; // points along axial

p      = 1;// progression

// First cell height
dh = 0.5*(r2-r1)*p/((1+p)^(n1/2) - 1);
Printf("First cell height = %e\n", dh);

Point(1) = {r1, 0, 0};
Point(2) = {r2, 0, 0};
Point(3) = {r2, h, 0};
Point(4) = {r1, h, 0};

Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,1};

Line Loop(1) = {1,2,3,4};
//Plane Surface(2) = {1};
Ruled Surface(2) = {1};
Transfinite Surface(2) = {1,2,3,4};
Transfinite Line{1,3} = n1 Using Progression p;
Transfinite Line{2,4} = n2 Using Progression p;
Recombine Surface {2};

Physical Line(1) = {1}; // bottom
Physical Line(2) = {2}; // outer radius
Physical Line(3) = {3}; // top
Physical Line(4) = {4}; // inner radius

Physical Surface(100005) = {2};
