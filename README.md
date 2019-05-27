# Transistor-based-chaotic-oscillator
About the https://iris.unipa.it/retrieve/handle/10447/276402/535513/81-Minati_Chaos-2017.pdf I show a set of dynamic non linear equation that represent a good approximation of autonomous chaotic oscillator circuit. Chaos is a pervasive occurrence in these kind of circuits.

<p align="center">
<img src="/img/circuit_.png" width="560">
</p>

# First test
Analyzing the circuit using Kirchhoff's circuit laws, the dynamics of Transistor-based-chaotic-oscillator can be accurately modeled by means of a system of seven nonlinear ordinary differential equations:
<p align="center">
  <img src="/img/Eq-1.png" width="480" />
</p>
Where:<br />
C1 is B-C parasitic capacitance of NPN_1<br />
C2 is B-E parasitic capacitance of NPN_1<br />
C3 is C-E parasitic capacitance of NPN_2<br />
<br />
And
<p align="center">
<img src="/img/Eq-3.png" width="170">
</p>

The functions f(x) and g(x) describe the electrical response of the nonlinear component (transistor NPN), and its shape depends on the used model of its components.
<p align="center">
<img src="/img/Eq_nl.png" width="490">
</p>

Consider the base current too
<p align="center">
<img src="/img/Eq_4.png" width="490">
</p>

The system become
<p align="center">
<img src="/img/Eq_s.png" width="400">
</p>

# Attractor
<p align="center">
  <img src="/img/attractor_VC.gif" width="405" />
  <img src="/img/attractor_VBC1.gif" width="405" />
</p>

# Second test

## Ideal circuit
A circuit model will always be an approximation of the real-world structure. 
An equivalent electrical circuit model is an idealized electrical description of a real structure. It is an approximation, based on using combinations of ideal circuit elements. In our case, after fists test, at the end we recognize:
<p align="center">
<img src="/img/circuit_2.png" width="620">
</p>
And, this time, the set of equations found are:<br />
<p align="center">
<img src="/img/equations_set.png" width="550">
</p>


# Signals
<p align="center">
<img src="/img/signal_t3.png" alt="alt text">
</p>

# Attractor
<p align="center">
  <img src="/img/attractor_VC_t3.png" width="600" />
</p>
