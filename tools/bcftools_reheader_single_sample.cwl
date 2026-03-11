cwlVersion: v1.2
class: CommandLineTool
id: bcftools_reheader_single_sample
doc: |
  Rename the single sample column in a VCF/VCF.GZ to a provided sample name,
  then bgzip and index the output.
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'staphb/bcftools:1.17'
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: |-
      set -eo pipefail

      bcftools query -l $(inputs.input_vcf.path) | head -n 1 | awk -v new_name="$(inputs.sample_name)" '{print $1"\t"new_name}' > reheader_samples.tsv
      if [ ! -s reheader_samples.tsv ]; then
        echo "ERROR: Could not determine sample name from input VCF: $(inputs.input_vcf.basename)" >&2
        exit 1
      fi

      bcftools reheader --samples reheader_samples.tsv --output $(inputs.output_filename) $(inputs.input_vcf.path)
      bcftools index --threads $(inputs.cpu) --tbi --force $(inputs.output_filename)
inputs:
  input_vcf:
    type: File
    secondaryFiles:
      - {pattern: '.tbi', required: false}
      - {pattern: '.csi', required: false}
    doc: "Input VCF.GZ to reheader"
  sample_name:
    type: string
    doc: "Desired sample name for the last VCF column"
  output_filename:
    type: string
    doc: "Output bgzipped VCF filename"
  cpu:
    type: int?
    default: 4
    doc: "Number of CPUs to allocate to this task."
  ram:
    type: int?
    default: 16
    doc: "GB size of RAM to allocate to this task."
outputs:
  output_vcf_gz:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles:
      - .tbi