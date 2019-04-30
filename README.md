# Transistor-based-chaotic-oscillator
About the https://iris.unipa.it/retrieve/handle/10447/276402/535513/81-Minati_Chaos-2017.pdf I show a set of dynamic non linear equation that represent a good approximation of autonomous chaotic oscillator circuit. Chaos is a pervasive occurrence in these kind of circuits.

<p align="center">
<img src="/circuit_.png" width="560">
</p>

# Equations
Analyzing the circuit using Kirchhoff's circuit laws, the dynamics of Transistor-based-chaotic-oscillator can be accurately modeled by means of a system of seven nonlinear ordinary differential equations: 
<p align="center">
  <img src="/Eq-1.png" width="480" />
</p>
Where:<br />
C1 is B-C parasitic capacitance of NPN_1<br />
C2 is B-E parasitic capacitance of NPN_1<br />
C3 is C-E parasitic capacitance of NPN_2<br />
<br />
And
<p align="center">
<img src="/Eq-3.png" width="170">
</p>

The functions f(x) and g(x) describe the electrical response of the nonlinear component (transistor NPN), and its shape depends on the used model of its components.
<p align="center">
<img src="/Eq_nl.png" width="490">
</p>



# Signals
<p align="center">
<img src="/signal.png" alt="alt text">
</p>

# Attractor
<p align="center">
  <img src="/attractor_VC.gif" width="405" />
  <img src="/attractor_VBC1.gif" width="405" /> 
</p>
