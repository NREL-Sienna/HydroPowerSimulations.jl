# HydroPowerSimulations.jl Documentation Review

## Executive Summary

This document provides a comprehensive review of the HydroPowerSimulations.jl codebase and documentation to identify gaps between implemented models and documented features, as well as missing tutorials for potential use cases.

## 1. Formulation Coverage Analysis

### Formulations Exported (from source code)

The package exports **10 formulations** in `src/HydroPowerSimulations.jl`:

| # | Formulation | Documented in Library | Has Tutorial |
|---|-------------|----------------------|--------------|
| 1 | `HydroDispatchRunOfRiver` | Yes | Yes |
| 2 | `HydroDispatchRunOfRiverBudget` | Yes | Mentioned in how-to |
| 3 | `HydroCommitmentRunOfRiver` | Yes | **No** |
| 4 | `HydroEnergyBlockOptimization` | Yes | Yes |
| 5 | `HydroWaterModelReservoir` | Yes | Yes |
| 6 | `HydroTurbineBilinearDispatch` | Yes | Partial (within water tutorial) |
| 7 | `HydroEnergyModelReservoir` | Yes | Yes |
| 8 | `HydroTurbineEnergyDispatch` | Yes | Yes |
| 9 | `HydroTurbineEnergyCommitment` | **No** | **No** |
| 10 | `HydroPumpEnergyDispatch` | **No** | Yes (but no math docs) |

### Critical Gap: Missing Formulation Documentation

**Two formulations lack mathematical documentation in the Formulation Library:**

1. **`HydroTurbineEnergyCommitment`** - Unit commitment for hydro turbines with energy variables
2. **`HydroPumpEnergyDispatch`** - Pump-turbine dispatch formulation

These formulations should be added to `docs/src/model_library/formulation.md` with complete mathematical specifications.

---

## 2. Decision Model Coverage

### Exported Decision Models

| Model | Documented | Has Tutorial |
|-------|-----------|--------------|
| `MediumTermHydroPlanning` | **No** | **No** |

### Critical Gap: MediumTermHydroPlanning

The `MediumTermHydroPlanning` decision model is exported but:
- Has no conceptual documentation
- Has no tutorial demonstrating its use
- Has no explanation of when to use it vs. standard DecisionModel

This is a significant gap as it's one of only two decision problems in the package.

---

## 3. Tutorials Gap Analysis

### Current Tutorials (5 total)

1. **Operation Problem with HydroDispatchRunOfRiver** - Basic dispatch
2. **Energy Hydro Reservoir Operation** - Energy-based storage
3. **Water Hydro Reservoir Operation** - Water/head-based storage
4. **Hydro Pump-Turbine Operation** - Pumped storage
5. **HydroEnergyBlock Model** - Integrated block optimization

### Missing Tutorials (Priority Order)

#### Priority 1 - Critical

| Missing Tutorial | Reason |
|-----------------|--------|
| **Unit Commitment Tutorial** | Two formulations (`HydroCommitmentRunOfRiver`, `HydroTurbineEnergyCommitment`) have no examples |
| **MediumTermHydroPlanning Tutorial** | Exported decision model with no documentation |
| **Feedforward Mechanisms Tutorial** | 4 feedforward types exported but not explained with examples |

#### Priority 2 - High

| Missing Tutorial | Reason |
|-----------------|--------|
| **Multi-Reservoir Cascade Example** | All tutorials use single reservoir; real-world cascades are common |
| **Reserve Provision Example** | Reserve expressions exist but no tutorial shows hydro providing reserves |
| **Multi-Stage Optimization Example** | Feedforwards are designed for this but no example shows usage |

#### Priority 3 - Medium

| Missing Tutorial | Reason |
|-----------------|--------|
| **Budget Constraint Comparison** | Compare interval vs. full-horizon budgets |
| **Water vs Energy Model Selection Guide** | When to choose each approach |
| **Rolling Horizon Simulation** | Sequential optimization with state carry-over |

---

## 4. Component Documentation Gaps

### Parameters - Missing Documentation

The following parameters are exported but not clearly documented:

| Parameter | Exported | Documented |
|-----------|----------|------------|
| `EnergyTargetTimeSeriesParameter` | Yes | Partial |
| `EnergyBudgetTimeSeriesParameter` | Yes | Partial |
| `InflowTimeSeriesParameter` | Yes | Yes |
| `OutflowTimeSeriesParameter` | Yes | Yes |
| `ReservoirTargetParameter` | Yes | **Minimal** |
| `ReservoirLimitParameter` | Yes | **Minimal** |
| `HydroUsageLimitParameter` | Yes | **Minimal** |
| `WaterLevelBudgetParameter` | Yes | **Minimal** |

The feedforward-related parameters (`ReservoirTargetParameter`, `ReservoirLimitParameter`, `HydroUsageLimitParameter`, `WaterLevelBudgetParameter`) need more detailed documentation explaining their use cases.

### Constraints - Incomplete Documentation

Several constraints are exported but lack detailed explanations:

- `ActivePowerPumpReservationConstraint`
- `ActivePowerPumpVariableLimitsConstraint`
- `EnergyCapacityTimeSeriesLimitsConstraint`
- `ReservoirLevelLimitConstraint`
- `ReservoirLevelTargetConstraint`
- `TurbinePowerOutputConstraint`
- `ReservoirHeadToVolumeConstraint`
- `ReservoirInventoryConstraint`
- `FeedForwardWaterLevelBudgetConstraint`

