# Overview
The Branch Processing Unit (or BPU) is the module responsible for the control flow of the processor, ultimately handelling all PC updates. It includes all logic for branch prediction, and branch resolution. It contains a Global History Register (or GHR), which tracks the global branch history of the processor, as well as local predictors, which provide the predictions themselves. The GHR tracks the last two branches, and the local predictors are 2-bits, meaning they have 4-states.

To store the prediction target addresses, a branching buffer is used. 

# BRU (Branch Resolution Unit)

## Design

## Testing

# GHR (Global History Register)

## Design

## Testing

# Local Predictor

## Design

## Testing

# Branching Buffer

## Design

## Testing

# Branch Predictor

## Design

## Testing

# Branch Control Unit

## Design

## Testing

# Key Tradeoffs

# Synthesis Results
