<!-- dx-header -->
This applet is used to run the same workflow across many inputs which match a particular pattern. Please read the following documentation on how to use this applet, it must be used in a particular way to work correctly.

## Providing and API key:
-  This applet requires you to give an API key. You can generate one by clicking on your name in the upper right, selecting **Profile**, then selecting the **API tokens** tab, and generating a new token. The token will look like a long string of letters and numbers.

## For the workflow:

- You must provide the name of the workflow you would like to run

- The first stage of the workflow must have one or two unfilled inputs

- All other stages of the workflow must be fully configured in a valid way

## How inputs are chosen:

- Inputs must be in a directory named **Inputs**

- Only an input whose name matches the pattern **Input Pattern** will be considered. The ‘*’ character acts as a wildcard, so **\*fastq\*** will match any input with "fastq" anywhere in its name, while **\*fastq** will match only items which end in "fastq".

- The type of input is restricted by the parameter **Input Type**

- If the **paired** option is selected, for each input which contains the value for **Input Identifier** the applet will look for a paired input where **Input Identifier** is replaced by **Replace Identifier With**. For example, if the file example_R1.fastq has Input Identifier "R1" and Replace Identifier With R2, then the applet will look for example_R2.fastq in the inputs directory.

## Outputs

- The outputs of all jobs run will be placed in a directory called **Results_<date><time>**

