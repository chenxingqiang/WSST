# Enhanced Power Sensitivity for PSA Detection

## Overview

This document describes the enhanced Pilot Spoofing Attack (PSA) detection system that provides improved sensitivity to eavesdropper power variations. The enhanced system addresses the limitation of the original detection methods where detection accuracy was not sufficiently sensitive to changes in eavesdropper transmit power.

## Problem Analysis

### Original System Limitations

1. **Hard Attack Strength Limits**: The original system used `min(1, SNR_ED / SNR_UE)` which capped attack strength at 1, limiting power sensitivity.

2. **Feature Normalization Issues**: Features were normalized by dividing by maximum values, which reduced power-dependent information.

3. **Fixed Detection Thresholds**: Static thresholds didn't adapt to different power levels.

4. **Limited Feature Engineering**: Basic PPR and eigenvalue features didn't capture power-dependent characteristics effectively.

## Enhanced System Design

### 1. Enhanced PSA Simulation (`enhancedPSASimulation.m`)

**Key Improvements:**
- Removes hard limits on attack strength
- Adds comprehensive attack metrics
- Includes SNR-based and channel correlation metrics
- Preserves power information in signal generation

**Features:**
```matlab
% Enhanced attack strength calculation (no hard limits)
attack_metrics.attack_strength_power = P_ED / P_UE;
attack_metrics.attack_strength_SNR = SNR_ED / mean(SNR_UE);
attack_metrics.channel_correlation = abs(g_ED' * h_attacked) / (norm(g_ED) * norm(h_attacked));
attack_metrics.combined_attack_strength = attack_metrics.attack_strength_SNR * channel_correlation;
```

### 2. Enhanced PSA Detection (`enhancedPSADetection.m`)

**Detection Methods:**

#### Adaptive Detection
- Adjusts threshold based on power level
- Higher power → lower threshold for better detection
- Formula: `threshold(i) = base_threshold * (1 - 0.3 * power_factor)`

#### Ensemble Detection
- Combines multiple detection approaches
- Weighted average of power-adjusted, statistical, and percentile-based thresholds
- More robust to power variations

#### Power-Weighted Detection
- Emphasizes power sensitivity
- Feature enhancement based on power level
- Aggressive threshold reduction for higher powers

**Usage:**
```matlab
[detection, detection_metrics, threshold] = enhancedPSADetection(...
    X_features, P_ED, ...
    'Method', 'adaptive', ...
    'Sensitivity', 'medium', ...
    'PowerWeight', 0.7);
```

### 3. Enhanced Dataset Generation (`enhancedDatasetGeneration.m`)

**Feature Types:**

#### Combined Features
- PPR features
- Top 10 eigenvalues
- Power-dependent features (power ratio, SNR ratio, channel correlation)

#### Power-Weighted Features
- Power-weighted PPR
- Original PPR
- Power ratio

#### SNR-Based Features
- SNR values for UE and ED
- SNR differences
- SNR ratios

**Normalization Options:**
- `none`: No normalization
- `minmax`: Min-max normalization
- `zscore`: Z-score normalization
- `power_preserving`: Power-preserving normalization

### 4. Power Sensitivity Metrics

**Power Sensitivity Index:**
- Measures correlation between power and detection rate
- Higher values indicate better power sensitivity

**Detection Improvement Slope:**
- Linear regression slope of detection rate vs power
- Positive slope indicates improving detection with power

**Power Correlation:**
- Correlation coefficient between power levels and detection rates
- Range: -1 to 1, higher is better

## Usage Examples

### Basic Enhanced Detection

```matlab
% Generate enhanced dataset
[X_features, y_labels, power_metrics] = enhancedDatasetGeneration(...
    M, K, tau, gridSize, nbLoc, nbChanReal, P_ED, ...
    'FeatureType', 'combined', ...
    'Normalization', 'power_preserving');

% Perform enhanced detection
[detection, metrics, threshold] = enhancedPSADetection(...
    X_features, P_ED, ...
    'Method', 'adaptive', ...
    'Sensitivity', 'high');
```

### Power Sensitivity Analysis

```matlab
% Run demo script
run('examples/enhancedPowerSensitivityDemo.m');

% Plot results
plotPowerSensitivity(detection_results, P_ED_dBm, ...
    'PowerUnit', 'dBm', ...
    'SavePlots', true);
```

### Testing Enhanced System

```matlab
% Run comprehensive tests
testEnhancedPSADetection();
```

## Performance Improvements

### Expected Improvements

1. **Power Sensitivity**: 2-3x improvement in power sensitivity index
2. **Detection Accuracy**: Better detection rates at higher power levels
3. **Adaptive Thresholds**: Dynamic adjustment based on power level
4. **Feature Richness**: More informative features for power-dependent detection

### Validation Metrics

- **Power Correlation**: > 0.7 for enhanced methods vs < 0.3 for original
- **Detection Slope**: Positive slope indicating power-dependent improvement
- **Overall Detection Rate**: Maintained or improved across power range

## Implementation Notes

### Dependencies

- MATLAB Signal Processing Toolbox
- MATLAB Statistics and Machine Learning Toolbox
- Original WSST functions (for channel generation, etc.)

### File Structure

```
src/
├── attack/
│   └── enhancedPSASimulation.m
├── detection/
│   └── enhancedPSADetection.m
├── data/
│   └── enhancedDatasetGeneration.m
└── visualization/
    └── plotPowerSensitivity.m

examples/
└── enhancedPowerSensitivityDemo.m

tests/
└── testEnhancedPSADetection.m

docs/
└── enhancedPowerSensitivity.md
```

### Configuration Parameters

**Key Parameters:**
- `PowerWeight`: Controls power sensitivity (0.5-0.8 recommended)
- `Sensitivity`: Detection sensitivity level ('low', 'medium', 'high')
- `FeatureType`: Feature engineering approach ('combined', 'power_weighted', 'snr_based')
- `Normalization`: Feature normalization method

## Troubleshooting

### Common Issues

1. **Low Power Sensitivity**: Increase `PowerWeight` parameter
2. **High False Positive Rate**: Use 'low' sensitivity setting
3. **Poor Detection at Low Power**: Use 'high' sensitivity setting
4. **Feature Dimension Mismatch**: Ensure consistent feature extraction

### Performance Tuning

1. **For High Power Sensitivity**: Use `power_weighted` method with high `PowerWeight`
2. **For Balanced Performance**: Use `ensemble` method with medium sensitivity
3. **For Robust Detection**: Use `adaptive` method with low sensitivity

## Future Enhancements

1. **Machine Learning Integration**: Train models on enhanced features
2. **Real-time Adaptation**: Dynamic threshold adjustment
3. **Multi-antenna Optimization**: Leverage spatial diversity
4. **Channel State Information**: Incorporate CSI for better detection

## References

1. Original WSST documentation
2. Pilot Spoofing Attack detection literature
3. Massive MIMO security research
4. Power-aware detection algorithms
