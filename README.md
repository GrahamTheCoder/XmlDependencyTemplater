# XmlDependencyTemplater
Generate nuspecs, wxs, etc. from a Resharper architecture file

GenerateXml.bat requires a file called Input\FromReSharperAnalyseProjectDependencies.argr which is generated from Resharper's architecture feature.
These dependencies are used to insert dependencies for various template types.

The templates provided are examples which need modifying to contain project-relevant information.
