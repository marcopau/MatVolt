# Power System State Estimation - A quick introduction

## What is state estimation?
The concept of state estimation refers, in general terms, to those mathematical techniques that allow estimating the values of a set of unknown variables given some specific information (e.g., measurements), possibly affected by uncertainties, in input. 
The goal of a state estimation algorithm is to process the information in input to derive the most likely status of the desired (unknown) variables of a system. 

State estimation techniques are applied in many different fields, such as aerospace (for trajectory estimation and radar tracking), robotics (for robots position and orientation estimation), chemistry (for estimation of parameters in chemical and biochemical processes), etc.

Electrical engineering is also one of the areas where state estimation techniques are widely applied, again, for different tasks and purposes. In the following, we will refer specifically to the application of state estimation techniques for power system monitoring, which is commonly referred to as power system state estimation. 

## Power system state estimation
Real-time monitoring of the operating conditions of an electrical grid is a key task within the control centers of modern power systems. 
Monitoring the operating conditions of the grid implies finding the values of the electrical quantities (voltages, powers, currents) at each point of the grid. 


![Monitoring chain in control centers](/Docs/Fig/GridMonitoring.png "Monitoring chain in control centers")

Advanced monitoring applications rely on ad hoc state estimation algorithms.
Conventional state estimation approaches require in input:
- data about the grid model (e.g., network topology, status of the switches, impendances of the lines, etc.);
- real-time measurements coming from the devices deployed in the field, together with the information about their associated uncertainty;
- any other a priori information possibly available about the operation of the grid (e.g., zero injections).

The task of a state estimation algorithm is to process this set of inputs to derive the most likely operating conditions (electrical quantities) of the electrical network.
The output of the state estimation process can be then exploited within the control center to:
- simply give situational awareness to human operators, by means of dedicated Graphical User Interfaces;
- store the operating conditions over time, for possible a posteriori analysis;
- trigger specific control applications and automation processes, which need the knowledge of the existing operting conditions in order to operate.

## Some definitions

As the name suggests, power system state estimation algorithms need to *estimate* the *state* of a grid. 
But what is exactly the *state* of an electrical grid?

The **state of an electrical grid** can be defined as a set of representative state variables that, once known, allow computing all the electrical quantities of the network (voltages, powers, currents). 

In power system state estimation, the state of a grid is often associated to the set of voltage magnitudes and phase angles at the different nodes of the grid. In fact, if voltages are known, this information, combined with data of the grid, is enough to derive also the knowledge of the other electrical quantities (powers and currents). 

In general, however, it is worth noting that a different set of state variables can be also chosen as *state* of the grid (provided that it allows computing the remaining electrical quantities). This is the case also for some of the algorithms provided in this repository, which rely on branch current state variables rather than on voltages. 

## Why using state estimation?

A typical question that could arise when approaching the topic of power system state estimation is: *why using complex techniques for grid monitoring instead of simply using the available measurements?*
Below you can find three main reasons that motivate the use of state estimation algorithms:

1. **Measurements have uncertainties:** state estimation techniques are designed specifically to deal with the presence of the measurement uncertainty and, when redundant measurements are available, they allow filtering out as much as possible the measurement errors, thus giving a more accurate view of the grid operating conditions. 
2. **Measurements are not available for each quantity:** state estimation algorithms adopt probabilistic approaches to integrate all the available measurement information, and they take into account the constrains given by typical power flow equations to obtain the most likely value of each quantity, also those that are not directly measured. 
3. **Measurements may carry bad data:** measurements with very large errors can be received sometimes due to communication errors, malfunctioning of the meter or other reasons. Under specific conditions, state estimation algorithms are able to detect, identify and discard these bad data, so that they do not adversely affect the monitoring results.

## State estimation vs. power flow
Another typical doubt is about the concrete difference between state estimation and power flow. 
Even if both are used to derive the knowledge about the electrical quantities of a grid, there are some very important differences between them. 
The list below summarizes some of the most important of these differences.

- **Number of inputs:** power flow algorithm use in input a number of known quantities equal to the number of variables to be derived; state estimation algorithms work instead with redundant measurements (the larger the set of input measurements, the better the results).
- **Input values:** power flow algorithms commonly need as input a pair of quantities for each node of the grid; state estimation algorithms do not have a similar constraint and use whatever measurements are available, wherever they are. 
- **Type of inputs:** power flow algorithms do not deal with uncertainties and their inputs are deterministic; state estimation algorithms are instead conceived to deal with uncertainties and their input is stochastic.
- **Type of output:** similar to the previous point, power flow algorithms derive a deterministic output from the deterministic inputs; state estimation algorithms provide instead an output affected by uncertainty, which is the residual uncertainty remaining after the filtering estimation process. 
- **Application:** due to their nature, power flow algorithms are typically employed to perform off-line analysis or for planning studies; state estimation algorithms are instead used to process real-time measurements within on-line monitoring applications. 
- **Robustness to bad data:** power flow algorithms are not conceived to deal with real measurements and do not have bad data filtering capabilities (a possibly wrong input would thus lead to erroneous and misleading power flow results); as already mentioned, under specific conditions, state estimation algorithms can instead detect and suppress possibly existing bad data.