### Feedforwards - No Examples

All 4 feedforward types are exported but lack practical examples:

1. `ReservoirTargetFeedforward`
2. `ReservoirLimitFeedforward`
3. `HydroUsageLimitFeedforward`
4. `WaterLevelBudgetFeedforward`

---

## 5. Use Cases Not Covered

### Problems HydroPowerSimulations Can Solve (from code analysis)

| Use Case | Currently Documented | Implementation Status |
|----------|---------------------|----------------------|
| Economic dispatch (run-of-river) | Yes | Complete |
| Energy-based reservoir scheduling | Yes | Complete |
| Water/head-based reservoir operation | Yes | Complete |
| Pumped hydro storage operation | Yes | Complete |
| Integrated block optimization | Yes | Complete |
| Unit commitment for hydro | **No** | Complete |
| Multi-stage optimization with feedforwards | **No** | Complete |
| Budget-constrained operations | Partial | Complete |
| Reserve provision by hydro | **No** | Complete |
| Cascading reservoir systems | **No** | Complete |
| Medium-term planning | **No** | Complete |

### Missing Use Case Documentation

1. **Unit commitment with on/off decisions** - When generators have significant startup/shutdown costs or constraints
2. **Multi-stage hierarchical optimization** - Day-ahead and real-time coordination
3. **Reserve market participation** - Hydro providing ancillary services
4. **Networked reservoir systems** - Multiple reservoirs with upstream/downstream relationships
5. **Time-varying storage capacities** - Seasonal reservoir limits

---

## 6. Recommendations

### Immediate Actions (Priority 1)

1. **Add HydroTurbineEnergyCommitment to Formulation Library**
   - Document variables, parameters, constraints, objective
   - Add complete mathematical formulation

2. **Add HydroPumpEnergyDispatch to Formulation Library**
   - Document the pump-turbine mathematical model
   - Include reservation constraint documentation

3. **Create Unit Commitment Tutorial**
   - Demonstrate `HydroCommitmentRunOfRiver`
   - Demonstrate `HydroTurbineEnergyCommitment`
   - Compare with dispatch-only formulations

4. **Create MediumTermHydroPlanning Tutorial**
   - Explain purpose and use cases
   - Show complete example with thermal and hydro

5. **Create Feedforward Mechanisms Tutorial**
   - Explain multi-stage optimization concept
   - Demonstrate each feedforward type
   - Show linking between stages

### Short-Term Actions (Priority 2)

6. **Add Multi-Reservoir Cascade Example**
   - Show upstream/downstream reservoir connections
   - Demonstrate water balance across cascade

7. **Add Reserve Provision Example**
   - Show reserve expressions usage
   - Integrate with service models

8. **Enhance Parameter Documentation**
   - Add detailed descriptions for all feedforward parameters
   - Include usage examples in docstrings

### Medium-Term Actions (Priority 3)

9. **Add Troubleshooting Guide**
   - Common infeasibility causes
   - Solver selection guidance
   - Numerical stability tips

10. **Add Performance Guide**
    - Model complexity comparison
    - Scalability considerations
    - Solver recommendations

11. **Add Migration Guide**
    - Moving from PowerSimulations basic hydro
    - When to use HydroPowerSimulations formulations

---

## 7. Table of Contents Update Recommendation

The Formulation Library table of contents should be updated to:

```markdown
### Table of Contents

#### Dispatch Formulations
1. [`HydroDispatchRunOfRiver`](#HydroDispatchRunOfRiver)
2. [`HydroDispatchRunOfRiverBudget`](#HydroDispatchRunOfRiverBudget)

#### Unit Commitment Formulations
3. [`HydroCommitmentRunOfRiver`](#HydroCommitmentRunOfRiver)
4. [`HydroTurbineEnergyCommitment`](#HydroTurbineEnergyCommitment) <!-- NEW -->

#### Turbine Formulations
5. [`HydroTurbineEnergyDispatch`](#HydroTurbineEnergyDispatch)
6. [`HydroTurbineBilinearDispatch`](#HydroTurbineBilinearDispatch)

#### Reservoir Formulations
7. [`HydroEnergyModelReservoir`](#HydroEnergyModelReservoir)
8. [`HydroWaterModelReservoir`](#HydroWaterModelReservoir)
9. [`HydroEnergyBlockOptimization`](#HydroEnergyBlockOptimization)

#### Pump-Turbine Formulations
10. [`HydroPumpEnergyDispatch`](#HydroPumpEnergyDispatch) <!-- NEW -->
```

---

## 8. Conclusion

HydroPowerSimulations.jl has a robust and comprehensive set of hydro optimization models. The documentation is well-structured following the Diataxis framework and provides good coverage of core features. However, there are notable gaps:

- **2 formulations** lack mathematical documentation
- **1 decision model** lacks any documentation
- **3+ use cases** lack tutorials
- **Feedforward mechanisms** are undocumented

Addressing these gaps will significantly improve user experience and make the full power of the package accessible to users. The package implements sophisticated multi-stage optimization capabilities that are not discoverable without documentation.

---

*Review Date: 2025-11-18*
*Repository: NREL-Sienna/HydroPowerSimulations.jl*
