# V2G

Simulation for academic purpose of a parking equipped with Vehicle to Grid technology.

The aim of this simulation is to show the possibility to have an economic remuneration providing energy to the MSD market. I simulated three different cars (2 equipped with lithium battery and one also with a supercapacitor), they are connected to the grid through a bidirectional converter. The grid is rapresented by a controlled current generator.

The control of the process is based on the SOC: the battery is discharged when the SOC is between 70 and 100. When is below it is recharged, so the user could take its car with enough power.

I only considered an MSD up-lift service (the cars provide power if the grid required), but you can also implement a smart charging when the grid needs to improve the load in order to maintain the balance.

Finally each lot is multiply for a random number to simulate lots of cars parked in the same time and they are connected and disconnected in random time interval like in reality.


In this repository you can find three files:
- Simulink simulation file
- Matlab parameters file for the simulation
- PDF file for the pitch that summarize the simulation


I chose to public my work in spirit of sharing, in order to give the possibility to improve this study. I apologize for any mistakes, but I would be happy if you would share them with me!

Enjoy my work and good luck!
Rodolfo
