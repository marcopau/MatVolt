# Roadmap

MatVolt is still at an early stage. We are currently working on extending the list of available algorithms and features. 

Below you can find an overview of the modules we are planning to release soon.

## Power Flow

- Least Squares method
    - Branch current-based
- Newton Raphson method
- Gauss-Seidel method
- Backward/forward sweep method

## Conventional State Estimation

- Weighted Least Squares with virtual measurements
    - Polar node voltage version
    - Polar branch current version
- Weighted Least Squares with lagrangian constraints
    - Rectangular node voltage version
    - Polar node voltage version
    - Rectangular branch current version
    - Node branch current version
- Augmented WLS
    - Branch current
    - Node voltage 
- Weighted Least Absolute Value
- Interval State Estimation
- Modified Backward/forward sweep method

## PMU-based state estimation

- Linear WLS
    - node voltage based
    - branch current based
- Two-step method 

## Tracking State Estimation

- Extended Kalman Filter
- Unscented Kalman Filter
- Ensemble Kalman Filter

## Distributed State Estimation

- Two-step method
- Gradient-based method

## Low Observability State Estimation

- Artificial Neural Network based
- Modified WLS
- Low-rank matrix approach

## Three-phase estimators

- all previous estimators to be adapted for three-phase version

## Additional features

- Meshes detection
- Observability check
- Voltage regulators 
- Transformers
- ZIP loads (for power flow)
- Multiple slack
- MatPower interface

