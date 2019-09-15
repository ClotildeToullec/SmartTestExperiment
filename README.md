# SmartTest Experiment

SmartTestExperiment is used to evaluate [SmartTest](https://github.com/badetitou/SmartTest).

Evaluate this code in a Playground to load it: 

```Smalltalk
Metacello new
  baseline: #SmartTestExperiment;
  githubUser: 'ClotildeToullec' project: 'SmartTestExperiment' commitish: 'master' path: '.';
  load
```
This project is dependant on [NeoCSV](https://github.com/svenvc/NeoCSV), [OSSubprocess](https://github.com/pharo-contributions/OSSubprocess) and [Roassal2](https://github.com/ObjectProfile/Roassal2).
