






WSST/
│
├── src/
│   ├── channel/
│   │   ├── generateUEChannels.m
│   │   ├── generateEDChannel.m
│   │   └── calculatePathLoss.m
│   │
│   ├── signal/
│   │   ├── generateNoise.m
│   │   └── generateTrainingSequence.m
│   │
│   ├── attack/
│   │   ├── simulatePSA.m
│   │   └── calculatePPR.m
│   │
│   ├── detection/
│   │   ├── calculateEigenvalues.m
│   │   └── detectPSA.m
│   │
│   └── utils/
│       ├── addGaussianNoise.m
│       └── removeZeroFeatures.m
│
├── examples/
│   ├── basicSimulation.m
│   └── advancedDetection.m
│
├── tests/
│   ├── testChannel.m
│   ├── testSignal.m
│   ├── testAttack.m
│   └── testDetection.m
│
├── docs/
│   ├── gettingStarted.md
│   ├── api/
│   │   ├── channel.md
│   │   ├── signal.md
│   │   ├── attack.md
│   │   └── detection.md
│   │
│   └── examples/
│       ├── basicSimulation.md
│       └── advancedDetection.md
│
├── LICENSE
└── README.md