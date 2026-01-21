# AnnotSV ACMG Classification Update

## Summary of Changes

This update addresses the issue where AnnotSV was not correctly annotating variants with ACMG variant classification and class. The workflow has been updated to the latest software versions and properly configured for ACMG annotation.

## Version Updates

### SvABA
- **Previous version**: 1.1.0
- **Updated version**: 1.2.0 (latest release as of May 2023)
- **Changes**: Bug fixes, performance improvements, and enhanced variant calling accuracy

### AnnotSV  
- **Previous version**: 3.1.1
- **Updated version**: 3.5.3 (latest release as of September 2025)
- **Key improvements**:
  - Full ACMG/ClinGen SV interpretation guidelines implementation
  - ACMG pathogenicity class (1-5) annotation
  - ACMG scoring based on comprehensive criteria
  - Enhanced gene annotations and regulatory elements
  - Improved population frequency data integration

## ACMG Classification in AnnotSV v3.5.3

AnnotSV now provides comprehensive ACMG classification following the joint consensus recommendation of ACMG and ClinGen (Riggs et al., 2020):

| ACMG Score | Classification | Class |
|------------|----------------|-------|
| ≥0.99 | Pathogenic | 5 |
| 0.90 to 0.98 | Likely Pathogenic | 4 |
| -0.89 to 0.89 | Variant of Uncertain Significance (VUS) | 3 |
| -0.98 to -0.90 | Likely Benign | 2 |
| ≤-0.99 | Benign | 1 |

### Output Columns

The annotated TSV files will now include:
- **ACMG_class**: The pathogenicity class (1-5)
- **ACMG_score**: The numerical score used for classification
- Detailed annotations supporting the classification decision

## Configuration Changes

### 1. Docker Images Updated
- **svaba.cwl**: Updated to `pgc-images.sbgenomics.com/d3b-bixu/svaba:1.2.0`
- **annotsv.cwl**: Updated to `pgc-images.sbgenomics.com/d3b-bixu/annotsv:3.5.3`

### 2. AnnotSV Default Mode
- Set `annotation_mode` default to "both" to ensure full ACMG classification
- "both" mode produces:
  - **split** annotations (one line per gene overlapped)
  - **full** annotations (one line per SV with ACMG classification)

### 3. Annotation Files Required

For AnnotSV v3.5.3 to properly generate ACMG classifications, the annotation directory must include:

1. **Gene annotations**
   - RefSeq/ENSEMBL transcript data
   - Gene disease associations (OMIM, morbid genes)
   - Haploinsufficiency/Triplosensitivity scores

2. **Regulatory elements**
   - Enhancers, promoters, TADs
   - ENCODE regulatory regions

3. **Pathogenic databases**
   - ClinVar pathogenic SVs
   - ClinGen dosage sensitivity data
   - DECIPHER pathogenic CNVs

4. **Population frequency data**
   - gnomAD-SV
   - DGV (Database of Genomic Variants)
   - 1000 Genomes SVs

## Installing/Updating Annotation Files

To create a compatible annotation directory for AnnotSV v3.5.3:

```bash
# Install AnnotSV v3.5.3
git clone https://github.com/lgmgeo/AnnotSV.git
cd AnnotSV
git checkout v3.5.3

# Install human annotations (requires internet connection)
make PREFIX=/path/to/install install
make PREFIX=/path/to/install install-human-annotation

# Package annotations for CWL workflow
cd /path/to/install/share/AnnotSV
tar -czf annotsv_353_annotations_dir.tgz Annotations_*

# Upload to your workflow platform (e.g., CAVATICA)
```

## Usage in Workflow

### Input Parameters

```yaml
annotsv_annotations_dir:
  class: File
  path: /path/to/annotsv_353_annotations_dir.tgz

annotsv_genome_build:
  value: "GRCh38"  # or "GRCh37"
```

### Expected Outputs

For each SV caller (Manta and SvABA), the workflow will produce:

1. **\*_annotated_svs.tsv** - Annotated structural variants with ACMG class
2. **\*_annotated_indels.tsv** - Annotated indels with ACMG class
3. **\*_unannotated_*.tsv** - Variants that couldn't be annotated

Each annotated file will include ACMG classification columns for filtering and prioritization.

## Verifying ACMG Annotations

After running the workflow, verify ACMG annotations are present:

```bash
# Check for ACMG columns in output
gunzip -c sample.manta_annotated_svs.tsv.gz | head -1 | tr '\t' '\n' | grep -i acmg

# Expected output should include:
# ACMG_class
# ACMG_score
```

## Troubleshooting

### Issue: No ACMG columns in output

**Possible causes:**
1. Using old annotation files (v3.1.1 or earlier)
2. annotation_mode not set to "both" or "full"
3. Incomplete annotation directory missing ACMG criteria files

**Solution:**
- Ensure annotation directory is from AnnotSV v3.5.3
- Verify annotation_mode is set to "both" (default) or "full"
- Check that annotation files include all required databases

### Issue: All variants classified as Class 3 (VUS)

**Possible cause:** Missing or incomplete pathogenic/benign databases

**Solution:**
- Reinstall annotations with `make install-human-annotation`
- Verify ClinVar, ClinGen, and DECIPHER data are present in annotation directory

## References

- [AnnotSV GitHub Repository](https://github.com/lgmgeo/AnnotSV)
- [AnnotSV Documentation v3.5](https://github.com/lgmgeo/AnnotSV/blob/master/README.AnnotSV_3.5.pdf)
- [ACMG/ClinGen SV Guidelines (Riggs et al., 2020)](https://www.nature.com/articles/s41436-019-0686-8)
- [SvABA GitHub Repository](https://github.com/walaj/svaba)

## Files Modified

1. `/tools/svaba.cwl` - Updated to v1.2.0
2. `/tools/annotsv.cwl` - Updated to v3.5.3 with proper ACMG configuration
3. `/workflows/kfdrc-germline-sv-wf.cwl` - Updated documentation and version references

## Migration Notes

If upgrading from previous workflow versions:

1. **Docker images**: The updated Docker images will be pulled automatically on first run
2. **Annotation files**: You MUST update your annotation directory to v3.5.3 for ACMG classification
3. **Backward compatibility**: Workflows using old annotation files will run but won't have ACMG classification
4. **Output format**: Output TSV files will have additional ACMG columns

## Support

For issues specific to:
- **ACMG classification**: Check AnnotSV GitHub issues
- **Workflow execution**: Check KFDRC workflow repository
- **Annotation installation**: Refer to AnnotSV installation documentation
